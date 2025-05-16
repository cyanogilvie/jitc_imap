if {[catch {package present jitc_imap}]} {
	set srcdir	[file dirname [file normalize [info script]]]

	puts stderr "[file tail [info script]] loading dev packages from $srcdir"

	source [file join $srcdir imap.tcl]
	package provide jitc_imap 0.1

	if {[file readable libtcllemon.so]} {
		load [file join $srcdir libtcllemon.so] Tcllemon
	}
}
