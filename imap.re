/*!header:re2c:on */ //<<<
#include <stdint.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

void breakpoint() {};

#define YYCONDTYPE parse_conds
/*!conditions:re2c:parse_response */
#undef YYCONDTYPE

// Literals <<<
#define LITS \
	X(EMPTY,				"") \
	X(EMPTYLIST,			"") \
	X(EMPTYDICT,			"") \
	X(TRUE,					"1") \
	X(FALSE,				"0") \
	X(SP,					" ") \
	X(JSON_NULL,			"null") \
	X(JSON_EMPTY_OBJ,		"\x7b\x7d") \
	X(JSON_EMPTY_ARR,		"[]") \
	X(JSON_TRUE,			"true") \
	X(JSON_FALSE,			"false") \
	X(ZERO,					"0") \
	X(MINUSONE,				"-1") \
	X(ZEROSTRING,			"\"\"") \
	X(END_PLUS_ONE,			"end+1") \
	X(MORE_EXCEPTION,			"-code 1 -errorcode IMAP\\ MORE -level 0") \
	X(PARSE_FAILED,				"Parse failed") \
	X(PARSE_FAILED_EXCEPTION,	"-code 1 -errorcode IMAP\\ PARSE_FAILED -level 0") \
	X(STACK_OVERFLOW,			"Parse stack overflow") \
	X(STACK_OVERFLOW_EXCEPTION,	"-code 1 -errorcode IMAP\\ STACK_OVERFLOW -level 0") \
	X(SYNTAX_ERROR,				"Parse syntax error") \
	X(SYNTAX_ERROR_EXCEPTION,	"-code 1 -errorcode IMAP\\ SYNTAX_ERROR -level 0") \
	X(LIST_MAILBOX,			"list_mailbox") \
	X(APPLY,				"apply") \
	X(BUILD_LIST,			"{t val} {string cat ( [join [json lmap e $val {uplevel 1 [list quote $t $e]}]] )}") \
	X(IMAP,					"IMAP") \
	X(TRAILING_INPUT,		"TRAILING_INPUT") \
	X(NONE,					"none") \
	X(UNTAGGED,				"untagged") \
	X(TAGGED,				"tagged") \
	X(FATAL,				"fatal") \
	X(CONTINUE,				"continue") \
	X(PREAUTH,				"PREAUTH") \
	X(BYE,					"BYE") \
	X(OK,					"OK") \
	X(NO,					"NO") \
	X(BAD,					"BAD") \
	X(CAPABILITY,			"CAPABILITY") \
	X(AUTH,					"auth") \
	X(TEXT,					"text") \
	X(TEXT_CODE,			"code") \
	X(ALERT,				"ALERT") \
	X(PARSE,				"PARSE") \
	X(READ_ONLY,			"READ-ONLY") \
	X(READ_WRITE,			"READ-WRITE") \
	X(TRYCREATE,			"TRYCREATE") \
	X(PERMANENTFLAGS,		"PERMANENTFLAGS") \
	X(UIDNEXT,				"UIDNEXT") \
	X(FLAGS,				"FLAGS") \
	X(LIST,					"LIST") \
	X(STATUS,				"STATUS") \
	X(EXISTS,				"EXISTS") \
	X(RECENT,				"RECENT") \
	X(UIDVALIDITY,			"UIDVALIDITY") \
	X(UNSEEN,				"UNSEEN") \
	X(SIZE,					"SIZE") \
	X(ESEARCH,				"ESEARCH") \
	X(EXPUNGE,				"EXPUNGE") \
	X(APPENDUID,			"APPENDUID") \
	X(COPYUID,				"COPYUID") \
	X(YYSTACKEND,			"stacksize") \
	X(YYTOS,				"tos") \
	X(YYHWM,				"hwm") \
	X(YYERRCNT,				"errcnt") \
	X(YYSTACK,				"stack") \
	X(YYSTACK_APPEND,		"stack end+1") \
	X(YYSTACK_STATENO,		"stack end 0") \
	X(YYSTACK_MAJOR,		"stack end 1") \
	X(YYSTACK_MINOR,		"stack end 2") \
	X(CUR_OFS,				"cur_ofs") \
	X(TOK_OFS,				"tok_ofs") \
	X(MAR_OFS,				"mar_ofs") \
	X(LIM_OFS,				"lim_ofs") \
	X(REWIND_OFS,			"rewind_ofs") \
	X(YYCH,					"yych") \
	X(YYACCEPT,				"yyaccept") \
	X(YYSTATE,				"yystate") \
	/*!stags:re2c:parse_response format = "X(@@{tag}_ofs,		\"@@{tag}_ofs\") "; */ \
	X(COND,					"cond") \
	X(P,					"p") \
	X(RESULT,				"result") \
	X(PARSE_EXCEPTION,		"parse_exception") \
	X(BUF,					"buf") \
	X(_,					"_") \
	X(REWIND,				"rewind") \
	X(TOKBUF,				"tokbuf") \
	X(LITLEN,				"litlen") \
	X(LITBIN,				"litbin") \
	X(MESSAGES,				"MESSAGES") \
	X(MAILBOX,				"MAILBOX") \
	X(MSGSEQ,				"msgseq") \
	X(FETCH,				"FETCH") \
	X(MIN,					"MIN") \
	X(MAX,					"MAX") \
	X(ALL,					"ALL") \
	X(COUNT,				"COUNT") \
	X(ASTERISK_JSTR,		"\"*\"") \
	X(DOLLAR_JSTR,			"\"$\"") \
	X(ENVELOPE,				"ENVELOPE") \
	X(INTERNALDATE,			"INTERNALDATE") \
	X(RFC822_SIZE,			"RFC822.SIZE") \
	/* keys used in the state->_ dictionary */ \
	X(_KEY,					"key") \
	/* token literals, for atom fallback handling <<< */ \
	X(TOK_sp,					" ") \
	X(TOK_lparen,				"(") \
	X(TOK_rparen,				")") \
	X(TOK_lbracket,				"[") \
	X(TOK_rbracket,				"]") \
	X(TOK_langle,				"<") \
	X(TOK_rangle,				">") \
	X(TOK_colon,				":") \
	X(TOK_dot,					".") \
	X(TOK_comma,				",") \
	X(TOK_equals,				"=") \
	X(TOK_dollar,				"$") \
	X(TOK_asterisk,				"*") \
	X(TOK_plus,					"+") \
	X(TOK_ALERT,				"ALERT") \
	X(TOK_ALL,					"ALL") \
	X(TOK_ALREADYEXISTS,		"ALREADYEXISTS") \
	X(TOK_APPENDUID,			"APPENDUID") \
	X(TOK_AUTHENTICATIONFAILED,	"AUTHENTICATIONFAILED") \
	X(TOK_AUTHORIZATIONFAILED,	"AUTHORIZATIONFAILED") \
	X(TOK_BAD,					"BAD") \
	X(TOK_BINARY,				"BINARY") \
	X(TOK_BINARY_PEEK,			"BINARY.PEEK") \
	X(TOK_BINARY_SIZE,			"BINARY.SIZE") \
	X(TOK_BODY,					"BODY") \
	X(TOK_BODY_PEEK,			"BODY.PEEK") \
	X(TOK_BODYSTRUCTURE,		"BODYSTRUCTURE") \
	X(TOK_BYE,					"BYE") \
	X(TOK_CANNOT,				"CANNOT") \
	X(TOK_CAPABILITY,			"CAPABILITY") \
	X(TOK_CLIENTBUG,			"CLIENTBUG") \
	X(TOK_CLOSED,				"CLOSED") \
	X(TOK_CONTACTADMIN,			"CONTACTADMIN") \
	X(TOK_COPYUID,				"COPYUID") \
	X(TOK_CORRUPTION,			"CORRUPTION") \
	X(TOK_DELETED,				"DELETED") \
	X(TOK_ENABLED,				"ENABLED") \
	X(TOK_ENVELOPE,				"ENVELOPE") \
	X(TOK_ESEARCH,				"ESEARCH") \
	X(TOK_EXISTS,				"EXISTS") \
	X(TOK_EXPIRED,				"EXPIRED") \
	X(TOK_EXPUNGE,				"EXPUNGE") \
	X(TOK_EXPUNGEISSUED,		"EXPUNGEISSUED") \
	X(TOK_FETCH,				"FETCH") \
	X(TOK_FLAGS,				"FLAGS") \
	X(TOK_HASCHILDREN,			"HASCHILDREN") \
	X(TOK_HEADER_FIELDS,		"HEADER.FIELDS") \
	X(TOK_HEADER_FIELDS_NOT,	"HEADER.FIELDS.NOT")  \
	X(TOK_HEADER,				"HEADER") \
	X(TOK_INTERNALDATE,			"INTERNALDATE") \
	X(TOK_INUSE,				"INUSE") \
	X(TOK_LIMIT,				"LIMIT") \
	X(TOK_LIST,					"LIST") \
	X(TOK_MESSAGES,				"MESSAGES") \
	X(TOK_MIME,					"MIME") \
	X(TOK_NAMESPACE,			"NAMESPACE") \
	X(TOK_NIL,					"NIL") \
	X(TOK_NONEXISTENT,			"NONEXISTENT") \
	X(TOK_NO,					"NO") \
	X(TOK_NOPERM,				"NOPERM") \
	X(TOK_NOTSAVED,				"NOTSAVED") \
	X(TOK_OK,					"OK") \
	X(TOK_OVERQUOTA,			"OVERQUOTA") \
	X(TOK_PARSE,				"PARSE") \
	X(TOK_PERMANENTFLAGS,		"PERMANENTFLAGS") \
	X(TOK_PREAUTH,				"PREAUTH") \
	X(TOK_PRIVACYREQUIRED,		"PRIVACYREQUIRED") \
	X(TOK_READ_ONLY,			"READ-ONLY") \
	X(TOK_READ_WRITE,			"READ-WRITE") \
	X(TOK_RECENT,				"RECENT") \
	X(TOK_RFC822_HEADER,		"RFC822.HEADER") \
	X(TOK_RFC822,				"RFC822") \
	X(TOK_RFC822_SIZE,			"RFC822.SIZE") \
	X(TOK_RFC822_TEXT,			"RFC822.TEXT") \
	X(TOK_SERVERBUG,			"SERVERBUG") \
	X(TOK_SIZE,					"SIZE") \
	X(TOK_STATUS,				"STATUS") \
	X(TOK_TAG,					"TAG") \
	X(TOK_TRYCREATE,			"TRYCREATE") \
	X(TOK_UIDNEXT,				"UIDNEXT") \
	X(TOK_UIDNOTSTICKY,			"UIDNOTSTICKY") \
	X(TOK_UID,					"UID") \
	X(TOK_UIDVALIDITY,			"UIDVALIDITY") \
	X(TOK_UNAVAILABLE,			"UNAVAILABLE") \
	X(TOK_UNKNOWN_CTE,			"UNKNOWN-CTE") \
	X(TOK_UNSEEN,				"UNSEEN") \
	\
	X(TOK_X_GM_MSGID,			"X-GM-MSGID") \
	X(TOK_X_GM_LABELS,			"X-GM-LABELS") \
	X(TOK_MODSEQ,				"MODSEQ") \
	/* token literals, for atom fallback handling >>> */ \
