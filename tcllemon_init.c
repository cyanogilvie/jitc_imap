#include "tclstuff.h"
#include <tcl.h>

extern int init(Tcl_Interp *interp);
extern void release(Tcl_Interp *interp);
extern OBJCMD(tcllemon);

int Tcllemon_Init(Tcl_Interp *interp)
{
#if USE_TCL_STUBS
	if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) return TCL_ERROR;
#endif

	Tcl_CreateObjCommand(interp, "::tcllemon", tcllemon, NULL, NULL);

	if (Tcl_PkgProvide(interp, "tcllemon", "1.0") != TCL_OK) return TCL_ERROR;

	return init(interp);
}

int Tcllemon_Unload(Tcl_Interp* interp, int flags)
{
	if (flags == TCL_UNLOAD_DETACH_FROM_PROCESS) {
		release(interp);
	}

	return TCL_OK;
}
