%default_type		{ Tcl_Obj* }
%token_type			{ Tcl_Obj* }
%extra_argument		{ struct cx* cx }

%include {

#include "test.h"

#define LEX_STATE_TMP_SIZE 4

// Literals <<<
#define LITS \
	X(NAT_ZERO,		"0") \
	X(NAT_ONE,		"1") \
	X(PLUS,			"+") \
	X(MINUS,		"-") \
	X(MULTIPLY,		"*") \
	X(DIVIDE,		"/") \
	X(LPAREN,		"(") \
	X(RPAREN,		")") \
	X(RATBAR,		"|") \
// Line intentionally left blank

static const char* litstrs[] = {
	#define X(name, str) str,
	LITS
	#undef X
};
enum literals {
	#define X(name, str) L_##name,
	LITS
	#undef X
	L_size
};
static Tcl_Obj* lit[L_size] = {0};
#undef LITS
//>>>

struct cx {
	Tcl_Interp*		interp;
	int				code;
};

INIT { //<<<
	for (int i=0; i<L_size; i++) replace_tclobj(&lit[i], Tcl_NewStringObj(litstrs[i], -1));
	return TCL_OK;
}

//>>>
RELEASE { //<<<
	for (int i=0; i<L_size; i++) replace_tclobj(&lit[i], NULL);
}

//>>>

Tcl_WideInt	n1, n2, d1, d2;

#define interp		cx->interp
#define parser_code	cx->code

#define GETRAT(o, n, d) \
do { \
	Tcl_Obj** ov; \
	int oc; \
	TEST_OK_LABEL(finally, parser_code, Tcl_ListObjGetElements(interp, o, &oc, &ov)); \
	if (oc != 2) THROW_ERROR_LABEL(finally, parser_code, "Bad rat"); \
	TEST_OK_LABEL(finally, parser_code, Tcl_GetWideIntFromObj(interp, ov[0], &n)); \
	TEST_OK_LABEL(finally, parser_code, Tcl_GetWideIntFromObj(interp, ov[1], &d)); \
} while(0)

#define NEWLIST(...) Tcl_NewListObj(sizeof((Tcl_Obj*[]){__VA_ARGS__})/sizeof(Tcl_Obj*), (Tcl_Obj*[]){__VA_ARGS__})

static Tcl_WideInt	gcd(Tcl_WideInt a, Tcl_WideInt b) //<<<
{
	while (b) {
		Tcl_WideInt t = b;
		b = a % b;
		a = t;
	}
	return a;
}

//>>>
static void simplify(Tcl_WideInt* n, Tcl_WideInt* d) //<<<
{
	if (*d < 0) {
		*n = -(*n);
		*d = -(*d);
	}
	if (*n == 0) {
		*d = 1;
	} else {
		const Tcl_WideInt g = gcd(*n, *d);
		if (g != 0) {
			*n /= g;
			*d /= g;
		}
	}
}

//>>>
}

%left PLUS MINUS.
%left MULTIPLY DIVIDE.
%left RATBAR.

topexpr ::= expr(E). {
	Tcl_Obj** ov;
	int oc;
	TEST_OK_LABEL(finally, parser_code, Tcl_ListObjGetElements(interp, E, &oc, &ov));
	if (oc != 2) THROW_ERROR_LABEL(finally, parser_code, "Bad rat");
	Tcl_SetObjResult(interp, Tcl_ObjPrintf("%s|%s",
		Tcl_GetString(ov[0]),
		Tcl_GetString(ov[1])
	));
	parser_code = TCL_OK;
}