// Line intentionally left blank
//@end=c@@begin=c@

enum literals {
	#define X(name, str) L_##name,
	LITS
	#undef X
	L_size
};
//@end=c@@begin=c@
static const char* litstr[L_size] = {
	#define X(name, str) str,
	LITS
	#undef X
};
static Tcl_Obj* lit[L_size] = {0};
#undef LITS
//>>>

struct lex_state {
	ptrdiff_t				cur_ofs;
	ptrdiff_t				tok_ofs;
	ptrdiff_t				mar_ofs;
	ptrdiff_t				lim_ofs;
	ptrdiff_t				rewind_ofs;
	uint8_t					yych;
	uint32_t				yyaccept;
	int						yystate;
/*!stags:re2c:parse_response format = "\t\tptrdiff_t			@@{tag}_ofs;\n";*/
	enum parse_conds		cond;
	struct yyParser			p;
	Tcl_Obj*				buf;
	Tcl_DString				tokbuf;
	size_t					litlen;
	int						litbin;
	Tcl_Obj*				_;			// dictionary for working memory between grammar actions
	// Ephemeral state:
	int						code;
	Tcl_Interp*				interp;
	int						harvest;	// bool: true if the parser should return the result in the interp
	int						rewind;		// bool: true will step the input back to the beginning of the current token and reset this flag
};

// Intrep tracking <<<
struct ll_intreps {
	struct ll_intreps*	next;
	struct ll_intreps*	prev;
	Tcl_Obj*			obj;
};
static Tcl_HashTable	g_intreps;
struct ll_intreps		ll_intreps_head = {0};
struct ll_intreps		ll_intreps_tail = {0};

static void register_intrep(Tcl_Obj* obj) //<<<
{
	Tcl_HashEntry*	he = NULL;
	int				new = 0;
	struct ll_intreps*	lle = NULL;

	lle = ckalloc(sizeof(*lle));
	*lle = (struct ll_intreps){
		.prev	= ll_intreps_tail.prev,
		.next	= &ll_intreps_tail,
		.obj	= obj,
	};
	ll_intreps_tail.prev->next	= lle;
	ll_intreps_tail.prev		= lle;
	he = Tcl_CreateHashEntry(&g_intreps, obj, &new);
	if (!new) Tcl_Panic("register_intrep: already registered");
	Tcl_SetHashValue(he, lle);
	//fprintf(stderr, "** Registered intrep %p\n", obj);
}

//>>>
void forget_intrep(Tcl_Obj* obj) //<<<
{
	Tcl_HashEntry*		he = Tcl_FindHashEntry(&g_intreps, obj);
	//fprintf(stderr, "** Forget intrep %p, exists: %p\n", obj, he);
	if (!he) Tcl_Panic("forget_intrep: not registered");
	struct ll_intreps*	lle = Tcl_GetHashValue(he);
	lle->prev->next = lle->next;
	lle->next->prev = lle->prev;
	Tcl_DeleteHashEntry(he);
	ckfree(lle);
	lle = NULL;
}

//>>>
// Intrep tracking >>>

static dedup_pool*	dpool = NULL;
//#define Dedup_NewStringObj(p, b, l) Tcl_NewStringObj((const char*)(b), (l))

#define LEX_STATE_TMP_SIZE		4

// action rule helpers <<<
struct lex_state;

static void parse_result(struct lex_state* state, Tcl_Obj* result);
static void throw_parse_exception(struct lex_state* state, Tcl_Obj* options, Tcl_Obj* result);
static int parse_take(struct lex_state* state, Tcl_Obj* key, Tcl_Obj** into);

// It's metaprogramming all the way down
static inline Tcl_Obj* _strobj_use_lit(enum literals s) {return lit[s];}
static inline Tcl_Obj* _strobj_use_Tcl_Obj(Tcl_Obj* s) {return s;}
static inline Tcl_Obj* _strobj_use_str(const char* s) {return Dedup_NewStringObj(dpool, s, -1);}
static inline Tcl_Obj* _strobj_use_voidptr(void* s) {if(s) Tcl_Panic("STROBJ given non-NULL void*"); return NULL;}
static inline Tcl_Obj* _jval_use_str(const char* s) {return JSON_NewJvalObj(JSON_STRING, Dedup_NewStringObj(dpool, s, -1));}
static inline Tcl_Obj* _jval_use_voidptr(void* s) {if(s) Tcl_Panic("JVAL given non-NULL void*"); return lit[L_JSON_NULL];}

#define STROBJ(s) _Generic((s), \
    enum literals: _strobj_use_lit, \
              int: _strobj_use_lit, \
         Tcl_Obj*: _strobj_use_Tcl_Obj, \
            char*: _strobj_use_str, \
      const char*: _strobj_use_str, \
            void*: _strobj_use_voidptr \
)(s)
#define JSTR(s)					JSON_NewJvalObj(JSON_STRING, STROBJ(s))
#define JVAL(s) _Generic((s), \
    enum literals: _strobj_use_lit, \
              int: _strobj_use_lit, \
         Tcl_Obj*: _strobj_use_Tcl_Obj, \
            char*: _jval_use_str, \
      const char*: _jval_use_str, \
            void*: _jval_use_voidptr \
)(s)

#define STASH(k, v)				TEST_OK_LABEL(finally, code, Tcl_DictObjPut(state->interp, state->_, STROBJ(k), STROBJ(v)))
#define STASHF(k, f, ...)		TEST_OK_LABEL(finally, code, Tcl_DictObjPut(state->interp, state->_, STROBJ(k), Tcl_ObjPrintf(f, ##__VA_ARGS__)))
#define TAKE(k, into) \
do { \
	Tcl_Obj* keyObj = NULL; \
	replace_tclobj(&keyObj, STROBJ(k)); \
	code = parse_take(state, keyObj, &(into)); \
	replace_tclobj(&keyObj, NULL); \
	if (code != TCL_OK) goto finally; \
} while(0)
#define MOVE(from, to)			replace_tclobj(&to, from); replace_tclobj(&from, NULL)
#define UNSHARE(o)				if (o && Tcl_IsShared(o)) replace_tclobj(&o, Tcl_DuplicateObj(o))
#define SET(o, v)				replace_tclobj(&o, STROBJ(v))
#define SETF(o, f, ...)			replace_tclobj(&o, Tcl_ObjPrintf(f, ##__VA_ARGS__))
#define JSON_SET(target, path, v) \
do { \
	Tcl_Obj** objPtr = &(target); \
	Tcl_Obj* pathObj = NULL; \
	if (!*objPtr)					{ TEST_OK_LABEL(finally, code, JSON_NewJObjectObj(state->interp, objPtr)); } \
	else if (Tcl_IsShared(*objPtr))	{ replace_tclobj(objPtr, Tcl_DuplicateObj(*objPtr)); } \
	replace_tclobj(&pathObj, STROBJ(path)); \
	code = JSON_Set(state->interp, *objPtr, pathObj, JVAL(v)); \
	replace_tclobj(&pathObj, NULL); \
	if (code != TCL_OK) goto finally; \
} while(0)
#define SET_JSON_ARR(a, ...)	TEST_OK_LABEL(finally, code, JSON_NewJArrayObj(state->interp, sizeof((Tcl_Obj*[]){__VA_ARGS__})/sizeof(Tcl_Obj*), (Tcl_Obj*[]){__VA_ARGS__}, &(a)))
#define SET_JSON_OBJ(o, ...) \
do { \
	Tcl_Obj* ov[] = {__VA_ARGS__}; \
	const size_t l = sizeof(ov)/sizeof(ov[0]); \
	if (l&1) THROW_PRINTF_LABEL(finally, code, "Must have an even number of arguments"); \
	Tcl_Obj** objPtr = &(o); \
	if (!*objPtr)					TEST_OK_LABEL(finally, code, JSON_NewJObjectObj(state->interp, objPtr)); \
	else if (Tcl_IsShared(*objPtr))	replace_tclobj(objPtr, Tcl_DuplicateObj(*objPtr)); \
	for (size_t i=0; i<l; i+=2) TEST_OK_LABEL(finally, code, JSON_Set(state->interp, *objPtr, ov[i], ov[i+1])); \
}
#define TCLLIST(...) Tcl_NewListObj(sizeof((Tcl_Obj*[]){__VA_ARGS__})/sizeof(Tcl_Obj*), (Tcl_Obj*[]){__VA_ARGS__})

//>>>
/*!header:re2c:off */ //>>>

