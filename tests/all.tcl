package require tcltest
namespace import tcltest::test

set ::tcltest::testSingleFile false
set ::tcltest::testsDirectory [file dirname [file normalize [info script]]]

set chan	$::tcltest::outputChannel

foreach file [lsort [::tcltest::getMatchingFiles]] {
	set tail	[file tail $file]
	puts $chan $tail
	try {
		source $file
	} on error {errmsg options} {
		puts $chan "Error: [dict get $options -errorinfo]"
	}
}

load [file join $::tcltest::testsDirectory ../libtcllemon.so] Tcllemon

::tcltest::cleanupTests 1
return
