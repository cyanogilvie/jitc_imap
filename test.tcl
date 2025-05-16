source test_load_packages.tcl

package require aws 2
package require chantricks 1.0.7		;# for appendbin fix
package require rl_json
namespace import ::rl_json::json

namespace eval tapchan {
	namespace export *
	namespace ensemble create -prefixes no -map {
		read	_read
	} -subcommands {
		initialize
		finalize
		read
		write
	}

	proc initialize {chan mode}		{chantricks writebin tests/traces/last_rx {}; return {initialize finalize read write}}
	proc finalize	chan			{}
	proc _read		{chan bytes}	{chantricks appendbin tests/traces/last_rx $bytes; set bytes}
	proc write		{chan bytes}	{set bytes}
}

coroutine mail try {
	::jitc_imap::client instvar imap -host imap.gmail.com -port 993 -tapchan tapchan -req_timeout 45
	#::jitc_imap::client instvar imap -host imap.gmail.com -port 993

	#puts "mbox_or_pat str: ([$imap quote mbox_or_pat {"RT/%"}])"
	#puts "mbox_or_pat arr: ([$imap quote mbox_or_pat {["RT/%", "RT/Marketing"]}])"

	set secrets	[json get [aws secretsmanager get_secret_value -secret_id rt] SecretString]
	$imap LOGIN \
		[json extract $secrets fetchmail_user] \
		[json extract $secrets fetchmail_password]

	if 0 {
		if {[$imap has_cap COMPRESS=DEFLATE]} {
			puts stderr "Attempting to enable deflate compression"
			$imap COMPRESS DEFLATE
		}
	}

	# List mailboxes with unseen messages <<<
	set fetch_mailboxes	{}
	if {[$imap has_cap LIST-EXTENDED]} {
		#set listcmd	{LIST "" "RT/%" RETURN (STATUS (UNSEEN))}
		set listcmd	{LIST "" "*" RETURN (STATUS (UNSEEN))}

		$imap on LIST apply {details {
			if {![string match RT/* [json get $details mailbox]]} {
				puts "LIST Ignoring mailbox: [json pretty $details]"
			} else {
				puts "LIST RT mailbox: [json pretty $details]"
			}
		}}
		$imap on STATUS apply {{var details} {
			puts [format {%-40s %4d unseen messages} [json get $details mailbox] [json get $details status UNSEEN]]
			if {
				[string match RT/* [json get $details mailbox]] &&
				[json get $details status UNSEEN] > 0
			} {
				lappend $var	[json get $details mailbox]
			}
		}} [namespace which -variable fetch_mailboxes]
	} else {
		set listcmd	{LIST "" "RT/%"}

		$imap on LIST apply {{var details} {
			#puts stderr "untagged LIST details: [json pretty $details]"
			lappend $var	[json get $details mailbox]
			#puts stderr "Added mailbox ([json get $details mailbox]) to fetch_mailboxes"
		}} [namespace which -variable fetch_mailboxes]
	}
	$imap req $listcmd
	$imap off STATUS
	$imap off LIST
	#>>>

	# Fetch unseen messages <<<
	puts stderr \n[string repeat - 80]
	puts "fetch_mailboxes: ($fetch_mailboxes)"

	set flagged	{}
	foreach mailbox $fetch_mailboxes {
		if {0 && $mailbox eq "RT/CS_Alerts"} {
			puts stderr "skipping mailbox: ($mailbox)"
			continue
		}

		#set select_id	[$imap writeline "SELECT [$imap quote astring [json string $mailbox]]"]
		$imap SELECT $mailbox
		#puts stderr "Selected mailbox: ($mailbox), state: ([json pretty [$imap mailbox_state]])"
		puts "Selected mailbox $mailbox"

		set seqset	{}
		$imap on ESEARCH apply {{seqsetvar mailbox details} {
			if {[json exists $details results ALL]} {
				set $seqsetvar [json get $details results ALL]
			}
		}} [namespace which -variable seqset] $mailbox
		#$imap req {UID SEARCH RETURN (ALL) UNSEEN}
		$imap req {UID SEARCH RETURN (ALL) (UNSEEN UNFLAGGED)}
		#$imap req {UID SEARCH RETURN (ALL) FLAGGED}
		$imap off ESEARCH

		puts stderr "After SEARCH, seqset: ($seqset)"
		if {$seqset eq {}} {
			puts stderr "No unseen messages in mailbox: ($mailbox)"
			continue
		}

		$imap on FETCH apply {{imap mailbox flaggedvar details} {
			if {![json exists $details msg {BODY[]}]} {
				puts stderr "Ignoring response with no BODY\[\], probably a response to the UID STORE command"
				return
			}
			set dir		[file join /tmp/fetch_results $mailbox]
			file mkdir $dir
			try {
				set uid	[json get $details msg UID]
				chantricks writefile [file join $dir $uid] $details
			} on ok {} {
				set store_id	[$imap writeline "UID STORE [$imap quote sequence_set [json string $uid]] +FLAGS.SILENT (\\Flagged Foo)"]
				dict incr $flaggedvar $mailbox 1
				#set store_id	[$imap writeline "UID STORE [$imap quote sequence_set [json string $uid]] -FLAGS (\\Seen \\Flagged)"]
			}
		}} $imap $mailbox [namespace which -variable flagged]
		$imap req "UID FETCH $seqset (FLAGS X-GM-MSGID X-GM-LABELS MODSEQ BODY.PEEK\[\])"
		$imap off FETCH
	}
	# Fetch unseen messages >>>

	puts "flagged messages:\n\t[join [lmap {k v} $flagged {format {%4d %40s} $v $k}] \n\t]"
	$imap LOGOUT
} on ok {} {
	set exit 0
} on error {errmsg options} {
	puts stderr [dict get $options -errorinfo]
	set exit 1
}

if {![info exists exit]} {vwait exit}
exit $exit

# vim: ft=tcl ts=4 shiftwidth=4 foldmethod=marker foldmarker=<<<,>>> noexpandtab