// Common rules <<<
/*!rules:re2c:common
	re2c:api:style			= free-form;
	re2c:define:YYCTYPE		= uint8_t;
	re2c:define:YYCURSOR	= "cur";
	re2c:define:YYLIMIT		= "lim";
	re2c:define:YYMARKER	= "mar";
	re2c:define:YYGETCOND	= "state->cond";
	re2c:define:YYSETCOND	= "state->cond = @@;";
	re2c:define:YYSETSTATE	= "state->yystate = @@;";
	re2c:define:YYGETSTATE	= "state->yystate";
	re2c:define:YYSTAGP		= "@@ = cur;";
	re2c:define:YYSTAGN		= "@@ = NULL;";
	re2c:tags:expression	= "@@";
	re2c:tags				= 1;

	end				= [\x00];
	SP				= [\x20];
	CR				= [\r];
	LF				= [\n];
	CRLF			= CR LF;
	BS				= [\x5c];
	CTL				= [\x00-\x1f\x7f];
	DQUOTE			= [\x22];
	LBRACE			= [\x7b];	// left brace
	RBRACE			= [\x7d];	// right brace
	DIGIT			= [0-9];
	ALPHA			= [A-Za-z];
	quoted_specials	= DQUOTE | BS;
	resp_specials	= [\x5d];		// right square bracket
	list_wildcards	= [%*];
	atom_specials	= [()] | LBRACE | SP | CTL | list_wildcards | quoted_specials | resp_specials;
	UTF8_tail		= [\x80-\xbf];
	UTF8_2			= [\xc2-\xdf] UTF8_tail;
	UTF8_3
		= [\xe0]      [\xa0-\xbf] UTF8_tail
		| [\xe1-\xec]             UTF8_tail{2}
		| [\xed]      [\x80-\x9f] UTF8_tail
		| [\xee-\xef]             UTF8_tail{2}
		;
	UTF8_4
		= [\xf0]      [\x90-\xbf] UTF8_tail{2}
		| [\xf1-\xf3]             UTF8_tail{3}
		| [\xf4]      [\x80-\x8f] UTF8_tail{2}
		;
	CHAR			= [\x01-\x7f];
	CHAR8			= [\x01-\xff];
	OCTET			= [\x00-\xff];
	TEXT_CHAR		= CHAR \ CR \ LF;
	QUOTED_CHAR
		= TEXT_CHAR \ quoted_specials
		| BS quoted_specials
		| UTF8_2
		| UTF8_3
		| UTF8_4
		;
	quote_safe_char
		= TEXT_CHAR \ quoted_specials
		| UTF8_2
		| UTF8_3
		| UTF8_4
		;
	ATOM_CHAR		= [^] \ atom_specials;
	astring_char	= ATOM_CHAR | resp_specials;
	quoted			= DQUOTE QUOTED_CHAR* DQUOTE;
	number			= [0-9]+;
	nz_number		= [1-9] [0-9]*;
	literal			= LBRACE number "+"? RBRACE CRLF;	// followed by number CHAR8s
	string			= quoted | literal;
	astring			= astring_char+ | string;
	text			= (TEXT_CHAR | UTF8_2 | UTF8_3 | UTF8_4)+;
	atom			= (ATOM_CHAR \ "[")+;		// Different to ABNF spec to prevent longest-match-wins from breaking resp_text_code grammar (grammar reconstructs atom with lbrackets as a fallback)
*/
//>>>

// lex_state intrep <<<
static struct lex_state* alloc_lex_state() //<<<
{
	struct lex_state*	state = ckalloc(sizeof(*state));
	*state = (struct lex_state){
		.yystate	= -1,
		.cond		= yycplain,
	};
	parse_response_tokInit(&state->p);
	Tcl_DStringInit(&state->tokbuf);
	replace_tclobj(&state->buf, Tcl_NewByteArrayObj(NULL, 65536));
	Tcl_SetByteArrayObj(state->buf, (const uint8_t*)"\0", 1);	// sentinel
	replace_tclobj(&state->_, Tcl_NewDictObj());
	return state;
}

//>>>
static void free_lex_state(struct lex_state* state) //<<<
{
	if (state) {
		parse_response_tokFinalize(&state->p);
		if (state->interp) {
			Tcl_Release(state->interp);
			state->interp = NULL;
		}
		Tcl_DStringFree(&state->tokbuf);
		replace_tclobj(&state->buf,				NULL);
		replace_tclobj(&state->_,				NULL);

		ckfree(state);
		state = NULL;
	}
}

//>>>

static void free_lex_state_intrep(Tcl_Obj* obj);
static void dup_lex_state_intrep(Tcl_Obj* src, Tcl_Obj* dst);
static void update_lex_state_string_rep(Tcl_Obj* obj);

static Tcl_ObjType lex_state_type = {
	.name				= "imap_lex_state",
	.freeIntRepProc		= free_lex_state_intrep,
	.dupIntRepProc		= dup_lex_state_intrep,
	.updateStringProc	= update_lex_state_string_rep,
};

static void free_lex_state_intrep(Tcl_Obj* obj) //<<<
{
	Tcl_ObjInternalRep*	ir = Tcl_FetchInternalRep(obj, &lex_state_type);
	forget_intrep(obj);
	free_lex_state((struct lex_state*)ir->twoPtrValue.ptr1);
}

//>>>
static void dup_lex_state_intrep(Tcl_Obj* src, Tcl_Obj* dst) //<<<
{
	Tcl_ObjInternalRep*	ir = Tcl_FetchInternalRep(src, &lex_state_type);

	struct lex_state*	srcstate = ir->twoPtrValue.ptr1;
	struct lex_state*	dststate = ckalloc(sizeof(*dststate));

	memcpy(dststate, srcstate, sizeof(*dststate));

	if (dststate->interp) Tcl_Preserve(dststate->interp);
	if (srcstate->p.yystack == srcstate->p.yystk0) {
		dststate->p.yystack = dststate->p.yystk0;
	} else {
		const int copysize = sizeof(dststate->p.yystack[0]) * (srcstate->p.yystackEnd - srcstate->p.yystack);
		dststate->p.yystack = ckalloc(copysize);
		memcpy(dststate->p.yystack, srcstate->p.yystack, copysize);
	}

	dststate->p.yytos		= dststate->p.yystack + (srcstate->p.yytos      - srcstate->p.yystack);
	dststate->p.yystackEnd	= dststate->p.yystack + (srcstate->p.yystackEnd - srcstate->p.yystack);

	for (yyStackEntry* e=dststate->p.yystack; e < dststate->p.yystackEnd; e++)
		if (e->minor.yy0) 
			Tcl_IncrRefCount((Tcl_Obj*)e->minor.yy0);

	if (dststate->buf)				Tcl_IncrRefCount(dststate->buf);
	if (dststate->_)				Tcl_IncrRefCount(dststate->_);

	Tcl_DStringInit(&dststate->tokbuf);
	Tcl_DStringAppend(&dststate->tokbuf, Tcl_DStringValue(&srcstate->tokbuf), Tcl_DStringLength(&srcstate->tokbuf));

	Tcl_StoreInternalRep(dst, &lex_state_type, &(Tcl_ObjInternalRep){.twoPtrValue.ptr1 = dststate});
	register_intrep(dst);
}

//>>>
static void store_ptrdiff_t		(void* dest, Tcl_WideInt val) {        *(ptrdiff_t*)dest = val; }
static void store_int			(void* dest, Tcl_WideInt val) {              *(int*)dest = val; }
static void store_uint8_t		(void* dest, Tcl_WideInt val) {          *(uint8_t*)dest = val; }
static void store_uint32_t		(void* dest, Tcl_WideInt val) {         *(uint32_t*)dest = val; }
static void store_size_t		(void* dest, Tcl_WideInt val) {           *(size_t*)dest = val; }
static void store_parse_conds	(void* dest, Tcl_WideInt val) { *(enum parse_conds*)dest = val; }
static void store_nop			(void* dest, Tcl_WideInt val) { /* nop */ }

#define LEX_STATE_KEYS \
	X(cur_ofs,			KT_NUM,			ptrdiff_t,			cur_ofs) \
	X(tok_ofs,			KT_NUM,			ptrdiff_t,			tok_ofs) \
	X(mar_ofs,			KT_NUM,			ptrdiff_t,			mar_ofs) \
	X(lim_ofs,			KT_NUM,			ptrdiff_t,			lim_ofs) \
	X(rewind_ofs,		KT_NUM,			ptrdiff_t,			rewind_ofs) \
	X(yych,				KT_NUM,			uint8_t,			yych) \
	X(yyaccept,			KT_NUM,			uint32_t,			yyaccept) \
	X(yystate,			KT_NUM,			int,				yystate) \
	X(cond,				KT_NUM,			parse_conds,		cond) \
	X(litlen,			KT_NUM,			size_t,				litlen) \
	X(litbin,			KT_BOOL,		int,				litbin) \
	X(_,				KT_OBJDICT,		nop,				_) \
	X(buf,				KT_BUF,			nop,				buf) \
	X(tokbuf,			KT_DSTRING,		nop,				tokbuf) \
	X(p,				KT_PARSERSTATE,	nop,				p) \
	/*!stags:re2c:parse_response format = "X(@@{tag}_ofs,			KT_NUM,		ptrdiff_t,	@@{tag}_ofs) \\\n"; */ \
// Line intentionally left blank

static int deserialise_parser_state(Tcl_Interp* interp, Tcl_Obj* obj, struct yyParser* p) //<<<
{
	int					code = TCL_OK;
	Tcl_Obj*			tmp = NULL;
	Tcl_WideInt			tmpwide;

	enum json_types	type;
	TEST_OK_LABEL(finally, code, JSON_Type(interp, obj, NULL, &type));
	if (type != JSON_OBJECT) THROW_ERROR_LABEL(finally, code, "Expected parser state");

	// yystackEnd - find the size of the stack
	TEST_OK_LABEL(finally, code, JSON_Get(interp, obj, lit[L_YYSTACKEND], &tmp));
	TEST_OK_LABEL(finally, code, Tcl_GetWideIntFromObj(interp, tmp, &tmpwide));
	p->yystack = p->yystk0;
	p->yystackEnd = p->yystack + YYSTACKDEPTH-1;
	if (tmpwide - 1 > p->yystackEnd - p->yystack) {
		while (tmpwide > p->yystackEnd - p->yystack) {
			// Prevent errors with the REALLOC attempting to copy unallocated memory
			p->yytos = p->yystack;
			if (yyGrowStack(p))
				THROW_PRINTF_LABEL(finally, code, "Could not grow stack, parser has: %d, requires %llu", YYSTACKDEPTH, tmpwide);
		}
	}

	// yytos
	TEST_OK_LABEL(finally, code, JSON_Get(interp, obj, lit[L_YYTOS], &tmp));
	TEST_OK_LABEL(finally, code, Tcl_GetWideIntFromObj(interp, tmp, &tmpwide));
	p->yytos = p->yystack + tmpwide;

	#ifdef YYTRACKMAXSTACKDEPTH
	// yymaxdepth
	TEST_OK_LABEL(finally, code, JSON_Get(interp, obj, lit[L_YYHWM], &tmp));
	TEST_OK_LABEL(finally, code, Tcl_GetWideIntFromObj(interp, tmp, &tmpwide));
	p->yyhwm = tmpwide;
	#endif
	#ifndef YYNOERRORRECOVERY
	// yyerrcnt
	TEST_OK_LABEL(finally, code, JSON_Get(interp, obj, lit[L_YYERRCNT], &tmp));
	TEST_OK_LABEL(finally, code, Tcl_GetWideIntFromObj(interp, tmp, &tmpwide));
	p->yyerrcnt = tmpwide;
	#endif

	int			sc;
	Tcl_Obj**	sv = NULL;
	TEST_OK_LABEL(finally, code, JSON_Get(interp, obj, lit[L_YYSTACK], &tmp));
	TEST_OK_LABEL(finally, code, Tcl_ListObjGetElements(interp, tmp, &sc, &sv));
	for (int i=0; i<sc; i++) {
		enum {
			YYSTACK_STATENO,
			YYSTACK_MAJOR,
			YYSTACK_MINOR,
			YYSTACK_size
		};
		int			ec;
		Tcl_Obj**	ev = NULL;
		TEST_OK_LABEL(finally, code, Tcl_ListObjGetElements(interp, sv[i], &ec, &ev));
		if (ec != YYSTACK_size) THROW_PRINTF_LABEL(finally, code, "Invalid yystack entry %d", i);

		// yystack[i].stateno
		TEST_OK_LABEL(finally, code, Tcl_GetWideIntFromObj(interp, ev[YYSTACK_STATENO], &tmpwide));
		p->yystack[i].stateno = tmpwide;

		// yystack[i].major
		TEST_OK_LABEL(finally, code, Tcl_GetWideIntFromObj(interp, ev[YYSTACK_MAJOR], &tmpwide));
		p->yystack[i].major = tmpwide;

		// yystack[i].minor		- bakes in the assumption that all minor types are Tcl_Obj*
		Tcl_IncrRefCount(p->yystack[i].minor.yy0 = ev[YYSTACK_MINOR]);
	}

finally:
	replace_tclobj(&tmp, NULL);
	return code;
}

