package ifneeded jitc_imap 0.1 [list apply {dir {
	source [file join $dir imap.tcl]
	package provide jitc_imap 0.1
}} $dir]