expr(O) ::= expr(A) PLUS expr(B).		{
	GETRAT(A, n1, d1);
	GETRAT(B, n2, d2);
	Tcl_WideInt nr = n1 * d2 + n2 * d1;
	Tcl_WideInt nd = d1 * d2;
	simplify(&nr, &nd);
	replace_tclobj(&O, NEWLIST(
		Tcl_NewWideIntObj(nr),
		Tcl_NewWideIntObj(nd)
	));
}
expr(O) ::= expr(A) MINUS expr(B).		{
	GETRAT(A, n1, d1);
	GETRAT(B, n2, d2);
	Tcl_WideInt nr = n1 * d2 - n2 * d1;
	Tcl_WideInt nd = d1 * d2;
	simplify(&nr, &nd);
	replace_tclobj(&O, NEWLIST(
		Tcl_NewWideIntObj(nr),
		Tcl_NewWideIntObj(nd)
	));
}
expr(O) ::= expr(A) MULTIPLY expr(B).	{
	GETRAT(A, n1, d1);
	GETRAT(B, n2, d2);
	Tcl_WideInt nr = n1 * n2;
	Tcl_WideInt nd = d1 * d2;
	simplify(&nr, &nd);
	replace_tclobj(&O, NEWLIST(
		Tcl_NewWideIntObj(nr),
		Tcl_NewWideIntObj(nd)
	));
}
expr(O) ::= expr(A) DIVIDE expr(B).		{
	GETRAT(A, n1, d1);
	GETRAT(B, n2, d2);
	Tcl_WideInt nr = n1 * d2;
	Tcl_WideInt nd = d1 * n2;
	simplify(&nr, &nd);
	replace_tclobj(&O, NEWLIST(
		Tcl_NewWideIntObj(nr),
		Tcl_NewWideIntObj(nd)
	));
}
expr(O) ::= LPAREN expr(E) RPAREN.	{ replace_tclobj(&O, E); }
expr(O) ::= rat(N).					{ replace_tclobj(&O, N); }

rat(O) ::= NAT(N).						{ replace_tclobj(&O, NEWLIST( N, lit[L_NAT_ONE] )); }
rat(O) ::= NAT(N) RATBAR NAT(D).		{ replace_tclobj(&O, NEWLIST( N, D )); }
rat(O) ::= MINUS NAT(N) RATBAR NAT(D).	{
	Tcl_WideInt	numerator;
	TEST_OK_LABEL(finally, parser_code, Tcl_GetWideIntFromObj(interp, N, &numerator));
	replace_tclobj(&O, NEWLIST( Tcl_NewWideIntObj(-numerator), D ));
}


%code {
#undef parser_code
#undef interp

OBJCMD(calc) //<<<
{
	int				code = TCL_OK;
	struct yyParser	p = {0};
	struct cx		cx = { .code = -1 };

	enum {A_cmd, A_EXPR, A_objc};
	CHECK_ARGS_LABEL(finally, code, "expr");

	const char* cur = Tcl_GetString(objv[A_EXPR]);

	Tcl_Preserve(cx.interp = interp);

	ParseInit(&p);

	for (;;) {
		const char* tok = cur;

		#define EMIT(tok, minor) Parse(&p, tok, minor, &cx); if (cx.code >= 0) goto finally

		/*!re2c
			re2c:yyfill:enable		= 0;
			re2c:define:YYCTYPE		= char;
			re2c:define:YYCURSOR	= cur;

			end		= [\x00];
			digit	= [0-9];
			nzdigit	= [1-9];
			zero	= [0];
			nat		= nzdigit digit* | zero;

			end			{ EMIT(0,			NULL);							break; }
			[ \t\n]+	{													continue; }
			"+"			{ EMIT(PLUS,		lit[L_PLUS]);					continue; }
			"-"			{ EMIT(MINUS,		lit[L_MINUS]);					continue; }
			"*"			{ EMIT(MULTIPLY,	lit[L_MULTIPLY]);				continue; }
			"/"			{ EMIT(DIVIDE,		lit[L_DIVIDE]);					continue; }
			"("			{ EMIT(LPAREN,		lit[L_LPAREN]);					continue; }
			")"			{ EMIT(RPAREN,		lit[L_RPAREN]);					continue; }
			"|"			{ EMIT(RATBAR,		lit[L_RATBAR]);					continue; }
			nat			{ EMIT(NAT,			Tcl_NewStringObj(tok, cur-tok));	continue; }

			*  { THROW_ERROR_LABEL(finally, code, "Parse failed"); }
		*/
		#undef EMIT
	}

	THROW_ERROR_LABEL(finally, code, "Ran out of input without a parse accept");

finally:
	ParseFinalize(&p);

	Tcl_Release(cx.interp);
	cx.interp = NULL;

	return code;
}

//>>>

}

// vim: foldmethod=marker foldmarker=<<<,>>> ts=4 shiftwidth=4 noexpandtab