//>>>
static int serialize_parser_state(Tcl_Interp* interp, struct yyParser* p, Tcl_Obj** objPtr) //<<<
{
	int					code = TCL_OK;
	Tcl_Obj*			obj = NULL;
	Tcl_Obj*			stackentry = NULL;
	Tcl_Obj*			jstr = NULL;
	Tcl_Obj*			stack = NULL;

	replace_tclobj(&obj, Tcl_DuplicateObj(lit[L_JSON_EMPTY_OBJ]));

	TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYSTACKEND],	Tcl_NewWideIntObj(p->yystackEnd - p->yystack + 1)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYTOS],		Tcl_NewWideIntObj(p->yytos - p->yystack)));
	#ifdef YYTRACKMAXSTACKDEPTH
	TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYHWM],		Tcl_NewWideIntObj(p->yyhwm)));
	#endif
	#ifndef YYNOERRORRECOVERY
	TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYERRCNT],		Tcl_NewWideIntObj(p->yyerrcnt)));
	#endif

	TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYSTACK],		lit[L_JSON_EMPTY_ARR]));
	const int	sc = p->yytos - p->yystack;
	for (int i=0; i<sc; i++) {

		TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYSTACK_APPEND],	lit[L_JSON_EMPTY_ARR]));
		TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYSTACK_STATENO],	Tcl_NewWideIntObj(p->yystack[i].stateno)));
		TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYSTACK_MAJOR],	Tcl_NewWideIntObj(p->yystack[i].major)));
		if (p->yystack[i].minor.yy0) {
			TEST_OK_LABEL(finally, code, JSON_NewJStringObj(interp, p->yystack[i].minor.yy0, &jstr));
		} else {
			replace_tclobj(&jstr, lit[L_JSON_NULL]);
		}
		TEST_OK_LABEL(finally, code, JSON_Set(interp, obj, lit[L_YYSTACK_MINOR],	jstr));
	}

	replace_tclobj(objPtr, obj);

finally:
	replace_tclobj(&obj,		NULL);
	replace_tclobj(&stackentry,	NULL);
	replace_tclobj(&jstr,		NULL);
	replace_tclobj(&stack,		NULL);
	return code;
}

//>>>
static void update_lex_state_string_rep(Tcl_Obj* obj) //<<<
{
	int					code = TCL_OK;
	Tcl_ObjInternalRep*	ir = Tcl_FetchInternalRep(obj, &lex_state_type);
	struct lex_state*	state = ir->twoPtrValue.ptr1;
	Tcl_Obj*			s = NULL;
	Tcl_Obj*			tmp = NULL;
	Tcl_Interp*			interp = state->interp;	// Could be NULL (likely)

	replace_tclobj(&s, Tcl_DuplicateObj(lit[L_JSON_EMPTY_OBJ]));

	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_CUR_OFS],	Tcl_NewWideIntObj(state->cur_ofs)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_TOK_OFS],	Tcl_NewWideIntObj(state->tok_ofs)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_MAR_OFS],	Tcl_NewWideIntObj(state->mar_ofs)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_LIM_OFS],	Tcl_NewWideIntObj(state->lim_ofs)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_REWIND_OFS],	Tcl_NewWideIntObj(state->rewind_ofs)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_YYCH],		Tcl_NewIntObj(state->yych)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_YYACCEPT],	Tcl_NewWideIntObj(state->yyaccept)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_YYSTATE],	Tcl_NewIntObj(state->yystate)));
/*!stags:re2c:parse_response format = "\t\tTEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_@@{tag}_ofs],	Tcl_NewWideIntObj(state->@@{tag}_ofs)));\n"; */
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_COND],		Tcl_NewWideIntObj(state->cond)));

	TEST_OK_LABEL(finally, code, serialize_parser_state(interp, &state->p,	&tmp));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_P],				tmp));
	if (state->buf) {
		TEST_OK_LABEL(finally, code, JSON_NewJStringObj(interp, state->buf,	&tmp));
		TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_BUF],		tmp));
	}
	if (state->_) {
		Tcl_DictSearch	search;
		Tcl_Obj			*k, *v;
		int				done;

		replace_tclobj(&tmp, lit[L_JSON_EMPTY_OBJ]);
		TEST_OK_LABEL(dict_search_done, code, Tcl_DictObjFirst(interp, state->_, &search, &k, &v, &done));
		for (; !done; Tcl_DictObjNext(&search, &k, &v, &done)) {
			if (Tcl_IsShared(tmp)) replace_tclobj(&tmp, Tcl_DuplicateObj(tmp));
			TEST_OK_LABEL(finally, code, JSON_Set(interp, tmp, k, v));
		}
	dict_search_done:
		Tcl_DictObjDone(&search);
		if (code != TCL_OK) goto finally;

		TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L__], tmp));
	}

	if (Tcl_DStringLength(&state->tokbuf) > 0)
		TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_TOKBUF],
			Tcl_NewStringObj(Tcl_DStringValue(&state->tokbuf), Tcl_DStringLength(&state->tokbuf))));

	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_LITLEN],		Tcl_NewWideIntObj(state->litlen)));
	TEST_OK_LABEL(finally, code, JSON_Set(interp, s, lit[L_LITBIN],		Tcl_NewBooleanObj(state->litbin)));

	int	slen;
	const char*	str = Tcl_GetStringFromObj(s, &slen);
	Tcl_InitStringRep(obj, str, slen);

finally:
	replace_tclobj(&tmp,	NULL);
	replace_tclobj(&s,		NULL);
	if (code != TCL_OK) {
		if (interp)	Tcl_BackgroundException(interp, code);
		else		Tcl_Panic("update_lex_state_string_rep");
	}
}

//>>>
static int IMAP_GetLexStateFromObj(Tcl_Interp* interp, Tcl_Obj* obj, struct lex_state** statePtr) //<<<
{
	int					code = TCL_OK;
	Tcl_ObjInternalRep*	ir = Tcl_FetchInternalRep(obj, &lex_state_type);
	struct lex_state*	state = NULL;
	Tcl_Obj*			tmp = NULL;
	Tcl_Obj*			tmp2 = NULL;
	Tcl_Obj*			val = NULL;

	if (!ir) {
		state = alloc_lex_state();

		enum json_types	type;
		TEST_OK_LABEL(finally, code, JSON_Type(interp, obj, NULL, &type));
		if (type != JSON_OBJECT)
			THROW_ERROR_LABEL(finally, code, "Expected lex state");

		int			tmpint;
		Tcl_WideInt	tmpwide;
		const char*	tmpstr = NULL;
		int			kc;
		Tcl_Obj**	kv = NULL;

		TEST_OK_LABEL(finally, code, JSON_Keys(interp, obj, NULL, &tmp));
		TEST_OK_LABEL(finally, code, Tcl_ListObjGetElements(interp, tmp, &kc, &kv));
		for (int i=0; i<kc; i++) {
			static const char* keys[] = {
				#define X(name, type, ctype, dest) #name,
				LEX_STATE_KEYS
				#undef X
				NULL
			};
			enum key {
				#define X(name, type, ctype, dest) K_##name,
				LEX_STATE_KEYS
				#undef X
			} key;
			static enum keytypes {
				KT_NUM,
				KT_BOOL,
				KT_STRING,
				KT_BUF,
				KT_DSTRING,
				KT_PARSERSTATE,
				KT_OBJDICT,
			} keytype[] = {
				#define X(name, type, ctype, dest) type,
				LEX_STATE_KEYS
				#undef X
			};
			void* dest[] = {
				#define X(name, type, ctype, dest) &state->dest,
				LEX_STATE_KEYS
				#undef X
			};
			#undef KEYS
			typedef void (*setter)(void*, Tcl_WideInt);
			static setter setters[] = {
				#define X(name, type, ctype, dest) store_##ctype,
				LEX_STATE_KEYS
				#undef X
			};
			int key_idx;

			TEST_OK_LABEL(finally, code, Tcl_GetIndexFromObj(interp, kv[i], keys, "key", TCL_EXACT, &key_idx)); key = key_idx;
			TEST_OK_LABEL(finally, code, JSON_Get(interp, obj, kv[i], &val));

			switch (keytype[key]) {
				case KT_NUM:
					TEST_OK_LABEL(finally, code, Tcl_GetWideIntFromObj(interp, val, &tmpwide));
					setters[key](dest[key], tmpwide);
					break;

				case KT_BOOL:
					TEST_OK_LABEL(finally, code, Tcl_GetBooleanFromObj(interp, val, &tmpint));
					setters[key](dest[key], tmpint);
					break;

				case KT_STRING:
					replace_tclobj(dest[key], val);
					break;

				case KT_BUF:
				{
					int				len;
					const uint8_t*	bytes = Tcl_GetBytesFromObj(interp, val, &len);
					if (bytes == NULL) THROW_ERROR_LABEL(finally, code, "buf is not a bytearray");
					if (len < 1 || bytes[len-1] != 0) THROW_ERROR_LABEL(finally, code, "buf lacks sentinel");
					replace_tclobj(dest[key], val);
					break;
				}

				case KT_DSTRING:
					tmpstr = Tcl_GetStringFromObj(val, &tmpint);
					Tcl_DStringAppend(dest[key], tmpstr, tmpint);
					break;

				case KT_PARSERSTATE:
					TEST_OK_LABEL(finally, code, JSON_Extract(interp, obj, kv[i], &val));
					TEST_OK_LABEL(finally, code, deserialise_parser_state(interp, val, &state->p));
					break;

				case KT_OBJDICT:
				{
					int			subc;
					Tcl_Obj**	subv;

					TEST_OK_LABEL(finally, code, JSON_Extract(interp, obj, kv[i], &val));
					TEST_OK_LABEL(finally, code, JSON_Keys(interp, obj, val, &tmp));
					TEST_OK_LABEL(finally, code, Tcl_ListObjGetElements(interp, tmp, &subc, &subv));

					for (int subi=0; subi<subc; subi++) {
						TEST_OK_LABEL(finally, code, JSON_Extract(interp, val, subv[subi], &tmp2));
						TEST_OK_LABEL(finally, code, Tcl_DictObjPut(interp, state->_, subv[subi], tmp2));
					}
					break;
				}

				default:
					THROW_PRINTF_LABEL(finally, code, "Invalid key: \"%s\"", Tcl_GetString(kv[i]));
			}
		}

		Tcl_StoreInternalRep(obj, &lex_state_type, &(Tcl_ObjInternalRep){.twoPtrValue.ptr1 = state});
		state = NULL;
		register_intrep(obj);
		ir = Tcl_FetchInternalRep(obj, &lex_state_type);
	}

	*statePtr = ir->twoPtrValue.ptr1;

finally:
	replace_tclobj(&tmp, NULL);
	replace_tclobj(&tmp2, NULL);
	replace_tclobj(&val, NULL);
	if (state) {
		free_lex_state(state);
		state = NULL;
	}
	return code;
}

