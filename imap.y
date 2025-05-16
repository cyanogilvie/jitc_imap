//%include {}

%late_include {
#include "imap.h"
#define TCLLEMON_ACTION_PRE	 Tcl_Interp* interp = state->interp; int code = TCL_OK;
#define TCLLEMON_ACTION_POST state->code = code; return code;
}

%name				parse_response_tok
%extra_argument		{ struct lex_state* state }

%default_type		{ Tcl_Obj* }
%token_type			{ Tcl_Obj* }

// Fallback hacks <<<
%fallback ATOM
	ALERT
	ALL
	ALREADYEXISTS
	APPENDUID
	AUTHENTICATIONFAILED
	AUTHORIZATIONFAILED
	BAD
	BINARY
	BINARY_PEEK
	BINARY_SIZE
	BODY
	BODY_PEEK
	BYE
	CANNOT
	CAPABILITY
	CLIENTBUG
	CLOSED
	CONTACTADMIN
	COPYUID
	CORRUPTION
	DELETED
	ENABLED
	ENVELOPE
	ESEARCH
	EXISTS
	EXPIRED
	EXPUNGE
	EXPUNGEISSUED
	FETCH
	FLAGS
	HASCHILDREN
	HEADER
	HEADER_FIELDS
	HEADER_FIELDS_NOT
	INTERNALDATE
	INUSE
	LIMIT
	LIST
	MESSAGES
	MIME
	MODSEQ
	NAMESPACE
	NIL
	NO
	NONEXISTENT
	NOPERM
	NOTSAVED
	OK
	OVERQUOTA
	PARSE
	PERMANENTFLAGS
	PREAUTH
	PRIVACYREQUIRED
	READ_ONLY
	READ_WRITE
	RECENT
	RFC822
	RFC822_HEADER
	RFC822_SIZE
	RFC822_TEXT
	SERVERBUG
	SIZE
	STATUS
	TAG
	TRYCREATE
	UID
	UIDNEXT
	UIDNOTSTICKY
	UIDVALIDITY
	UNAVAILABLE
	UNKNOWN_CTE
	UNSEEN
	X_GM_LABELS
	X_GM_MSGID
	.

// LEX_ERROR: Not referenced directly in the grammar, but used to allow a character that fails the lexing rules in "plain" to trigger the switch to the "text" condition if the grammar wants that
%token LEX_ERROR.

%wildcard ANY.

//>>>

response ::= . {
	JSON_SET(t2, "type",	"none");
	Tcl_SetObjResult(interp, t2);
}
response ::= ASTERISK untagged_response(B) CRLF. {
	TAKE("resp_type", t1);
	JSON_SET(t2, "type",		"untagged");
	JSON_SET(t2, L_UNTAGGED,	t1);
	JSON_SET(t2, "details",		B);
	Tcl_SetObjResult(interp, t2);
}
response ::= PLUS resp_text(B) CRLF. {
	JSON_SET(t2, "type",	"continue");
	JSON_SET(t2, "details",	B);
	Tcl_SetObjResult(interp, t2);
}
response ::= json_atom(T) state(C) resp_text(R) CRLF. {
	JSON_SET(t2, "type",	"tagged");
	JSON_SET(t2, "tag",		T);
	JSON_SET(t2, "state",	C);
	JSON_SET(t2, "details",	R);
	Tcl_SetObjResult(interp, t2);
}

untagged_response(A) ::= resp_text_type(T) resp_text(B).		{ STASH("resp_type", T);			MOVE(B, A); }
untagged_response(A) ::= CAPABILITY capability_data_list(B).	{ STASH("resp_type", "CAPABILITY");	MOVE(B, A); }
untagged_response(A) ::= FLAGS flag_list(B).					{ STASH("resp_type", "FLAGS");		MOVE(B, A); }
untagged_response(A) ::= LIST mailbox_list(B).					{ STASH("resp_type", "LIST");		MOVE(B, A); }
untagged_response(A) ::= STATUS json_astring(M) LPAREN status_att_list(S) RPAREN. {
	STASH("resp_type", "STATUS");
	JSON_SET(A, "mailbox",	M);
	JSON_SET(A, "status",	S);
}
untagged_response(A) ::= NUMBER(B) EXISTS.						{ STASH("resp_type", "EXISTS");		MOVE(B, A); }
untagged_response(A) ::= NUMBER(B) RECENT.						{ STASH("resp_type", "RECENT");		MOVE(B, A); }
untagged_response(A) ::= ESEARCH search_correlator(T) is_uid(U) search_return_data_list(S). {
	STASH("resp_type", "ESEARCH");
	if (T)	JSON_SET(A, "tag",		T);
			JSON_SET(A, "uid",		U);
			JSON_SET(A, "results",	S);
}
untagged_response(A) ::= NAMESPACE namespace(P) namespace(O) namespace(S). {
	STASH("resp_type", "NAMESPACE");
	JSON_SET(A, "personal",	P);
	JSON_SET(A, "other",	O);
	JSON_SET(A, "shared",	S);
}
untagged_response(A) ::= NUMBER(B) EXPUNGE.					{ STASH("resp_type", "EXPUNGE");	MOVE(B, A); }
untagged_response(A) ::= NUMBER(B) FETCH msg_att(C). {
	STASH("resp_type", "FETCH");
	JSON_SET(A, "msgseq",	B);
	JSON_SET(A, "msg",		C);
}
untagged_response(A) ::= ENABLED capability_list(B).		{ STASH("resp_type", "ENABLED");	MOVE(B, A); }

