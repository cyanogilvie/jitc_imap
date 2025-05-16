TCLSH_PROG = tclsh8.7
TESTLIB = libtcllemon.so
PACKAGE_NAME = tcllemon
PACKAGE_VERSION = 1.0
PKG_LIB_FILE = libtcllemon.so
PACKAGE_LOAD = "source [file join $(shell pwd) test_load_packages.tcl]"
PACKAGE_LOAD_EMBED = source\ [file\ join\ "$(shell pwd)"\ test_load_packages.tcl]
VALGRIND = valgrind
VALGRINDEXTRA =
VALGRINDARGS	= --tool=memcheck --num-callers=8 --leak-resolution=high \
				  --leak-check=yes -v --keep-debuginfo=yes \
				  --error-exitcode=2 $(VALGRINDEXTRA)
srcdir := $(shell pwd)

binaries: $(TESTLIB)

libraries:

$(TESTLIB): tcllemon.c tcllemon_init.c
	gcc -ggdb3 -Wall -Werror -std=c17 -Og -shared -fPIC -o $@ -DUSE_TCL_STUBS=1 $< tcllemon_init.c -ltclstub8.7

test: $(TESTLIB)
	$(TCLSH_ENV) $(PKG_ENV) $(TCLSH_PROG) tests/all.tcl $(TESTFLAGS) -singleproc 1 -load $(PACKAGE_LOAD)

vim-gdb: binaries libraries
	$(TCLSH_ENV) $(PKG_ENV) vim -c "set number" -c "set mouse=a" -c "set foldlevel=100" -c "Termdebug -ex set\ print\ pretty\ on --args $(TCLSH_PROG) tests/all.tcl -singleproc 1 -load $(PACKAGE_LOAD_EMBED) $(TESTFLAGS)" -c "2windo set nonumber" -c "1windo set nonumber"

valgrind: binaries libraries
	$(TCLSH_ENV) $(PKG_ENV) $(VALGRIND) $(VALGRINDARGS) $(TCLSH_PROG) tests/all.tcl $(TESTFLAGS) -load $(PACKAGE_LOAD)

clean:
	-rm -f $(TESTLIB)

tags:
	ctags-exuberant --langmap=c:+.re *

.PHONY: clean test binaries libraries tags vim-gdb valgrind