//>>>
#undef LEX_STATE_KEYS
static Tcl_Obj* IMAP_NewLexStateObj(Tcl_Interp* interp, struct lex_state* state) //<<<
{
	Tcl_Obj*	obj = Tcl_NewObj();
	Tcl_StoreInternalRep(obj, &lex_state_type, &(Tcl_ObjInternalRep){.twoPtrValue.ptr1 = state});
	register_intrep(obj);
	return obj;
}

//>>>
// lex_state intrep >>>

static void throw_parse_exception(struct lex_state* state, Tcl_Obj* options, Tcl_Obj* result) //<<<
{
	if (TCL_OK != Tcl_SetReturnOptions(state->interp, options)) Tcl_BackgroundException(state->interp, TCL_ERROR);
	Tcl_SetObjResult(state->interp, result);
	state->code = TCL_ERROR;
}

//>>>
static int parse_take(struct lex_state* state, Tcl_Obj* key, Tcl_Obj** into) // Pop key out of state->_ <<<
{
	int			code = TCL_OK;
	Tcl_Obj*	borrowed = NULL;

	TEST_OK_LABEL(finally, code, Tcl_DictObjGet(state->interp, state->_, key, &borrowed));
	replace_tclobj(into, borrowed);
	TEST_OK_LABEL(finally, code, Tcl_DictObjRemove(state->interp, state->_, key));

finally:
	return code;
}

//>>>

char* trace_prefix = NULL;

INIT { //<<<
	ll_intreps_head.next = &ll_intreps_tail;
	ll_intreps_tail.prev = &ll_intreps_head;
	Tcl_InitHashTable(&g_intreps, TCL_ONE_WORD_KEYS);
	dpool = Dedup_NewPool(interp);
	for (int i=0; i<L_size; i++) replace_tclobj(&lit[i], Tcl_NewStringObj(litstr[i], -1));
	return TCL_OK;
}
//@end=c@@begin=c@
//>>>
RELEASE { //<<<
	Dedup_FreePool(dpool);	dpool = NULL;
	for (int i=0; i<L_size; i++) replace_tclobj(&lit[i], NULL);

	// Since new entries are added to the tail of the list, we can just walk
	// the list and free all the entries - any new entries added during this
	// process will be processed before reaching the end.  Can't use lle->next
	// (even saved) since the Tcl_FreeInternalRep handler could have freed the
	// corresponding object too.
	for (struct ll_intreps* lle = ll_intreps_head.next; lle->next; lle = ll_intreps_head.next) {
		Tcl_GetString(lle->obj);
		Tcl_FreeInternalRep(lle->obj);	// Calls Tcl_DeleteHashEntry on this entry and unlinks lle, frees it
	}
	if (
			ll_intreps_head.next != &ll_intreps_tail ||
			ll_intreps_tail.prev != &ll_intreps_head
	) Tcl_Panic("ll_intreps_head->next != ll_intreps_tail");
	Tcl_DeleteHashTable(&g_intreps);

	if (trace_prefix) {
		ckfree(trace_prefix);
		trace_prefix = NULL;
	}
}

//>>>