resp_text_type(A) ::= state(B).								{ MOVE(B, A); }
resp_text_type(A) ::= BYE.									{ SET(A, L_BYE); }
resp_text_type(A) ::= PREAUTH.								{ SET(A, L_PREAUTH); }

state(A) ::= OK.											{ SET(A, L_OK); }
state(A) ::= NO.											{ SET(A, L_NO); }
state(A) ::= BAD.											{ SET(A, L_BAD); }

// capability_data_list is a JSON array of strings
capability_data_list(A) ::= .								{ SET(A, L_JSON_EMPTY_ARR); }
capability_data_list(A) ::= capability_list(B).				{ MOVE(B, A); }

// capability_list is a JSON array of strings
capability_list(A) ::= .									{ SET(A, L_JSON_EMPTY_ARR); }
capability_list(A) ::= capability(B).						{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); }
capability_list(A) ::= capability_list(B) capability(C).	{ MOVE(B, A); 				JSON_SET(A, L_END_PLUS_ONE, C); }

// capability is a JSON string
capability(A) ::= json_atom(B).				{ MOVE(B, A); }
capability(A) ::= AUTH EQUALS atom(B).		{ SETF(A, "AUTH=%s", Tcl_GetString(B));		SET(A, JSTR(A)); }

/* resp_text_code is a JSON array: first element is the code, second is the details (if there are any), like:

["ALERT"]

or 

["COPYUID", {
	"UIDVALIDITY":	123,
	"from_uids":	[123, [130, 135], 155, 170],
	"to_uids":		[[821, 829]
}]

or

["UIDVALIDITY", 42]

*/
resp_text_code(A) ::= atom(B).												{ SET_JSON_ARR( A, JSTR(B)		); }
resp_text_code(A) ::= ALERT(B).												{ SET_JSON_ARR( A, JSTR(B)		); }
resp_text_code(A) ::= BADCHARSET(B) LPAREN charset_list(L) RPAREN.			{ SET_JSON_ARR( A, JSTR(B),	L	); }
resp_text_code(A) ::= BADCHARSET(B).										{ SET_JSON_ARR( A, JSTR(B)		); }
resp_text_code(A) ::= CAPABILITY(B) capability_data_list(L).				{ SET_JSON_ARR( A, JSTR(B),	L	); }
resp_text_code(A) ::= PARSE(B).												{ SET_JSON_ARR( A, JSTR(B)		); }
resp_text_code(A) ::= PERMANENTFLAGS(B) LPAREN flag_perm_list(L) RPAREN.	{ SET_JSON_ARR( A, JSTR(B),	L	); }
resp_text_code(A) ::= READ_ONLY(B).											{ SET_JSON_ARR( A, JSTR(B)		); }
resp_text_code(A) ::= READ_WRITE(B).										{ SET_JSON_ARR( A, JSTR(B)		); }
resp_text_code(A) ::= TRYCREATE(B).											{ SET_JSON_ARR( A, JSTR(B)		); }
resp_text_code(A) ::= UIDNEXT(B) NUMBER(U).									{ SET_JSON_ARR( A, JSTR(B),	U	); }
resp_text_code(A) ::= UIDVALIDITY(B) NUMBER(V).								{ SET_JSON_ARR( A, JSTR(B),	V	); }
resp_text_code(A) ::= APPENDUID(B) NUMBER(V) NUMBER(U). {
	JSON_SET(t1, L_UIDVALIDITY,		V);
	JSON_SET(t1, "assigned_uid",	U);
	SET_JSON_ARR(A, JSTR(B), t1);
}
resp_text_code(A) ::= COPYUID(B) NUMBER(V) uid_set(F) uid_set(T). {
	JSON_SET(t1, L_UIDVALIDITY,	V);
	JSON_SET(t1, "from_uids",	F);
	JSON_SET(t1, "to_uids",		T);
	SET_JSON_ARR(A, JSTR(B), t1);
}
resp_text_code(A) ::= UIDNOTSTICKY(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= UNAVAILABLE(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= AUTHENTICATIONFAILED(B).								{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= AUTHORIZATIONFAILED(B).								{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= EXPIRED(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= PRIVACYREQUIRED(B).									{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= CONTACTADMIN(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= NOPERM(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= INUSE(B).												{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= EXPUNGEISSUED(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= CORRUPTION(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= SERVERBUG(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= CLIENTBUG(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= CANNOT(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= LIMIT(B).												{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= OVERQUOTA(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= ALREADYEXISTS(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= NONEXISTENT(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= NOTSAVED(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= HASCHILDREN(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= CLOSED(B).											{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= UNKNOWN_CTE(B).										{ SET_JSON_ARR( A, JSTR(B)				); }
resp_text_code(A) ::= UNSEEN(B) NUMBER(V).									{ SET_JSON_ARR( A, JSTR(B), V			); }
resp_text_code(A) ::= atom(B) NUMBER(V).									{ SET_JSON_ARR( A, JSTR(B), V			); }
resp_text_code(A) ::= atom(B) text_not_rbracket(S).							{ SET_JSON_ARR( A, JSTR(B), JSTR(S)		); }

charset_list(A) ::= charset(B).					{ SET_JSON_ARR(A, JSTR(B)); }
charset_list(A) ::= charset_list(B) charset(C).	{ MOVE(B, A); JSON_SET(A, L_END_PLUS_ONE, JSTR(C)); }

charset(A) ::= atom(B).				{ MOVE(B, A); }
charset(A) ::= QUOTED_STRING(B).	{ MOVE(B, A); }

text_not_rbracket_init(A) ::= QUOTED_STRING(B).										{ SETF(A, "\"%s\"", Tcl_GetString(B)); state->cond=yyctext_not_rbracket; state->rewind=1; }
text_not_rbracket_init(A) ::= ANY(B).												{ MOVE(B, A); state->cond=yyctext_not_rbracket; state->rewind=1; }
text_not_rbracket(A) ::= text_not_rbracket_init(B) ANY TEXT_NOT_RBRACKET_STRING(C).	{ MOVE(B, A); UNSHARE(A); Tcl_AppendObjToObj(A, C); }
text_not_rbracket(A) ::= text_not_rbracket_init(B).									{ MOVE(B, A); state->cond=yycpost; state->rewind=0; }	// Cancel the pending rewind - this rule is reduced if the next token is RBRACKET

text_init(A) ::= QUOTED_STRING(B).		{ SETF(A, "\"%s\"", Tcl_GetString(B)); state->cond = yyctext; state->rewind = 1; /* TODO: should actually capture and restore the original bytes, or re-format as a valid QUOTED-STRING */ }
text_init(A) ::= ANY(B).				{ MOVE(B, A); state->cond=yyctext; state->rewind=1; }
text(A) ::= text_init(B) ANY TEXT(C).	{ MOVE(B, A); UNSHARE(A); Tcl_AppendObjToObj(A, C); }	// Unused ANY to catch the lookahead terminal after the initial trigger terminal, which was rewound and captured in the TEXT terminal
text(A) ::= text_init(B).				{
breakpoint();
MOVE(B, A); state->cond=yycplain; state->rewind=0; }	// Cancel the pending rewind - this rule is reduced if the next token is CRLF
text(A) ::= .							{ SET(A, L_EMPTY); }	// Have to allow so that ANY can't eat CRLF

// resp_text is a JSON object with keys "code" and "text" (if they are present)
resp_text(A) ::= LBRACKET resp_text_code(C) RBRACKET text(T).	{ JSON_SET(A, "code", C);	JSON_SET(A, "text", JSTR(T)); }
resp_text(A) ::= text(T).										{ 							JSON_SET(A, "text", JSTR(T)); }

atom(A) ::= ATOM(B).					{ MOVE(B, A); }
atom(A) ::= LBRACKET atom(B).			{ SETF(A, "[%s", Tcl_GetString(B)); }
atom(A) ::= atom(F) LBRACKET atom(S).	{ SETF(A, "%s[%s", Tcl_GetString(F), Tcl_GetString(S)); }

// flag_perm_list is a JSON array of strings
flag_perm_list(A) ::= .									{ SET(A, L_JSON_EMPTY_ARR); }
flag_perm_list(A) ::= flag_perm(E).						{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, E); }
flag_perm_list(A) ::= flag_perm_list(L) flag_perm(E).	{ MOVE(L, A);				JSON_SET(A, L_END_PLUS_ONE, E); }

flag(A) ::= FLAG(B).			{ SET(A, JSTR(B)); }
flag(A) ::= FLAG_KEYWORD(B).	{ SET(A, JSTR(B)); }
flag(A) ::= atom(B).			{ SET(A, JSTR(B)); }

flag_perm(A) ::= flag(B).		{ SET(A, B); }
flag_perm(A) ::= FLAG_STAR(B).	{ SET(A, JSTR(B)); }

uid_set(A) ::= uid_set_elem(B).						{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); }
uid_set(A) ::= uid_set(B) COMMA uid_set_elem(C).	{ MOVE(B, A);				JSON_SET(A, L_END_PLUS_ONE, C); }

uid_set_elem(A) ::= NUMBER(B).						{ SET(A, B); }
uid_set_elem(A) ::= NUMBER(B) COLON NUMBER(C).		{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); JSON_SET(A, L_END_PLUS_ONE, C); }

flag_list(A) ::= LPAREN flag_list_content(B) RPAREN.			{ MOVE(B, A); }

flag_list_content(A) ::= .										{ SET(A, L_JSON_EMPTY_ARR); }
flag_list_content(A) ::= flag_fetch(B).							{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); }
flag_list_content(A) ::= flag_list_content(B) flag_fetch(C).	{ MOVE(B, A);				JSON_SET(A, L_END_PLUS_ONE, C); }

flag_fetch(A) ::= flag(B).										{ MOVE(B, A); }

search_correlator(A) ::= LPAREN TAG json_astring(T) RPAREN.	{ MOVE(T, A); }
search_correlator ::= .

is_uid(A) ::= UID.												{ SET(A, L_JSON_TRUE); }
is_uid(A) ::= .													{ SET(A, L_JSON_FALSE); }

// search_return_data_list is a JSON object
search_return_data_list(A) ::= .													{ SET(A, L_JSON_EMPTY_OBJ); }
search_return_data_list(A) ::= search_return_data(B).								{ TAKE(L__KEY, t1); JSON_SET(A, t1, B); }
search_return_data_list(A) ::= search_return_data_list(B) search_return_data(C).	{ TAKE(L__KEY, t1); MOVE(B, A); JSON_SET(A, t1, C); }

search_return_data(A) ::= MIN NUMBER(V).											{ STASH(L__KEY, L_MIN);		MOVE(V, A); }
search_return_data(A) ::= MAX NUMBER(V).											{ STASH(L__KEY, L_MAX);		MOVE(V, A); }
search_return_data(A) ::= ALL json_sequence_set(V).									{ STASH(L__KEY, L_ALL);		MOVE(V, A); }
search_return_data(A) ::= COUNT NUMBER(V).											{ STASH(L__KEY, L_COUNT);	MOVE(V, A); }
search_return_data(A) ::= json_atom(K) json_atom(V).								{ STASH(L__KEY, K);			MOVE(V, A); }

%ifdef PARSE_SEQUENCE_SET
json_sequence_set(A) ::= sequence_set(B).											{ MOVE(B, A); }
sequence_set(A) ::= json_atom(B).													{ SET(A, B); }	// Since this is longer than the match of the parts, it will take precedence over lexing the parts
sequence_set(A) ::= sequence_thing(B).												{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); }
sequence_set(A) ::= sequence_set(B) COMMA sequence_thing(C).						{ MOVE(B, A);				JSON_SET(A, L_END_PLUS_ONE, C); }

sequence_thing(A) ::= seq_number(B).												{ MOVE(B, A); }
sequence_thing(A) ::= seq_number(B) COLON seq_number(C).							{ SET(A, L_JSON_EMPTY_ARR); JSON_SET(A, L_END_PLUS_ONE, B); JSON_SET(A, L_END_PLUS_ONE, C); }

seq_number(A) ::= NUMBER(B).														{ MOVE(B, A); }
seq_number(A) ::= ASTERISK.															{ SET(A, L_ASTERISK_JSTR); }
seq_number(A) ::= DOLLAR.															{ SET(A, L_DOLLAR_JSTR); }
%else
json_sequence_set(A) ::= sequence_set(B).											{ SET(A, JSTR(B)); }
sequence_set(A) ::= atom(B).														{ SET(A, B); }	// Since this is longer than the match of the parts, it will take precedence over lexing the parts
sequence_set(A) ::= sequence_thing(B).												{ MOVE(B, A); }
sequence_set(A) ::= sequence_set(B) COMMA sequence_thing(C).						{ SETF(A, "%s,%s", Tcl_GetString(B), Tcl_GetString(C)); }

sequence_thing(A) ::= seq_number(B).												{ MOVE(B, A); }
sequence_thing(A) ::= seq_number(B) COLON seq_number(C).							{ SETF(A, "%s:%s", Tcl_GetString(B), Tcl_GetString(C)); }

seq_number(A) ::= NUMBER(B).														{ MOVE(B, A); }
seq_number(A) ::= ASTERISK(B).														{ MOVE(B, A); }
seq_number(A) ::= DOLLAR(B).														{ MOVE(B, A); }
%endif

/* msg_att handles all FETCH response attributes */
msg_att(A) ::= LPAREN msg_att_list(B) RPAREN.										{ MOVE(B, A); }
msg_att_list(A) ::= .																{ SET(A, L_JSON_EMPTY_OBJ); }
msg_att_list(A) ::= msg_att_item(B).												{ TAKE(L__KEY, t1); JSON_SET(A, TCLLIST(t1), B); }
msg_att_list(A) ::= msg_att_list(B) msg_att_item(C).								{ TAKE(L__KEY, t1); MOVE(B, A); JSON_SET(A, TCLLIST(t1), C); }

/* Dynamic attributes (MAY change for a message) */
msg_att_item(A) ::= FLAGS flag_list(B).												{ STASH(L__KEY, STROBJ("FLAGS"));	MOVE(B, A); }

/* Static attributes (MUST NOT change for a message) */
msg_att_item(A) ::= ENVELOPE envelope(V).											{ STASH(L__KEY,  "ENVELOPE");													MOVE(V, A); }
msg_att_item(A) ::= INTERNALDATE json_string(V).									{ STASH(L__KEY,  "INTERNALDATE");												MOVE(V, A); }
msg_att_item(A) ::= RFC822_SIZE NUMBER(V).											{ STASH(L__KEY,  "RFC822.SIZE");												MOVE(V, A); }
msg_att_item(A) ::= BODY body(V).													{ STASH(L__KEY,  "BODYSTRUCTURE");												MOVE(V, A); }
msg_att_item(A) ::= BODYSTRUCTURE body(V).											{ STASH(L__KEY,  "BODYSTRUCTURE");												MOVE(V, A); }
msg_att_item(A) ::= BODY section(S) json_nstring(V).								{ STASHF(L__KEY, "BODY[%s]",			Tcl_GetString(S));						MOVE(V, A); }
msg_att_item(A) ::= BODY section(S) LANGLE NUMBER(O) RANGLE json_nstring(V).		{ STASHF(L__KEY, "BODY[%s]<%s>",		Tcl_GetString(S), Tcl_GetString(O));	MOVE(V, A); }
msg_att_item(A) ::= BODY_PEEK section(S) json_nstring(V).							{ STASHF(L__KEY, "BODY.PEEK[%s]",		Tcl_GetString(S));						MOVE(V, A); }
msg_att_item(A) ::= BODY_PEEK section(S) LANGLE NUMBER(O) RANGLE json_nstring(V).	{ STASHF(L__KEY, "BODY.PEEK[%s]<%s>",	Tcl_GetString(S), Tcl_GetString(O));	MOVE(V, A); }
msg_att_item(A) ::= UID NUMBER(V).													{ STASH(L__KEY,  "UID");														MOVE(V, A); }
msg_att_item(A) ::= RFC822 json_nstring(V).											{ STASH(L__KEY,  "RFC822");														MOVE(V, A); }
msg_att_item(A) ::= RFC822_HEADER json_nstring(V).									{ STASH(L__KEY,  "RFC822.HEADER");												MOVE(V, A); }
msg_att_item(A) ::= RFC822_TEXT json_nstring(V).									{ STASH(L__KEY,  "RFC822.TEXT");												MOVE(V, A); }
msg_att_item(A) ::= BINARY section_binary(S) json_nstring(V).						{ STASHF(L__KEY, "BINARY[%s]",			Tcl_GetString(S));						MOVE(V, A); }
msg_att_item(A) ::= BINARY_PEEK section_binary(S) json_nstring(V).					{ STASHF(L__KEY, "BINARY.PEEK[%s]",		Tcl_GetString(S));						MOVE(V, A); }
msg_att_item(A) ::= BINARY_SIZE section_binary(S) NUMBER(V).						{ STASHF(L__KEY, "BINARY.SIZE[%s]",		Tcl_GetString(S));						MOVE(V, A); }
msg_att_item(A) ::= X_GM_MSGID NUMBER(V).											{ STASH(L__KEY,  "X-GM-MSGID");													MOVE(V, A); }
msg_att_item(A) ::= X_GM_LABELS utf7_astring_list(V).								{ STASH(L__KEY,  "X-GM-LABELS");												MOVE(V, A); }
//msg_att_item(A) ::= MODSEQ LPAREN number(V) RPAREN.								{ STASH(L__KEY,  "MODSEQ");														MOVE(V, A); }

section_binary(A) ::= LBRACKET section_part(B) RBRACKET.	{ MOVE(B, A); }
section_binary(A) ::= LBRACKET RBRACKET.					{ SET(A, L_EMPTY); }

/* Section handles the section specification for BODY[] and similar tokens */
section(A) ::= LBRACKET RBRACKET.							{ SET(A, L_EMPTY); }
section(A) ::= LBRACKET section_spec(B) RBRACKET.			{ MOVE(B, A); }

section_spec(A) ::= section_msgtext(B).						{ MOVE(B, A); }
section_spec(A) ::= section_part(B).						{ MOVE(B, A); }
section_spec(A) ::= section_part(B) DOT section_text(C).	{ SETF(A, "%s.%s", Tcl_GetString(B), Tcl_GetString(C)); }

section_part(A) ::= NUMBER(B).								{ MOVE(B, A); }
section_part(A) ::= section_part(B) DOT NUMBER(C).			{ SETF(A, "%s.%s", Tcl_GetString(B), Tcl_GetString(C)); }

section_text(A) ::= section_msgtext(B).						{ MOVE(B, A); }
section_text(A) ::= MIME.									{ SET(A, "MIME"); }

section_msgtext(A) ::= HEADER(F).							{ SET(A, F); }
section_msgtext(A) ::= HEADER_FIELDS(F) header_list(B).		{ SETF(A, "%s %s", Tcl_GetString(F), Tcl_GetString(B)); }
section_msgtext(A) ::= HEADER_FIELDS_NOT(F) header_list(B).	{ SETF(A, "%s %s", Tcl_GetString(F), Tcl_GetString(B)); }

header_list(A) ::= LPAREN header_list_inner(V) RPAREN.		{ SETF(A, "(%s)", Tcl_GetString(V)); }
header_list_inner(A) ::= astring(B).						{ SET(A, Tcl_NewListObj(1, &B)); }
header_list_inner(A) ::= header_list_inner(B) astring(H).	{ MOVE(B, A); UNSHARE(A);	TEST_OK_LABEL(finally, code, Tcl_ListObjAppendElement(interp, A, H)); }

utf7_astring_list(A) ::= LPAREN utf7_astrings(B) RPAREN.	{ MOVE(B, A); }
utf7_astrings(A) ::= utf7_astring(B).						{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); }
utf7_astrings(A) ::= utf7_astrings(B) utf7_astring(C).		{ MOVE(B, A);				JSON_SET(A, L_END_PLUS_ONE, C); }
utf7_astring(A) ::= astring(B).								{
	// TODO: Decode UTF-7
	MOVE(B, A); 
}

/* Envelope parser rules */
envelope(A) ::= LPAREN json_nstring(D) json_nstring(S) env_mail_list(F) env_mail_list(X) env_mail_list(R) env_mail_list(T) env_mail_list(C) env_mail_list(B) json_nstring(I) json_nstring(Z) RPAREN. {
	JSON_SET(A, "date", D);
	JSON_SET(A, "subject", S);
	JSON_SET(A, "from", F);
	JSON_SET(A, "sender", X);
	JSON_SET(A, "reply-to", R);
	JSON_SET(A, "to", T);
	JSON_SET(A, "cc", C);
	JSON_SET(A, "bcc", B);
	JSON_SET(A, "in-reply-to", I);
	JSON_SET(A, "message-id", Z);
}

env_mail_list(A) ::= LPAREN RPAREN.					{ SET(A, L_JSON_EMPTY_ARR); }
env_mail_list(A) ::= LPAREN addr_list(L) RPAREN.	{ MOVE(L, A); }
env_mail_list(A) ::= NIL.							{ SET(A, L_JSON_NULL); }

addr_list(A) ::= address(B).						{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); }
addr_list(A) ::= addr_list(B) address(C).			{ MOVE(B, A);				JSON_SET(A, L_END_PLUS_ONE, C); }

// address is a JSON object
address(A) ::= LPAREN json_nstring(N) json_nstring(O) json_nstring(M) json_nstring(H) RPAREN. {
	JSON_SET(A, "name", N);
	JSON_SET(A, "obsolete_adl", O);	// Obsolete
	JSON_SET(A, "mailbox", M);
	JSON_SET(A, "host", H);
}

/* Body structure parser rules */
body(A) ::= LPAREN body_type_1part(B) RPAREN.		{ SET_JSON_ARR(A, B); }
body(A) ::= LPAREN body_type_mpart(B) RPAREN.		{ MOVE(B, A); }

// body_type_1part is a JSON object with keys "media", "fields", "lines"?, "ext"?, "envelope"?, "body"?
body_type_1part(A) ::= body_base(B).					{ MOVE(B, A); }
body_type_1part(A) ::= body_base(B) body_ext_1part(C).	{ MOVE(B, A); JSON_SET(A, "ext", C); }

body_base(A) ::= media_type(M) body_fields(F). {
	JSON_SET(A, "media",	M);
	JSON_SET(A, "fields",	F);
}

body_base(A) ::= media_type(M) body_fields(F) NUMBER(L). {
	JSON_SET(A, "media",	M);
	JSON_SET(A, "fields",	F);
	JSON_SET(A, "lines",	L);
}

body_base(A) ::= media_type(M) body_fields(F) envelope(E) body(B) NUMBER(L). {
	JSON_SET(A, "media",	M);
	JSON_SET(A, "fields",	F);
	JSON_SET(A, "envelope",	E);
	JSON_SET(A, "body",		B);
	JSON_SET(A, "lines",	L);
}

body_type_mpart(A) ::= body_list(L) string(M).						{ JSON_SET(A, "subtype", M); JSON_SET(A, "parts", L); }
body_type_mpart(A) ::= body_list(L) string(M) body_ext_mpart(E).	{ JSON_SET(A, "subtype", M); JSON_SET(A, "parts", L); JSON_SET(A, "ext", E); }

// body_list is a JSON array of body parts
body_list(A) ::= body(B).						{ SET_JSON_ARR(A, B); }
body_list(A) ::= body_list(L) body(B).			{ MOVE(L, A); JSON_SET(A, L_END_PLUS_ONE, B); }

media_type(A) ::= media_part(T) media_part(S).	{ SETF(A, "%s/%s", Tcl_GetString(T), Tcl_GetString(S)); }

media_part(A) ::= string(B).	{ MOVE(B, A); }
media_part(A) ::= atom(B).		{ MOVE(B, A); }

body_fields(A) ::= body_fld_param(P) json_nstring(I) json_nstring(D) body_fld_enc(E) NUMBER(O). {
	JSON_SET(A, "params",		P);
	JSON_SET(A, "id",			I);
	JSON_SET(A, "desc",			D);
	JSON_SET(A, "encoding",		E);
	JSON_SET(A, "octets",		O);
}

body_fld_param(A) ::= LPAREN string_list(L) RPAREN.		{ MOVE(L, A); }
body_fld_param(A) ::= NIL.								{ SET(A, L_JSON_NULL); }

body_fld_enc(A) ::= string(B).				{ MOVE(B, A); }
body_fld_enc(A) ::= LPAREN atom(B) RPAREN.	{ MOVE(B, A); }

body_ext_1part(A) ::= json_nstring(M).																				{ JSON_SET(A, "md5", M); }
body_ext_1part(A) ::= json_nstring(M) body_fld_dsp(D).																{ JSON_SET(A, "md5", M); JSON_SET(A, "dsp", D); }
body_ext_1part(A) ::= json_nstring(M) body_fld_dsp(D) body_fld_lang(L).												{ JSON_SET(A, "md5", M); JSON_SET(A, "dsp", D); JSON_SET(A, "lang", L); }
body_ext_1part(A) ::= json_nstring(M) body_fld_dsp(D) body_fld_lang(L) json_nstring(X).								{ JSON_SET(A, "md5", M); JSON_SET(A, "dsp", D); JSON_SET(A, "lang", L); JSON_SET(A, "loc", X); }
body_ext_1part(A) ::= json_nstring(M) body_fld_dsp(D) body_fld_lang(L) json_nstring(X) body_extension_list(E).		{ JSON_SET(A, "md5", M); JSON_SET(A, "dsp", D); JSON_SET(A, "lang", L); JSON_SET(A, "loc", X); JSON_SET(A, "ext", E); }

body_ext_mpart(A) ::= body_fld_param(P).																			{ JSON_SET(A, "params", P); }
body_ext_mpart(A) ::= body_fld_param(P) body_fld_dsp(D).															{ JSON_SET(A, "params", P); JSON_SET(A, "dsp", D); }
body_ext_mpart(A) ::= body_fld_param(P) body_fld_dsp(D) body_fld_lang(L).											{ JSON_SET(A, "params", P); JSON_SET(A, "dsp", D); JSON_SET(A, "lang", L); }
body_ext_mpart(A) ::= body_fld_param(P) body_fld_dsp(D) body_fld_lang(L) json_nstring(X).							{ JSON_SET(A, "params", P); JSON_SET(A, "dsp", D); JSON_SET(A, "lang", L); JSON_SET(A, "loc", X); }
body_ext_mpart(A) ::= body_fld_param(P) body_fld_dsp(D) body_fld_lang(L) json_nstring(X) body_extension_list(E).	{ JSON_SET(A, "params", P); JSON_SET(A, "dsp", D); JSON_SET(A, "lang", L); JSON_SET(A, "loc", X); JSON_SET(A, "ext", E); }

body_fld_dsp(A) ::= LPAREN string(S) body_fld_param(P) RPAREN.		{ JSON_SET(A, "disposition", S); JSON_SET(A, "params", P); }
body_fld_dsp(A) ::= NIL.												{ SET(A, L_JSON_NULL); }

body_fld_lang(A) ::= json_nstring(B).					{ SET_JSON_ARR(A, B); }
body_fld_lang(A) ::= LPAREN string_list(L) RPAREN.		{ MOVE(L, A); }

body_extension_list(A) ::= body_extension(E).							{ SET_JSON_ARR(A, E); }
body_extension_list(A) ::= body_extension_list(L) body_extension(E).	{ MOVE(L, A); JSON_SET(A, L_END_PLUS_ONE, E); }

body_extension(A) ::= json_nstring(B).							{ MOVE(B, A); }
body_extension(A) ::= NUMBER(B).								{ MOVE(B, A); }
body_extension(A) ::= LPAREN body_extension_list(B) RPAREN.		{ MOVE(B, A); }

mailbox_list(A) ::= LPAREN mbx_list_flags(F) RPAREN json_nstring(D) json_astring(M) mbox_list_extended(E). {
	JSON_SET(A, "flags",		F);
	JSON_SET(A, "delimiter",	D);
	JSON_SET(A, "mailbox",		M);
	if (E) JSON_SET(A, "ext",	E);
}

mbox_list_extended(A) ::= LPAREN mbox_list_extended_item_list(E) RPAREN.	{ MOVE(E, A); }
mbox_list_extended(A) ::= .													{ SET(A, NULL); }

mbox_list_extended_item_list(A) ::= .															{ SET(A, L_JSON_EMPTY_OBJ); }
mbox_list_extended_item_list(A) ::= mbox_list_extended_item(I).									{				TAKE(L__KEY, t1);	JSON_SET(A, t1, I); }
mbox_list_extended_item_list(A) ::= mbox_list_extended_item_list(B) mbox_list_extended_item(I).	{ MOVE(B, A);	TAKE(L__KEY, t1);	JSON_SET(A, t1, I); }

mbox_list_extended_item(A) ::= astring(T) tagged_ext_val(V).	{ STASH(L__KEY, T); MOVE(V, A); }

tagged_ext_val(A) ::= tagged_ext_simple(B).						{ MOVE(B, A); }
tagged_ext_val(A) ::= LPAREN tagged_ext_comp(B) RPAREN.			{ MOVE(B, A); }

tagged_ext_simple(A) ::= json_sequence_set(B).					{ MOVE(B, A); }

tagged_ext_comp(A) ::= astring(B).								{ SET_JSON_ARR(A, JSTR(B)); }
tagged_ext_comp(A) ::= tagged_ext_comp(B) tagged_ext_comp(C).	{ MOVE(B, A); JSON_SET(A, L_END_PLUS_ONE, C); }
tagged_ext_comp(A) ::= LPAREN tagged_ext_comp(B) RPAREN.		{ SET_JSON_ARR(t1, B); SET_JSON_ARR(A, t1); }

mbx_list_flags(A) ::= .											{ SET(A, L_JSON_EMPTY_ARR); }
mbx_list_flags(A) ::= FLAG(F).									{ SET_JSON_ARR(A, JSTR(F)); }
mbx_list_flags(A) ::= mbx_list_flags(L) FLAG(F).				{ MOVE(L, A); JSON_SET(A, L_END_PLUS_ONE, JSTR(F)); }

/* Status response rules */
status_att_list(A) ::= .										{ SET(A, L_JSON_EMPTY_OBJ); }
status_att_list(A) ::= status_att_val(B).						{ 				TAKE(L__KEY, t1);	JSON_SET(A, t1, B); }
status_att_list(A) ::= status_att_list(B) status_att_val(C).	{ MOVE(B, A);	TAKE(L__KEY, t1);	JSON_SET(A, t1, C); }

status_att_val(A) ::= MESSAGES(K)    NUMBER(B).		{ STASH(L__KEY, K);		MOVE(B, A); }
status_att_val(A) ::= RECENT(K)      NUMBER(B).		{ STASH(L__KEY, K);		MOVE(B, A); }
status_att_val(A) ::= UIDNEXT(K)     NUMBER(B).		{ STASH(L__KEY, K);		MOVE(B, A); }
status_att_val(A) ::= UIDVALIDITY(K) NUMBER(B).		{ STASH(L__KEY, K);		MOVE(B, A); }
status_att_val(A) ::= UNSEEN(K)      NUMBER(B).		{ STASH(L__KEY, K);		MOVE(B, A); }
status_att_val(A) ::= DELETED(K)     NUMBER(B).		{ STASH(L__KEY, K);		MOVE(B, A); }
status_att_val(A) ::= SIZE(K)        NUMBER(B).		{ STASH(L__KEY, K);		MOVE(B, A); }

astring(A) ::= atom(B).			{ MOVE(B, A); }
astring(A) ::= string(B).		{ MOVE(B, A); }

json_astring(A) ::= astring(B).	{ SET(A, JSTR(B)); }

string(A) ::= QUOTED_STRING(B).						{ MOVE(B, A); }
string(A) ::= LITERAL_HEADER CRLF LITERAL_DATA(B).	{ MOVE(B, A); }
string(A) ::= LITERAL_HEADER CRLF LITERAL8_DATA(B).	{ MOVE(B, A); }

json_string(A) ::= string(B).	{ SET(A, JSTR(B)); }

//nstring(A) ::= string(B).		{ MOVE(B, A); }
//nstring(A) ::= NIL.				{ SET(A, L_EMPTY); }

json_nstring(A) ::= string(B).	{ SET(A, JSTR(B)); }
json_nstring(A) ::= NIL.		{ SET(A, L_JSON_NULL); }

json_atom(A) ::= atom(B).		{ SET(A, JSTR(B)); }

// namespace is a JSON array or null
namespace(A) ::= NIL.								{ SET(A, L_JSON_NULL); }
namespace(A) ::= LPAREN namespace_list(B) RPAREN.	{ MOVE(B, A); }

// namespace_list is a JSON array
namespace_list(A) ::= namespace_item(B).					{ SET(A, L_JSON_EMPTY_ARR);	JSON_SET(A, L_END_PLUS_ONE, B); }
namespace_list(A) ::= namespace_list(C) namespace_item(B).	{ MOVE(C, A);				JSON_SET(A, L_END_PLUS_ONE, B); }

// namespace_object is a JSON object
namespace_item(A) ::= LPAREN string(P) delimiter(D) namespace_extensions(E) RPAREN. {
	JSON_SET(A, "prefix", P);
	JSON_SET(A, "delimiter", D);
	if (E) JSON_SET(A, "ext", E);
}

// namespace_item is a JSON object or (void*)NULL
namespace_extensions ::= .
namespace_extensions(A) ::= namespace_extensions(B) namespace_extension(C).	{ MOVE(B, A); TAKE(L__KEY, t1); JSON_SET(A, t1, C); }
namespace_extension(A) ::= string(K) LPAREN string_list(V) RPAREN.			{ MOVE(V, A); STASH(L__KEY, K); }

// string_list is a JSON object with string values
string_list(A) ::= string_list_pair(B).					{				TAKE(L__KEY, t1);	JSON_SET(A, t1, B); }
string_list(A) ::= string_list(B) string_list_pair(C).	{ MOVE(B, A);	TAKE(L__KEY, t1);	JSON_SET(A, t1, C); }
string_list_pair(A) ::= string(K) json_string(V).		{ STASH(L__KEY, K); MOVE(V, A); }

// namespace_item is a JSON string or null
delimiter(A) ::= NIL.				{ SET(A, L_JSON_NULL); }
delimiter(A) ::= QUOTED_STRING(S).	{ SET(A, JSTR(S)); }


%parse_accept {
	//fprintf(stderr, "Parse accepted: (%s)\n", state->result ? Tcl_GetString(state->result) : "NULL");
	state->harvest = 1;
}

%parse_failure {
	//fprintf(stderr, "Parse failed\n");
	throw_parse_exception(state, lit[L_PARSE_FAILED_EXCEPTION], lit[L_PARSE_FAILED]);
	state->harvest = 1;
}

%stack_overflow {
	//fprintf(stderr, "Parse failed: stack overflow\n");
	throw_parse_exception(state, lit[L_STACK_OVERFLOW_EXCEPTION], lit[L_STACK_OVERFLOW]);
	state->harvest = 1;
}

%syntax_error {
	//fprintf(stderr, "Syntax error\n");
	throw_parse_exception(state, lit[L_SYNTAX_ERROR_EXCEPTION], lit[L_SYNTAX_ERROR]);
	state->harvest = 1;
}

%code {
#include "imap.c"
}

// vim: foldmethod=marker foldmarker=<<<,>>> ts=4 shiftwidth=4 noexpandtab
