package require jitc
package require chantricks
package require gc_class
package require rl_json

namespace eval ::jitc_imap {
	namespace export *
	namespace ensemble create -prefixes no
	namespace path {
		::rl_json
	}

	if {![llength [info commands ::jitc_imap::log]]} {
		proc log {lvl msg} {puts stderr "$lvl: $msg"}
	}

	variable cdef	[apply [list {} { # Send the source through tcllemon and re2c <<<
		variable dir	[file dirname [file normalize [info script]]]
		variable debug
		if {![info exists debug]} {set debug 0}

		variable cdef {
			options	{-Wall -Werror -std=c17 -D_POSIX_C_SOURCE=200809L -g}
			package	{rl_json	0.15.3}
			package	{dedup		0.9.5}
		}

		set saved	[pwd]
		try {
			set tmpdir	[file tempdir jitc_imap]
			cd $tmpdir

			file link -symbolic code.y		[file join $dir imap.y]
			file link -symbolic imap.re		[file join $dir imap.re]

			::jitc::capply [list options {-Wall -Werror -std=c17} code [chantricks readfile [file join $dir tcllemon.c]]] \
				tcllemon -l \
					-q \
					-allow_conflicts \
					-d $tmpdir \
					-T [file join $dir lempar.c] \
					-i code.y

			#		-headervar header \
			#chantricks writefile code.h $header

			exec -- $::jitc::re2cpath --input-encoding utf8 \
				-W -Wno-nondeterministic-tags -Werror --case-ranges --storable-state --conditions \
				--no-debug-info \
				--header imap.h \
				--output imap.c \
				imap.re

			if {$debug} {lappend cdef debug $tmpdir}
			if {$debug} {log notice "debugdir: $tmpdir"}

			# "file" doesn't work here because it lacks the jitc preamble that
			# includes headers and definitions that MODE_TCL source assumes
			#lappend cdef file [file join $debugdir parse.c]
			lappend cdef include_path $tmpdir code "#include \"code.c\"\n"

			if {$debug} {
				# Wrapper to allow test builds with gcc (for better error hunting)
				file link -symbolic Makefile	[file join $dir Makefile.gcc]
				file link -symbolic gcc.tcl		[file join $dir gcc.tcl]
				chantricks writefile cdef $cdef
			}

			jitc::symbols $cdef	;# Trigger a compile before the tmpdir is removed

			set cdef
		} finally {
			cd $saved
			if {!$debug && [info exists tmpdir]} {file delete -force $tmpdir}
		}
	} [namespace current]]]

	#>>>

	jitc::bind [namespace current]::parse_response	$cdef parse_response
	jitc::bind [namespace current]::finalize		$cdef finalize
	jitc::bind [namespace current]::quote			$cdef quote
	jitc::bind [namespace current]::log_chan		$cdef log_chan
	jitc::bind [namespace current]::log_stderr		$cdef log_stderr
	jitc::bind [namespace current]::disable_log		$cdef disable_log

	proc enable_trace prefix { #<<<
		variable trace_log_tid

		package require Thread

		if {![info exists trace_log_tid]} {
			set trace_log_tid	[thread::create -preserved -joinable]

			thread::send $trace_log_tid {
				package require Thread

				proc readable {chan maintid} {
					while 1 {
						set line	[gets $chan]
						if {[chan eof $chan]} {
							thread::release [thread::id]
							close $chan
							return
						}
						if {[chan blocked $chan]} return
						#puts stderr "TRACE: trace thread read line: ($line)"
						thread::send -async $maintid [list namespace eval ::jitc_imap [list log debug $line]]
					}
				}
			}

			set chan	[log_chan $prefix]
			chan configure $chan -buffering line -blocking 0
			thread::detach $chan
			thread::send $trace_log_tid [list thread::attach $chan]
			thread::send $trace_log_tid [list chan event $chan readable [list readable $chan [thread::id]]]
		}
	}

	#>>>
	proc disable_trace {} { #<<<
		variable trace_log_tid
		if {[info exists trace_log_tid]} {
			disable_log
			thread::join $trace_log_tid
			update	;# Need to process the log event sends waiting on our event loop
		}
	}