OBJCMD(parse_response) //<<<
{
	int					code = TCL_OK;
	Tcl_Obj*			stateobj = NULL;
	struct lex_state	*state = NULL;
	int					buflen, chunklen;

	enum {A_cmd, A_STATEVAR, A_CHUNK, A_objc};
	CHECK_ARGS_LABEL(finally, code, "statevar chunk");

	replace_tclobj(&stateobj, Tcl_ObjGetVar2(interp, objv[A_STATEVAR], NULL, TCL_LEAVE_ERR_MSG));
	if (stateobj == NULL) {
		state = alloc_lex_state();
		replace_tclobj(&stateobj, IMAP_NewLexStateObj(interp, state));
	} else {
		TEST_OK_LABEL(finally, code, Tcl_UnsetVar(interp, Tcl_GetString(objv[A_STATEVAR]), TCL_LEAVE_ERR_MSG));
	}
	// Should now be unshared, but make sure
	if (Tcl_IsShared(stateobj))	replace_tclobj(&stateobj, Tcl_DuplicateObj(stateobj));

	TEST_OK_LABEL(finally, code, IMAP_GetLexStateFromObj(interp, stateobj, &state));
	Tcl_InvalidateStringRep(stateobj);
	Tcl_Preserve(state->interp = interp);

	if (Tcl_IsShared(state->buf)) replace_tclobj(&state->buf, Tcl_DuplicateObj(state->buf));
	uint8_t* buf			= Tcl_GetBytesFromObj(interp, state->buf, &buflen);
	Tcl_InvalidateStringRep(state->buf);

	const uint8_t* chunk	= Tcl_GetBytesFromObj(interp, objv[A_CHUNK], &chunklen);

	if (chunklen > 0) {
		const ptrdiff_t	shift = state->rewind_ofs < state->tok_ofs ? state->rewind_ofs : state->tok_ofs;
		if (shift) {
			state->cur_ofs		-= shift;
			state->tok_ofs		-= shift;
			state->mar_ofs		-= shift;
			state->lim_ofs		-= shift;
			state->rewind_ofs	-= shift;
/*!stags:re2c:parse_response format = "\t\t\t\tstate->@@{tag}_ofs -= shift;"; */
			buflen				-= shift;
			memmove(buf, buf + shift, buflen-1);		// buflen includes sentinel
		}
		const size_t	newsize = buflen + chunklen;	// buflen includes sentinel
		buf = Tcl_SetByteArrayLength(state->buf, newsize);
		memcpy(buf + state->lim_ofs, chunk, chunklen);
		state->lim_ofs	+= chunklen;
		buflen			+= chunklen;
		buf[state->lim_ofs] = 0;
	}

	const uint8_t*	cur	= buf + state->cur_ofs;
	const uint8_t*	tok	= buf + state->tok_ofs;
	const uint8_t*	mar	= buf + state->mar_ofs;
	const uint8_t*	lim	= buf + state->lim_ofs;
	uint8_t			yych = state->yych;
	uint32_t		yyaccept = state->yyaccept;
/*!stags:re2c:parse_response format = "\t\tconst uint8_t* @@{tag} = buf + state->@@{tag}_ofs;\n"; */

	#define DEDUP(from, to)	Dedup_NewStringObj(dpool, (const char*)from, (int)((to)-(from)))
	#define EMIT(token, val)	\
	do { \
		Tcl_Obj* minor = val; \
		if (minor) Tcl_IncrRefCount(minor); \
		/*fprintf(stderr, "EMIT: <%s>\n", minor ? Tcl_GetString(minor) : "NULL");*/ \
		state->code = TCL_OK; state->harvest = 0; state->rewind = 0; \
		parse_response_tok(&state->p, token, minor, state); \
		if (!state->rewind) { \
			state->rewind_ofs = cur - buf; \
			/*fprintf(stderr, "\tEMIT updating rewind ofs after accepted token: (%.*s)\n", 20, buf+state->rewind_ofs);*/ \
		} \
		/*fprintf(stderr, "After parse_response_tok, rewind: %d\n", state->rewind);*/ \
		replace_tclobj(&minor, NULL); \
		if (state->harvest) goto parse_result; \
		if (state->rewind) { \
			/*fprintf(stderr, "rewinding cur back to rewind point: (%.*s)\n", 20, buf+state->rewind_ofs);*/ \
			tok = cur = buf + state->rewind_ofs; \
			goto tokloop; \
		} \
	} while (0)

	/*!getstate:re2c:parse_response */
	for (;;) {
		const uint8_t		*s, *e, *f;
		tok = cur;

	tokloop:	// like "continue" but doesn't move tok, for lexing a token in chunks
		/*!local:re2c:parse_response
		!use:common;
		re2c:define:YYFILL	= "goto more;";
		re2c:eof			= 0;

		//< > :=> plain

		<plain,post>	CRLF	=> plain				{ EMIT(CRLF, NULL); EMIT(0, NULL); }
		<post>	SP		=> plain				{ continue; }
		<plain,post>	")"				=> post	{ EMIT(RPAREN,					lit[L_TOK_rparen]);					continue; }
		<plain,post>	"]"				=> post	{ EMIT(RBRACKET,				lit[L_TOK_rbracket]);				continue; }
		<post>	">"								{ EMIT(RANGLE,					lit[L_TOK_rangle]);					continue; }
		<post>	","		=> plain				{ EMIT(COMMA,					lit[L_TOK_comma]);					continue; }
		<post>	":"		=> plain				{ EMIT(COLON,					lit[L_TOK_colon]);					continue; }
		<plain>	"="		=> plain				{ EMIT(EQUALS,					lit[L_TOK_equals]);					continue; }

		<plain>	"("								{ EMIT(LPAREN,					lit[L_TOK_lparen]);					continue; }
		<plain,post>	"["			=> plain	{ EMIT(LBRACKET,				lit[L_TOK_lbracket]);				continue; }
		<plain,post>	"<"			=> plain	{ EMIT(LANGLE,					lit[L_TOK_langle]);					continue; }
		<plain>	"."						=> post	{ EMIT(DOT,						lit[L_TOK_dot]);					continue; }
		<plain>	"$"						=> post	{ EMIT(DOLLAR,					lit[L_TOK_dollar]);					continue; }
		<plain>	"*"						=> post	{ EMIT(ASTERISK,				lit[L_TOK_asterisk]);				continue; }
		<plain>	"+"						=> post	{ EMIT(PLUS,					lit[L_TOK_plus]);					continue; }

//		<plain>	'7BIT'					=> post	{ EMIT(SEVENBIT,				lit[L_TOK_SEVENBIT]);				continue; }
//		<plain>	'8BIT'					=> post	{ EMIT(EIGHTBIT,				lit[L_TOK_EIGHTBIT]);				continue; }
		<plain>	'ALERT'					=> post	{ EMIT(ALERT,					lit[L_TOK_ALERT]);					continue; }
		<plain>	'ALL'					=> post	{ EMIT(ALL,						lit[L_TOK_ALL]);					continue; }
		<plain>	'ALREADYEXISTS'			=> post	{ EMIT(ALREADYEXISTS,			lit[L_TOK_ALREADYEXISTS]);			continue; }
		<plain>	'APPENDUID'				=> post	{ EMIT(APPENDUID,				lit[L_TOK_APPENDUID]);				continue; }
		<plain>	'AUTHENTICATIONFAILED'	=> post	{ EMIT(AUTHENTICATIONFAILED,	lit[L_TOK_AUTHENTICATIONFAILED]);	continue; }
		<plain>	'AUTHORIZATIONFAILED'	=> post	{ EMIT(AUTHORIZATIONFAILED,		lit[L_TOK_AUTHORIZATIONFAILED]);	continue; }
		<plain>	'BAD'					=> post	{ EMIT(BAD,						lit[L_TOK_BAD]);					continue; }
//		<plain>	'BASE64'				=> post	{ EMIT(BASE64,					lit[L_TOK_BASE64]);					continue; }
		<plain>	'BINARY'				=> post	{ EMIT(BINARY,					lit[L_TOK_BINARY]);					continue; }
		<plain>	'BINARY.PEEK'			=> post	{ EMIT(BINARY_PEEK,				lit[L_TOK_BINARY_PEEK]);			continue; }
		<plain>	'BINARY.SIZE'			=> post	{ EMIT(BINARY_SIZE,				lit[L_TOK_BINARY_SIZE]);			continue; }
		<plain>	'BODY'					=> post	{ EMIT(BODY,					lit[L_TOK_BODY]);					continue; }
		<plain>	'BODY.PEEK'				=> post	{ EMIT(BODY_PEEK,				lit[L_TOK_BODY_PEEK]);				continue; }
		<plain>	'BODYSTRUCTURE'			=> post	{ EMIT(BODYSTRUCTURE,			lit[L_TOK_BODYSTRUCTURE]);			continue; }
		<plain>	'BYE'					=> post	{ EMIT(BYE,						lit[L_TOK_BYE]);					continue; }
		<plain>	'CANNOT'				=> post	{ EMIT(CANNOT,					lit[L_TOK_CANNOT]);					continue; }
		<plain>	'CAPABILITY'			=> post	{ EMIT(CAPABILITY,				lit[L_TOK_CAPABILITY]);				continue; }
		<plain> 'CLIENTBUG'				=> post	{ EMIT(CLIENTBUG,				lit[L_TOK_CLIENTBUG]);				continue; }
		<plain>	'CLOSED'				=> post	{ EMIT(CLOSED,					lit[L_TOK_CLOSED]);					continue; }
		<plain>	'CONTACTADMIN'			=> post	{ EMIT(CONTACTADMIN,			lit[L_TOK_CONTACTADMIN]);			continue; }
		<plain>	'COPYUID'				=> post	{ EMIT(COPYUID,					lit[L_TOK_COPYUID]);				continue; }
		<plain>	'CORRUPTION'			=> post	{ EMIT(CORRUPTION,				lit[L_TOK_CORRUPTION]);				continue; }
		<plain>	'DELETED'				=> post	{ EMIT(DELETED,					lit[L_TOK_DELETED]);				continue; }
		<plain>	'ENABLED'				=> post	{ EMIT(ENABLED,					lit[L_TOK_ENABLED]);				continue; }
		<plain>	'ENVELOPE'				=> post	{ EMIT(ENVELOPE,				lit[L_TOK_ENVELOPE]);				continue; }
		<plain>	'ESEARCH'				=> post	{ EMIT(ESEARCH,					lit[L_TOK_ESEARCH]);				continue; }
		<plain>	'EXISTS'				=> post	{ EMIT(EXISTS,					lit[L_TOK_EXISTS]);					continue; }
		<plain> 'EXPIRED'				=> post	{ EMIT(EXPIRED,					lit[L_TOK_EXPIRED]);				continue; }
		<plain>	'EXPUNGE'				=> post	{ EMIT(EXPUNGE,					lit[L_TOK_EXPUNGE]);				continue; }
		<plain>	'EXPUNGEISSUED'			=> post	{ EMIT(EXPUNGEISSUED,			lit[L_TOK_EXPUNGEISSUED]);			continue; }
//		<plain>	'FAST'					=> post	{ EMIT(FAST,					lit[L_TOK_FAST]);					continue; }
		<plain>	'FETCH'					=> post	{ EMIT(FETCH,					lit[L_TOK_FETCH]);					continue; }
		<plain>	'FLAGS'					=> post	{ EMIT(FLAGS,					lit[L_TOK_FLAGS]);					continue; }
//		<plain>	'FULL'					=> post	{ EMIT(FULL,					lit[L_TOK_FULL]);					continue; }
		<plain>	'HASCHILDREN'			=> post	{ EMIT(HASCHILDREN,				lit[L_TOK_HASCHILDREN]);			continue; }
		<plain>	'HEADER'				=> post	{ EMIT(HEADER,					lit[L_TOK_HEADER]);					continue; }
		<plain>	'HEADER.FIELDS'			=> post	{ EMIT(HEADER_FIELDS,			lit[L_TOK_HEADER_FIELDS]);			continue; }
		<plain>	'HEADER.FIELDS.NOT'		=> post	{ EMIT(HEADER_FIELDS_NOT,		lit[L_TOK_HEADER_FIELDS_NOT]);		continue; }
//		<plain>	'IMAP4rev1'				=> post	{ EMIT(IMAP4REV1,				lit[L_TOK_IMAP4REV1]);				continue; }
//		<plain>	'IMAP4rev2'				=> post	{ EMIT(IMAP4REV2,				lit[L_TOK_IMAP4REV2]);				continue; }
		<plain>	'INTERNALDATE'			=> post	{ EMIT(INTERNALDATE,			lit[L_TOK_INTERNALDATE]);			continue; }
		<plain>	'INUSE'					=> post	{ EMIT(INUSE,					lit[L_TOK_INUSE]);					continue; }
		<plain>	'LIMIT'					=> post	{ EMIT(LIMIT,					lit[L_TOK_LIMIT]);					continue; }
		<plain>	'LIST'					=> post	{ EMIT(LIST,					lit[L_TOK_LIST]);					continue; }
//		<plain>	'LSUB'					=> post	{ EMIT(LSUB,					lit[L_TOK_LSUB]);					continue; }
		<plain>	'MESSAGES'				=> post	{ EMIT(MESSAGES,				lit[L_TOK_MESSAGES]);				continue; }
		<plain>	'MIME'					=> post	{ EMIT(MIME,					lit[L_TOK_MIME]);					continue; }
		<plain>	'NAMESPACE'				=> post	{ EMIT(NAMESPACE,				lit[L_TOK_NAMESPACE]);				continue; }
		<plain>	'NIL'					=> post	{ EMIT(NIL,						lit[L_TOK_NIL]);					continue; }
		<plain>	'NO'					=> post	{ EMIT(NO,						lit[L_TOK_NO]);						continue; }
		<plain>	'NONEXISTENT'			=> post	{ EMIT(NONEXISTENT,				lit[L_TOK_NONEXISTENT]);			continue; }
		<plain> 'NOPERM'				=> post	{ EMIT(NOPERM,					lit[L_TOK_NOPERM]);					continue; }
		<plain> 'NOTSAVED'				=> post	{ EMIT(NOTSAVED,				lit[L_TOK_NOTSAVED]);				continue; }
		<plain>	'OK'					=> post	{ EMIT(OK,						lit[L_TOK_OK]);						continue; }
		<plain>	'OVERQUOTA'				=> post	{ EMIT(OVERQUOTA,				lit[L_TOK_OVERQUOTA]);				continue; }
		<plain>	'PARSE'					=> post	{ EMIT(PARSE,					lit[L_TOK_PARSE]);					continue; }
		<plain>	'PERMANENTFLAGS'		=> post	{ EMIT(PERMANENTFLAGS,			lit[L_TOK_PERMANENTFLAGS]);			continue; }
		<plain>	'PREAUTH'				=> post	{ EMIT(PREAUTH,					lit[L_TOK_PREAUTH]);				continue; }
		<plain>	'PRIVACYREQUIRED'		=> post	{ EMIT(PRIVACYREQUIRED,			lit[L_TOK_PRIVACYREQUIRED]);		continue; }
//		<plain>	'QUOTED-PRINTABLE'		=> post	{ EMIT(QUOTED_PRINTABLE,		lit[L_TOK_QUOTED_PRINTABLE]);		continue; }
		<plain>	'READ-ONLY'				=> post	{ EMIT(READ_ONLY,				lit[L_TOK_READ_ONLY]);				continue; }
		<plain>	'READ-WRITE'			=> post	{ EMIT(READ_WRITE,				lit[L_TOK_READ_WRITE]);				continue; }
		<plain>	'RECENT'				=> post	{ EMIT(RECENT,					lit[L_TOK_RECENT]);					continue; }
		<plain>	'RFC822'				=> post	{ EMIT(RFC822,					lit[L_TOK_RFC822]);					continue; }
		<plain>	'RFC822.HEADER'			=> post	{ EMIT(RFC822_HEADER,			lit[L_TOK_RFC822_HEADER]);			continue; }
		<plain>	'RFC822.SIZE'			=> post	{ EMIT(RFC822_SIZE,				lit[L_TOK_RFC822_SIZE]);			continue; }
		<plain>	'RFC822.TEXT'			=> post	{ EMIT(RFC822_TEXT,				lit[L_TOK_RFC822_TEXT]);			continue; }
//		<plain>	'SEARCH'				=> post	{ EMIT(SEARCH,					lit[L_TOK_SEARCH]);					continue; }
		<plain>	'SERVERBUG'				=> post	{ EMIT(SERVERBUG,				lit[L_TOK_SERVERBUG]);				continue; }
		<plain>	'SIZE'					=> post	{ EMIT(SIZE,					lit[L_TOK_SIZE]);					continue; }
		<plain>	'STATUS'				=> post	{ EMIT(STATUS,					lit[L_TOK_STATUS]);					continue; }
		<plain> 'TAG'					=> post	{ EMIT(TAG,						lit[L_TOK_TAG]);					continue; }
//		<plain>	'TEXT'					=> post	{ EMIT(TEXT,					lit[L_TOK_TEXT]);					continue; }
		<plain>	'TRYCREATE'				=> post	{ EMIT(TRYCREATE,				lit[L_TOK_TRYCREATE]);				continue; }
		<plain>	'UID'					=> post	{ EMIT(UID,						lit[L_TOK_UID]);					continue; }
		<plain>	'UIDNEXT'				=> post	{ EMIT(UIDNEXT,					lit[L_TOK_UIDNEXT]);				continue; }
		<plain>	'UIDNOTSTICKY'			=> post	{ EMIT(UIDNOTSTICKY,			lit[L_TOK_UIDNOTSTICKY]);			continue; }
		<plain>	'UIDVALIDITY'			=> post	{ EMIT(UIDVALIDITY,				lit[L_TOK_UIDVALIDITY]);			continue; }
		<plain> 'UNAVAILABLE'			=> post	{ EMIT(UNAVAILABLE,				lit[L_TOK_UNAVAILABLE]);			continue; }
		<plain> 'UNKNOWN-CTE'			=> post	{ EMIT(UNKNOWN_CTE,				lit[L_TOK_UNKNOWN_CTE]);			continue; }
		<plain>	'UNSEEN'				=> post	{ EMIT(UNSEEN,					lit[L_TOK_UNSEEN]);					continue; }

		<plain> 'X-GM-MSGID'			=> post	{ EMIT(X_GM_MSGID,				lit[L_TOK_X_GM_MSGID]);				continue; }
		<plain> 'X-GM-LABELS'			=> post	{ EMIT(X_GM_LABELS,				lit[L_TOK_X_GM_LABELS]);			continue; }
		<plain> 'MODSEQ'				=> post	{ EMIT(MODSEQ,					lit[L_TOK_MODSEQ]);					continue; }

		flag_keyword
			= "$MDNSent"
			| "$Forwarded"
			| "$Junk"
			| "$NotJunk"
			| "$Phishing"
			;
		flag = BS atom;
		<plain>	flag			=> post	{ EMIT(FLAG,			DEDUP(tok,cur));	continue; }
		<plain>	flag_keyword	=> post	{ EMIT(FLAG_KEYWORD,	DEDUP(tok,cur));	continue; }
		<plain>	BS "*"			=> post	{ EMIT(FLAG_STAR,		DEDUP(tok,cur));	continue; }

		<plain>	number			=> post	{ EMIT(NUMBER,			DEDUP(tok,cur));	continue; }
		<plain>	atom			=> post	{ EMIT(ATOM,			DEDUP(tok,cur));	continue; }

		<plain>		DQUOTE quote_safe_char* DQUOTE	=> post		{ EMIT(QUOTED_STRING, DEDUP(tok+1,cur-1));					continue; }
		<plain>		DQUOTE							=> string	{ Tcl_DStringSetLength(&state->tokbuf, 0);					goto tokloop; }
		<string>	@s quote_safe_char+ @e						{ Tcl_DStringAppend(&state->tokbuf, (const char*)s, e-s);	goto tokloop; }
		<string>	BS @s quoted_specials @e					{ Tcl_DStringAppend(&state->tokbuf, (const char*)s, e-s);	goto tokloop; }
		<string>	DQUOTE							=> post		{ EMIT(QUOTED_STRING, Tcl_DStringToObj(&state->tokbuf));	continue; }

		<plain> ("~" @f)? LBRACE @s number @e "+"? RBRACE CRLF	=> literal	{
			EMIT(LITERAL_HEADER, DEDUP(tok,cur));	// give the grammar a chance to bail out and redirect to parsing text or text_not_rbracket if that's what it wants
			EMIT(CRLF, NULL);
			state->litlen = strtoll((const char*)s, NULL, 10);
			state->litbin = f != NULL;
			continue;
		}

		<literal> *		{
			cur--;
			const size_t	have = cur - tok;
			const size_t	want = state->litlen - have;
			const size_t	avail = lim - cur;
			const size_t	take = want < avail ? want : avail;

			cur += take;
			if (cur - tok == state->litlen) {
				state->cond = yycpost;
				EMIT(LITERAL_DATA, state->litbin ? Tcl_NewByteArrayObj(tok, cur-tok) : Tcl_NewStringObj((const char*)tok, cur-tok));
				continue;
			}

			goto more;
		}

		// These context-dependent tokens don't fit into the plain rules, the conditions are triggered from the parser actions
		<text> TEXT_CHAR+ @s						=> post		{ EMIT(TEXT, DEDUP(tok,s)); continue; }
		<text_not_rbracket> (TEXT_CHAR \ "]")+		=> post		{ EMIT(TEXT_NOT_RBRACKET_STRING, DEDUP(tok,s)); continue; }

		<*> *	{
			//THROW_PRINTF_LABEL(finally, code, "Could not lex: <%.*s>", 50, cur-1);
			breakpoint();
			EMIT(LEX_ERROR, DEDUP(tok,cur));
			continue;
		}
		<*> $ { goto more; }
		*/
	}

update_state:
	state->cur_ofs = cur - buf;
	state->tok_ofs = tok - buf;
	state->mar_ofs = mar - buf;
	state->lim_ofs = lim - buf;
	state->yych = yych;
	state->yyaccept = yyaccept;
/*!stags:re2c:parse_response format = "\t\tstate->@@{tag}_ofs = @@{tag} - buf;\n"; */
	replace_tclobj(&stateobj, Tcl_ObjSetVar2(interp, objv[A_STATEVAR], NULL, stateobj, TCL_LEAVE_ERR_MSG));
	if (stateobj == NULL) {code=TCL_ERROR; goto finally;}
	// Falls through

finally:
	if (state) {
		if (state->interp) {
			Tcl_Release(state->interp);
			state->interp = NULL;
		}
	}
	replace_tclobj(&stateobj,	NULL);
	return code;

parse_result:
	tok = cur;
	code = state->code;
	state->code = TCL_OK;
	// Falls through

	/* Should be unnecessary:
parse_reset:
	*/
	parse_response_tokFinalize(&state->p);
	parse_response_tokInit(&state->p);
	replace_tclobj(&state->_, Tcl_NewDictObj());
	goto update_state;

more:
	code = Tcl_SetReturnOptions(interp, lit[L_MORE_EXCEPTION]);
	Tcl_SetObjResult(interp, lit[L_EMPTY]);
	goto update_state;

	#undef DEDUP
	#undef EMIT
}

