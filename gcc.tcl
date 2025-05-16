package require chantricks
package require jitc

set options		{}
set ldflags		{}
set libs		{}
set cflags		{}
set preamble	"#include <tclstuff.h>\n"
set packages	{}

foreach {pref v} {
	-I	::jitc::includepath
	-L	::jitc::libpath
} {
	if {[info exists $v]} {
		foreach e [set $v] {
			lappend cflags ${pref}$e
		}
	}
}

lappend cflags -DUSE_TCL_STUBS=1

foreach {k v} [chantricks readfile cdef] {
	switch -exact -- $k {
		package {
			package require {*}$v
			set name	[lindex $v 0]
			lappend packages $v

			foreach key {
				header
			} {
				try {
					::${name}::pkgconfig get $key
				} on ok val {
					append preamble	"\n#include <$val>\n"
				} on error {} {}
			}

			foreach key {
				includedir,runtime
				includedir,install
			} {
				try {
					::${name}::pkgconfig get $key
				} on ok val {
					lappend cflags	-I$val
				} on error {} {}
			}

			foreach key {
				libdir,runtime
				libdir,install
			} {
				try {
					::${name}::pkgconfig get $key
				} on ok val {
					lappend ldflags	-L$val -Wl,-rpath,$val
				} on error {} {}
			}

			foreach key {
				library
			} {
				try {
					::${name}::pkgconfig get $key
				} on ok val {
					if {[string match lib* $val]} {
						set val	[string range $val 3 end]
					}
					lappend libs	-l$val
				} on error {} {}
			}
		}

		options {
			set options	$v
		}
	}
}

lappend libs	-ltclstub8.7

lappend options -Wno-error=unused-variable -Wno-error=unused-label
set cflags	[list {*}$options {*}$cflags]

namespace eval $argv0 {
	namespace export *
	namespace ensemble create -prefixes no

	proc cflags {} {join $::cflags}
	proc ldflags {} {join [list {*}$::ldflags {*}$::libs]}
	proc preamble {} {set ::preamble}
	proc package {name ver} {
		string map [list \
			%name%			[list $name] \
			%Name%			[list [string totitle $name]] \
			%ver%			[list $ver] \
			%loadpackages%	[join [lmap e $::packages {string cat {package require } [join $e]}] \n] \
		] {
			package ifneeded %name% %ver% [list apply {dir {
				%loadpackages%
				load [file join $dir %name%[info sharedlibextension]] %Name%
			}} $dir]
		}
	}
	proc tclinit {name ver} {
		string map [list \
			%name%	$name \
			%Name%	[string totitle $name] \
			%ver%	$ver \
		] {
			DLLEXPORT int %Name%_Init(Tcl_Interp* interp)
			{
				int code = TCL_OK;

				#if USE_TCL_STUBS
				if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) return TCL_ERROR;
				#endif
				// TODO: jitc cdefs aren't designed to run in a threaded context - prevent it being loaded into multiple interps

				code = init(interp);
				if (code != TCL_OK) return code;

				// TODO: Make commands dynamic somehow
				Tcl_CreateObjCommand(interp, "parse_response", parse_response, NULL, NULL);
				Tcl_CreateObjCommand(interp, "finalize", finalize, NULL, NULL);

				code = Tcl_PkgProvide(interp, "%name%", "%ver%");

				return code;
			}
			DLLEXPORT int %Name%_Unload(Tcl_Interp* interp, int flags)
			{
				if (flags == TCL_UNLOAD_DETACH_FROM_PROCESS) release(interp);
				return TCL_OK;
			}
		}
	}
}

try {
	$argv0 {*}$argv
} on ok res {
	puts $res
	exit 0
} on error {errmsg options} {
	puts stderr [dict get $options -errorinfo]
	exit 1
}
