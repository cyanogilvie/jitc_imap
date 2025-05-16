if {"::tcltest" ni [namespace children]} {
	package require tcltest
	namespace import tcltest::test
}

::tcltest::loadTestedCommands

package require jitc
package require rl_json
package require chantricks
namespace import ::rl_json::json

set tmpdir	[file join [file dirname [info script]] tmp]

::tcltest::configure \
	-tmpdir	$tmpdir

proc readfile fn {
	set h	[open $fn r]
	try {read $h} finally {close $h}
}

proc writefile {fn str} {
	set h	[open $fn w]
	try {puts -nonewline $h $str} finally {close $h}
}

set testy [::tcltest::makeFile \
	[readfile [file join [file dirname [info script]] test.y]] \
	test.y \
]

set srcdir	[file dirname [file dirname [file normalize [info script]]]]

apply {{} {
	global tcllemon_cdef srcdir

	set debugopts	[if 1 {
		set debugpath	[::tcltest::makeDirectory debug_tcllemon]
		list debug $debugpath
	}]

	set tcllemon_cdef	[list \
		{*}$debugopts \
		options {-Wall -Werror -g -std=c17} \
		code	[readfile [file join $srcdir tcllemon.c]] \
	]
}}

proc capply_tcllemon args {
	global tcllemon_cdef
	uplevel 1 [list ::jitc::capply $tcllemon_cdef tcllemon {*}$args]
}

trace add execution test {enter} [list apply {{cmd op} {
	global testname
	set testname [lindex $cmd 1]
}}]
trace add execution test {leave} [list apply {{cmd code result op} {
	global testname
	unset -nocomplain testname
}}]

proc replay {rxtrace {chunksize 0}} { #<<<
	global srcdir
	set res	{[]}
	chantricks with_file h [file join $srcdir tests/traces $rxtrace] rb {
		while {![eof $h]} {
			set chunk	[if {$chunksize} {read $h $chunksize} {read $h}]
			try {
				while 1 {
					set resp	[::jitc_imap::parse_response state $chunk[set chunk {}]]
					json set res end+1 $resp
				}
			} trap {IMAP MORE} {} continue
		}
	}

	#::jitc_imap::finalize state

	json normalize $res
}

#>>>

# vim: ft=tcl foldmethod=marker foldmarker=<<<,>>> ts=4 shiftwidth=4 noexpandtab