//>>>
OBJCMD(finalize) // Not required for cleanup, but checks that no partial parse state exists <<<
{
	int					code = TCL_OK;
	Tcl_Obj*			stateobj = NULL;
	struct lex_state*	state = NULL;
	int					buflen = 0;

	enum {A_cmd, A_STATEVAR, A_objc};
	CHECK_ARGS_LABEL(finally, code, "statevar");

	replace_tclobj(&stateobj, Tcl_ObjGetVar2(interp, objv[A_STATEVAR], NULL, 0));

	if (stateobj) {
		TEST_OK_LABEL(finally, code, Tcl_UnsetVar(interp, Tcl_GetString(objv[A_STATEVAR]), TCL_LEAVE_ERR_MSG));
		TEST_OK_LABEL(finally, code, IMAP_GetLexStateFromObj(interp, stateobj, &state));

		// Finalize the parse: throw an exception if a parse was in progress
		parse_response_tok(&state->p, 0, NULL, state);

		if (state->buf) {
			const uint8_t* buf = Tcl_GetBytesFromObj(interp, state->buf, &buflen);
			if (buf == NULL && code == TCL_OK) {code = TCL_ERROR; goto finally;}
		}
		if (buflen>1) {
			if (code == TCL_OK) {
				Tcl_SetObjErrorCode(interp, Tcl_NewListObj(3, (Tcl_Obj*[]){
					lit[L_IMAP],
					lit[L_TRAILING_INPUT],
					state->buf
				}));
				THROW_PRINTF_LABEL(finally, code, "Unparsed input remains: %zd bytes", buflen-1);
			}
		}
	}

finally:
	replace_tclobj(&stateobj, NULL);		// objtype free intrep does all the cleanup
	return code;
}