	#>>>

	gc_class create client {
		variable {*}{
			cdef
			sock
			state
			capability
			rxbuf
			idseq
			cmdwait
			resp_text_code
			resp_text
			on
			capability
			mailbox_state
			req_timeout
			utf8
		}

		constructor args { #<<<
			if {[self next] ne ""} next

			package require aio
			package require s2n
			package require parse_args
			namespace path [list {*}[namespace path] {*}{
				::parse_args
				::rl_json
				::jitc_imap
			}]

			parse_args $args {
				-host				{-required}
				-port				{-default 993}
				-connect_timeout	{-default 5.0 -# {seconds}}
				-req_timeout		{-default 5.0 -# {seconds}}
				-tapchan			{}
			}

			set state			connecting
			set idseq			0
			set utf8			0
			array set on		{}
			my off STATUS
			my off FETCH
			my off LIST
			my off ESEARCH
			my off BYE
			my off OK
			my off RECENT
			my off EXISTS
			my off FLAGS
			my _reset_mailbox_state

			array set cmdwait {}

			set sock	[socket $host $port]
			if {$port eq 993} {
				chan configure $sock -buffering none -translation binary
				s2n::push $sock -servername imap.gmail.com
			}
			if {[info exists tapchan]} {
				chan push $sock $tapchan
			}
			chan configure $sock -buffering none -blocking 0 -translation binary
			set state	{server greeting}

			coroutine statemachine my _statemachine

			chan event $sock readable [namespace code {my _readable}]

			# Wait for server greeting
			set timeout_horizon	[expr {[clock microseconds]/1e6 + $connect_timeout}]
			while 1 {
				set remain	[expr {max(0, $timeout_horizon - [clock microseconds]/1e6)}]
				switch -exact -- $state {
					{server greeting}					{aio coro_vwait [namespace which -variable state] $remain}
					Logout								{throw [list JITC_IMAP REFUSED $resp_text_code] $resp_text}
					{Not Authenticated}	- Authenticed	break
					default								{error "Unexpected state: ($state)"}
				}
			}
		}

		#>>>
		destructor { #<<<
			my _close_sock
			rename statemachine {}
			if {[self next] ne ""} next
		}

		#>>>
		method _close_sock {} { #<<<
			if {[info exists sock] && $sock in [chan names]} {
				close $sock
			}
			unset -nocomplain sock
		}

		#>>>
		method _readable {} { #<<<
			#log debug "_readable"
			set chunk		[read $sock]
			if {[eof $sock]} {
				log debug "EOF on socket"
				my _close_sock
				if {$chunk eq {}} return
			}

			try {
				while 1 {
					set feed	$chunk
					set chunk	{}
					#log debug "Sending chunk ([string length $chunk]) bytes to parse_response"
					statemachine [parse_response rxbuf $feed]
				}
			} trap {JITC_IMAP MORE} {} {
				#log error "Trapped JITC_IMAP MORE, returning from _readable"
				if {![info exists sock]} {
					if {[array size cmdwait]} {
						#log notice "Socket closed, resolving all waiting commands as errors"
						foreach k [array names cmdwait] {
							#log notice "Resolving command $k as error"
							set cmdwait(k) {"IMAP connection collapsed" {-code TCL_ERROR -errorcode {JITC_IMAP CLOSED} -level 0}}
						}
					}
				}
			} trap {JITC_IMAP PARSE_FAILED}		{r o} - \
			  trap {JITC_IMAP SYNTAX_ERROR}		{r o} - \
			  trap {JITC_IMAP STACK_OVERFLOW}	{r o} {
				log error "$r ([dict get $o -errorcode]):\nrxbuf: $rxbuf\nfeed: [binary encode hex $feed]"
				return -options $o $r
			} on error {r o} {
				log error "([dict get $o -errorcode]) Error parsing response: $r\nrxbuf: $rxbuf\nfeed: [binary encode hex $feed]"
				return -options $o $r
			}
		}

		#>>>
		method _statemachine {} { #<<<
			while 1 {
				set resp	[yield]

				switch -exact -- $state {
					{server greeting} { #<<<
						#log notice "Server greeting: [json pretty $resp]"
						switch -exact -- [json get $resp type],[json get $resp untagged] {
							untagged,OK {
								#log notice "Got server greeting: [json pretty $resp]"
								my _set_state	{Not Authenticated}
							}
							untagged,PREAUTH {
								#log notice "Server preauthenticated us: [json pretty $resp]"
								my _set_state	Authenticated
							}
							untagged,BYE {
								log notice "Server refused connection: [json pretty $resp]"
								my _set_state	Logout
							}
							default {
								log error "Unexpected server greeting: [json pretty $resp]"
								my _set_state	Logout
							}
						}
						#>>>
					}
					{Not Authenticated} - Authenticated - Selected { #<<<
						#log notice "State $state: [json pretty $resp]"
						switch -exact -- [json get $resp type] {
							untagged {
								my untagged $resp
							}
							tagged {
								catch {
									switch -exact -- [json get $resp state] {
										OK	{json extract $resp details}
										NO	{throw [list JITC_IMAP NO  {*}[json get -default {} $resp details code]] [json get $resp details text]}
										BAD {throw [list JITC_IMAP BAD {*}[json get -default {} $resp details code]] [json get $resp details text]}
										default {
											log error "Unexpected state: [json pretty $resp]"
											my destroy
											return
										}
									}
								} r o
								#dict incr o -level 2
								#dict set o -errorinfo {}
								set cmdwait([json get $resp tag]) [list $r $o]
							}
							continue {
								if {![info exists on(+)]} {
									log error "Got continuation request without handler registered"
									my destroy
									return
								}
								{*}$on(+) [json extract $resp details]
							}
							default {error "Unexpected state: ($state)"}
						}
						#>>>
					}
					Logout { #<<<
						#log debug "State $state: [json pretty $resp]"
						switch -exact -- [json get $resp type] {
							untagged {
								log error "Unexpected untagged response in Logout state: [json pretty $resp]"
							}
							tagged {
								catch {
									switch -exact -- [json get $resp state] {
										OK	{json extract $resp details}
										NO	{throw [list JITC_IMAP NO  {*}[json get -default {} $resp details code]] [json get $resp details text]}
										BAD {throw [list JITC_IMAP BAD {*}[json get -default {} $resp details code]] [json get $resp details text]}
										default {
											log error "Unexpected state: [json pretty $resp]"
											my destroy
											return
										}
									}
								} r o
								set cmdwait([json get $resp tag]) [list $r $o]
							}
							continue {
								log error "Unexpected continuation request in Logout state: [json pretty $resp]"
								if {![info exists on(+)]} {
									log error "Got continuation request without handler registered"
									my destroy
									return
								}
								{*}$on(+) [json extract $resp details]
							}
						}
						#>>>
					}
					default { #<<<
						log error "Unexpected state: ($state)"
						my destroy
						return
						#>>>
					}
				}

				if {$state eq {Logout}} {
					log notice "State Logout, closing connection"
					my _close_sock
				}
			}
		}

		#>>>
		method untagged resp { #<<<
			set type	[json get $resp untagged]
			set unhandled	0
			switch -exact -- $type {
				CAPABILITY {
					set capability	[json get $resp details]
				}
				EXISTS {
					#log notice "Observed EXISTS: [json pretty $resp details]"
					json set mailbox_state exists [json extract $resp details]
				}
				RECENT {
					#log notice "Observed RECENT: [json pretty $resp details]"
					json set mailbox_state recent [json extract $resp details]
				}
				CLOSED {
					#log notice "Observed CLOSED: [json pretty $resp details]"
					my _reset_mailbox_state
					my _set_state	Authenticated
				}
				BYE {
					#log notice "Server BYE: [json pretty $resp]"
					my _reset_mailbox_state
					my _set_state	Logout
				}
				FLAGS {
					json set mailbox_state flags [json extract $resp details]
				}
				ENABLED {
					foreach cap [json get $resp details] {
						switch -exact -nocase -- $cap {
							UTF8=ACCEPT		{set utf8 1}
						}
					}
				}
				OK {
					switch -exact -- [json get -default {} $resp details code 0] {
						PERMANENTFLAGS {
							set v	[json extract $resp details code 1]
							json set mailbox_state permanentflags $v
						}
						UIDVALIDITY {
							set v	[json extract $resp details code 1]
							json set mailbox_state uidvalidity $v
						}
						UIDNEXT {
							set v	[json extract $resp details code 1]
							json set mailbox_state uidnext $v
						}
						HIGHESTMODSEQ {
							set v	[json extract $resp details code 1]
							json set mailbox_state highestmodseq $v
						}
						default {
							set unhandled	1
						}
					}
				}
				default {
					#log debug "Got untagged [json get $resp untagged]: [json extract $resp details]"
					set unhandled	1
				}
			}

			if {[info exists on($type)]} {
				{*}$on($type) [json extract $resp details]
			} elseif {$unhandled} {
				log debug "Got untagged [json get $resp untagged] without registered handler: [json extract $resp details]"
				#log debug "No handler registered for untagged type: ($type):\n\t[join [lmap {k v} [array get on] {format {%20s: %s} $k $v}] \n\t]"
			}
		}

		#>>>
		method _set_state newstate { #<<<
			set oldstate	$state
			#switch -exact -- $oldstate {
			#	Selected			{}
			#}
			switch -exact -- $newstate {
				{Not Authenticated}	{set state {Not Authenticated}}
				Authenticated		{set state Authenticated}
				Selected			{set state Selected}
				Logout				{set state Logout; my _close_sock}
				default				{error "Can't transition states ($oldstate) -> ($newstate)"}
			}
		}

		#>>>
		method _reset_mailbox_state {} { #<<<
			set mailbox_state	{{}}
		}

		#>>>
		method mailbox_state {} { set mailbox_state }
		method capability {} { #<<<
			if {![info exists capability]} {
				my req CAPABILITY
			}
			set capability
		}

		#>>>
		method has_cap cap { expr {$cap in $capability} }
		method id {} {format a%04d [incr idseq]}
		method writeline cmd { puts -nonewline $sock "[set id [my id]] $cmd\r\n"; set id }
		method req {cmd {untagged_handlers {}}} { #<<<
			set tag	[my writeline $cmd]
			if {$untagged_handlers eq {}} {return [my wait $tag]}

			if {[llength $untagged_handlers] % 3} {error "Invalid handlers"}

			set handler_names	{}
			set handler_vars	{}
			set handler_scripts	{}
			foreach {name detailsvar script} $untagged_handlers {
				if {[info exists $detailsvar]} {error "Duplicate untagged handler for $name: $detailsvar"}
				lappend handler_names $name
				dict set handler_vars		$name $detailsvar
				dict set handler_scripts	$name $script
				my on $name [info coroutine] untagged $name
			}

			set timeout_afterid	[after [expr {int($req_timeout * 1000)}] [list [info coroutine] timeout]]
			set fqvar			[namespace which -variable cmdwait]($tag)
			set writehandler	[list [info coroutine] gotresp]

			set cleanup	[list apply {{self fqvar afterid writehandler handler_names args} {
				after cancel $afterid
				trace remove variable $fqvar write $writehandler
				if {[info object isa object $self]} {
					foreach name $handler_names {$self off $name}
				}
			}} [self] $fqvar $timeout_afterid $writehandler $handler_names]

			trace add command [info coroutine] delete $cleanup
			trace add variable $fqvar write $writehandler
			try {
				set yo	{-level 0}
				set yr	{}
				while 1 {
					set args	[lassign [yieldto return -options $yo $yr] ev]
					set yo		{-level 0}
					set yr		{}
					switch -exact -- $ev {
						gotresp {
							lassign $cmdwait($tag) r o
							unset cmdwait($tag)
							break
						}

						timeout {
							catch {throw [list JITC_IMAP TIMEOUT $tag] "Request timed out"} r o
							break
						}

						untagged {
							catch {
								parse_args $args {
									name	{-required}
									details {-required}
								}
								uplevel 1 [list set [dict get $handler_vars $name] $details]
								uplevel 1 [dict get $handler_scripts $name]
							} yr yo	;# Arrange for the yeildto to rethrow our exception to our caller (statemachine method) if there was one
						}

						default {
							catch {error "Unexpected wakeup event: ($ev) with args: ($args)"} r o
							break
						}
					}
				}
			} finally {
				trace remove command [info coroutine] delete $cleanup
				{*}$cleanup
			}
			after 0 [list [info coroutine]]
			yield
			return -options $o $r
		}

		#>>>
		method wait id { #<<<
			lassign [aio coro_vwait [namespace which -variable cmdwait]($id) $req_timeout] r o
			unset -nocomplain cmdwait($id)
			#log debug "vwait [namespace which -variable cmdwait]($id) returned: r: ($r). o: ($o)"
			return -options $o $r
		}

		#>>>
		method state {} {set state}
		method LOGIN {user pass} { #<<<
			set r	[my req "LOGIN [quote astring $user] [quote astring $pass]"]
			my _set_state Authenticated
			set r
		}; export LOGIN

		#>>>
		method LOGOUT {} { #<<<
			my req "LOGOUT"	;# BYE untagged response sets the state
		}; export LOGOUT

		#>>>
		method LIST args { #<<<
			parse_args $args {
				-select_options	{-validate {json valid}}
				-return_optins	{-validate {json valid}}
				reference		{-required -validate {json valid}}
				pattern			{-required -validate {json valid}}
			}

			set params	{}
			if {[info exists select_options]} {
				lappend params [quote imap_list $select_options]
			}
			lappend params [quote astring $reference] [quote mbox_or_pat $pattern]
			if {[info exists return_options]} {
				lappend params [quote imap_list $return_options]
			}
			my req "LIST [join $params]"
		}; export LIST

		#>>>
		method SELECT mailbox { #<<<
			try {
				my _reset_mailbox_state
				my req "SELECT [quote astring [json string $mailbox]]"
			} trap {JITC_IMAP NO} {r o} {
				log notice "SELECT failed: $r\n$o"
				my _set_state	Authenticated
			} on ok r {
				my _set_state Selected
			}
			set r
		}; export SELECT

		#>>>
		method EXAMINE mailbox { #<<<
			try {
				my _reset_mailbox_state
				my req "EXAMINE [quote astring [json string $mailbox]]"
			} trap {JITC_IMAP NO} {r o} {
				log notice "EXAMINE failed: $r\n$o"
				my _set_state	Authenticated
			} on ok r {
				my _set_state Selected
			}
			set r
		}; export EXAMINE

		#>>>
		method COMPRESS algorithm { #<<<
			if {![my has_cap "COMPRESS=[quote atom [json string $algorithm]]"]} {
				error "Server does not support COMPRESS $algorithm"
			}
			try {
				switch -nocase -- $algorithm {
					DEFLATE {
						my req "COMPRESS [quote atom [json string $algorithm]]"
						zlib push deflate $sock
					}
					default {
						error "Compression $algorithm is not suppported in the client"
					}
				}
			} trap {JITC_IMAP NO COMPRESSIONACTIVE} {r o} {
				log notice "Compression already active: $r"
			} trap {JITC_IMAP NO} {r o} {
				log notice "COMPRESS $algorithm failed: $r\n$o"
			}
		}; export COMPRESS

		#>>>
		method ENABLE capability { #<<<
			if {![my has_cap ENABLE] || ![my has_cap $capability]} {
				error "Server does not support ENABLE $capability"
			}
			my req "ENABLE [quote atom [json string $capability]]"
		}; export ENABLE

		#>>>
		method on {type args} { set on($type) $args }
		method off type { #<<<
			set on($type) [list apply [list {type details} {
				upvar 1 unhandled unhandled
				if {$unhandled} {
					log notice "No handler for untagged response $type, received $details"
				}
			} [namespace current]] $type]
		}

		#>>>
		method quote args {quote {*}$args}
	}
}

# vim: ft=tcl ts=4 shiftwidth=4 foldmethod=marker foldmarker=<<<,>>> noexpandtab