//>>>
OBJCMD(quote) //<<<
{
	int			code = TCL_OK;
	Tcl_Obj*	tmp = NULL;
	Tcl_Obj*	res = NULL;
	Tcl_Obj*	val = NULL;
	Tcl_Obj*	strval = NULL;

	#define QUOTE_TYPES \
		X(string) \
		X(astring) \
		X(atom) \
		X(mbox_or_pat) \
		X(list_mailbox) \
		X(sequence_set) \
	// Line intentionally left blank
	static const char* types[] = {
		#define X(name) #name,
		QUOTE_TYPES
		#undef X
		NULL
	};
	enum quote_types {
		#define X(name) QT_##name,
		QUOTE_TYPES
		#undef X
	} type;
	#undef QUOTE_TYPES

	enum {A_cmd, A_TYPE, A_VAL, A_objc};
	CHECK_ARGS_LABEL(finally, code, "type value");

	int				size;
	const uint8_t*	str = NULL;
	const uint8_t*	cur = NULL;
	const uint8_t*	lim = NULL;
	const uint8_t*	mar;
	uint8_t			yych;
	int				yystate = -1;
	int				cond = 0;

	/*!rules:re2c:quote
		!use:common;
		re2c:define:YYFILL		= "";
		re2c:define:YYGETCOND	= "cond";
		re2c:define:YYSETCOND	= "cond = @@;";
		re2c:define:YYSETSTATE	= "yystate = @@;";
		re2c:define:YYGETSTATE	= "yystate";
	*/

	replace_tclobj(&val, objv[A_VAL]);

	int type_int;
	TEST_OK_LABEL(finally, code, Tcl_GetIndexFromObj(interp, objv[A_TYPE], types, "type", TCL_EXACT, &type_int)); type=type_int;
	for (;;) {	// Allow retargeting other types by changing `type` and `val` and `continue;`-ing
		switch (type) {
			case QT_string: { //<<<
				enum json_types	t;
				TEST_OK_LABEL(finally, code, JSON_Type(interp, val, NULL, &t));
				if (t != JSON_STRING) THROW_ERROR_LABEL(finally, code, "must be a JSON string");
				TEST_OK_LABEL(finally, code, JSON_Get(interp, val, NULL, &strval));

				/*!types:re2c:quote_string */
				cur = str = (const uint8_t*)Tcl_GetStringFromObj(strval, &size);
				lim = str + size;

				/*!local:re2c:quote_string
					!use:quote;

					<quote_string> end {
						// Must be sent as a zero-length quoted string
						Tcl_SetObjResult(interp, lit[L_ZEROSTRING]);
						goto finally;
					}

					<quote_string> quote_safe_char+ end {
						// TODO: enforce length limits
						// Can just be written directly, wrapped in double quotes
						Tcl_SetObjResult(interp, Tcl_ObjPrintf("\"%s\"", str));
						goto finally;
					}

					<quote_string> CHAR8+ end {
						// Write as a non-synchronizing literal
						Tcl_SetObjResult(interp, Tcl_ObjPrintf("{%d+}\r\n%*s\r\n", size, size, str));
						goto finally;
					}

					<quote_string> * { THROW_ERROR_LABEL(finally, code, "Cannot write string"); }
				*/
				break;
			}
			//>>>
			case QT_astring: { //<<<
				enum json_types	t;
				TEST_OK_LABEL(finally, code, JSON_Type(interp, val, NULL, &t));
				if (t != JSON_STRING) THROW_ERROR_LABEL(finally, code, "must be a JSON string");
				TEST_OK_LABEL(finally, code, JSON_Get(interp, val, NULL, &strval));

				/*!types:re2c:quote_astring */
				cur = str = (const uint8_t*)Tcl_GetStringFromObj(strval, &size);
				lim = str + size;

				/*!local:re2c:quote_astring
					!use:quote;

					<quote_astring> astring_char+ end {
						// Can just be written directly
						Tcl_SetObjResult(interp, strval);
						goto finally;
					}

					<quote_astring> * { type = QT_string; continue; }
				*/
				break;
			}
			//>>>
			case QT_atom: { //<<<
				enum json_types	t;
				TEST_OK_LABEL(finally, code, JSON_Type(interp, val, NULL, &t));
				if (t != JSON_STRING) THROW_ERROR_LABEL(finally, code, "must be a JSON string");
				TEST_OK_LABEL(finally, code, JSON_Get(interp, val, NULL, &strval));

				/*!types:re2c:quote_atom */
				cur = str = (const uint8_t*)Tcl_GetStringFromObj(strval, &size);
				lim = str + size;

				/*!local:re2c:quote_atom
					!use:quote;

					<quote_atom> ATOM_CHAR+ end {
						// Can just be written directly
						Tcl_SetObjResult(interp, strval);
						goto finally;
					}

					<quote_atom> * { THROW_ERROR_LABEL(finally, code, "Cannot write value as an atom"); }
				*/
				break;
			}
			//>>>
			case QT_mbox_or_pat: { //<<<
				enum json_types	t;
				TEST_OK_LABEL(finally, code, JSON_Type(interp, val, NULL, &t));
				/*
					//patterns		= "(" list_mailbox ")";
					patterns		= "(" list_mailbox (SP list_mailbox)* ")";		// RFC 5258 - LIST-EXTENDED capability
					mbox_or_pat		= list_mailbox | patterns;
				*/
				switch (t) {
					case JSON_STRING:	type = QT_list_mailbox; continue;
					case JSON_ARRAY:
						{
							replace_tclobj(&tmp, Tcl_NewListObj(4, (Tcl_Obj*[]){
								lit[L_APPLY],
								lit[L_BUILD_LIST],
								lit[L_LIST_MAILBOX],
								val
							}));
							TEST_OK_LABEL(finally, code, Tcl_EvalObjEx(interp, tmp, 0));
							break;
						}
					default: THROW_ERROR_LABEL(finally, code, "must be a JSON string or array of strings");
				}
				break;
			}
			//>>>
			case QT_list_mailbox: { //<<<
				TEST_OK_LABEL(finally, code, JSON_Get(interp, val, NULL, &strval));

				/*!types:re2c:quote_list_mailbox */
				cur = str = (const uint8_t*)Tcl_GetStringFromObj(strval, &size);
				lim = str + size;

				/*!local:re2c:quote_list_mailbox
					!use:quote;

					list_char		= ATOM_CHAR | list_wildcards | resp_specials;

					<list_mailbox> list_char+ end		{
						// Can just be written directly
						Tcl_SetObjResult(interp, strval);
						goto finally;
					}

					<list_mailbox> * { type = QT_string; continue; }
				*/
				break;
			}
			//>>>
			case QT_sequence_set: { //<<<
				enum json_types	t;
				TEST_OK_LABEL(finally, code, JSON_Type(interp, val, NULL, &t));
				if (t != JSON_STRING) THROW_ERROR_LABEL(finally, code, "must be a JSON string");
				TEST_OK_LABEL(finally, code, JSON_Get(interp, val, NULL, &strval));

				/*!types:re2c:quote_sequence_set */
				cur = str = (const uint8_t*)Tcl_GetStringFromObj(strval, &size);
				lim = str + size;

				/*!local:re2c:quote_sequence_set
					!use:quote;

					seq_number			= nz_number | "*";
					seq_range			= seq_number ":" seq_number;
					seq_thing			= seq_number | seq_range;
					seq_last_command	= "$";
					sequence_set
						= seq_thing ("," seq_thing)*
						| seq_last_command
						;

					<quote_sequence_set> sequence_set+ end {
						// Can just be written directly
						Tcl_SetObjResult(interp, strval);
						goto finally;
					}

					<quote_sequence_set> * { THROW_ERROR_LABEL(finally, code, "Cannot write value as a sequence_set"); }
				*/
				break;
			}
			//>>>
			default: THROW_ERROR_LABEL(finally, code, "Invalid type");
		}
		break;
	}

	if (res) Tcl_SetObjResult(interp, res);

finally:
	replace_tclobj(&tmp,	NULL);
	replace_tclobj(&res,	NULL);
	replace_tclobj(&val,	NULL);
	replace_tclobj(&strval,	NULL);
	return code;
}

//>>>
OBJCMD(log_chan) // Return a readable Tcl channel handle that receives the log messages <<<
{
	int		code = TCL_OK;
	FILE*	f = NULL;

	enum {A_cmd, A_PREFIX, A_objc};
	CHECK_ARGS_LABEL(finally, code, "");

	enum {PIPE_READ, PIPE_WRITE};
	int	pipefd[2] = {-1, -1};

	if (-1 == pipe(pipefd)) THROW_POSIX_LABEL(finally, code, "pipe");
	if (-1 == fcntl(pipefd[PIPE_READ],  F_SETFD, FD_CLOEXEC)) THROW_POSIX_LABEL(finally, code, "fcntl");
	if (-1 == fcntl(pipefd[PIPE_WRITE], F_SETFD, FD_CLOEXEC)) THROW_POSIX_LABEL(finally, code, "fcntl");

	intptr_t	handle = pipefd[PIPE_READ];
	Tcl_Channel	chan = Tcl_MakeFileChannel((ClientData)handle, TCL_READABLE);
	pipefd[PIPE_READ] = -1;	// fd is owned by the channel
	Tcl_RegisterChannel(interp, chan);
	const char*	chan_name = Tcl_GetChannelName(chan);

	if (yyTraceFILE && yyTraceFILE != stderr && yyTraceFILE != stdout) {
		if (-1 == fclose(yyTraceFILE)) THROW_POSIX_LABEL(finally, code, "fclose");
		yyTraceFILE = NULL;
	}
	parse_response_tokTrace(NULL, NULL);
	if (trace_prefix) {
		ckfree(trace_prefix);
		trace_prefix = NULL;
	}

	f = fdopen(pipefd[PIPE_WRITE], "w");
	if (f == NULL) THROW_POSIX_LABEL(finally, code, "fdopen");
	pipefd[PIPE_WRITE] = -1;	// fd is owned by the FILE*
	int prefix_len = 0;
	const char* prefix = Tcl_GetStringFromObj(objv[A_PREFIX], &prefix_len);
	trace_prefix = ckalloc(prefix_len+1);
	memcpy(trace_prefix, prefix, prefix_len+1);
	parse_response_tokTrace(f, trace_prefix);
	f = NULL;

	Tcl_SetObjResult(interp, Tcl_NewStringObj(chan_name, -1));
	chan = NULL;	// Channel is owned by the interp

finally:
	if (f) {fclose(f); f = NULL;}
	if (chan) Tcl_UnregisterChannel(interp, chan);
	if (pipefd[PIPE_READ] != -1) {
		close(pipefd[PIPE_READ]);
		pipefd[PIPE_READ] = -1;
	}
	if (pipefd[PIPE_WRITE] != -1) {
		close(pipefd[PIPE_WRITE]);
		pipefd[PIPE_WRITE] = -1;
	}
	return code;
}

//>>>
OBJCMD(disable_log) // Disable the logging channel <<<
{
	int		code = TCL_OK;

	enum {A_cmd, A_objc};
	CHECK_ARGS_LABEL(finally, code, "");

	if (yyTraceFILE && yyTraceFILE != stderr && yyTraceFILE != stdout) {
		if (-1 == fclose(yyTraceFILE)) THROW_POSIX_LABEL(finally, code, "fclose");
	}
	yyTraceFILE = NULL;

finally:
	return code;
}

//>>>

// vim: ft=c foldmethod=marker foldmarker=<<<,>>> ts=4 shiftwidth=4 noexpandtab
