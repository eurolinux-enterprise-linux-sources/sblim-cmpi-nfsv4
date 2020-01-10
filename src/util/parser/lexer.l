	/*** WARNING - COMMENTS IN LEX MUST BE TAB INDENTED ***/

	/* DEFINITIONS SECTION */
	/* Everything between %{ ... %} is copied verbatim to the start of the lex generated C code. */

%{
#include <string.h>
#include "cmpidt.h"
#include "parser.h"
#ifndef YY_FLEX_LEX_COMPAT
int yylineno = 1;
#endif

char * NFSv4comments = NULL;		/* String buffer to accumulate comments */
%}

		/* Some useful regular expressions to use in the RULES section */
DIGIT		([0-9])
ALPHA		([A-Za-z])
ALPHANUMERIC	([A-Za-z0-9])
PUNCTUATION	([\,\.\:\(\)\-\!\"\'\`\^])
ARITHMATIC	([\+\-\*\/\<\>\=])
WHITESPACE	([\t ]+)
EOLN		(\n)
NUMBER		([0-9]+)
INTEGER		(-?[0-9]+)
REAL		(-?[0-9]+\.[0-9]+)
WORD		([A-Za-z]+)
QUOTEDTEXT	(\"[^"\n]*["\n])
FILENAME	([A-Za-z0-9\.][A-Za-z0-9\.\-\+\_]*)
PATHNAME	(\/?[A-Za-z0-9\.][A-Za-z0-9\.\-\+\_]*(\/[A-Za-z0-9\.][A-Za-z0-9\.\-\+\_]*)*\/?)
HOSTNAME	([A-Za-z][A-Za-z0-9\-\_]*(\.[A-Za-z][A-Za-z0-9\-\_]*)*)
IPADDR		([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)

	/* Use the default yywrap() behavior */
%option  noyywrap

	/* END OF DEFINITIONS SECTION */
%%
	/* RULES SECTION */
	/* DESCRIBE EVERY LEXICAL TOKEN/PATTERN FOLLOWED BY THE APPROPRIATE ACTION.
	   TYPICALLY THE ACTION RETURNS THE TOKEN IDENTIFIER AND ITS VALUE (IN YYLVAL) */

	/* The following simple lexical tokens only return the token identifier */

pseudo	{
	return(PSEUDO);
	}

sec	{
	return(SECURITY);
	}

	/* The following lexical tokens return the token identifier and the value of the token (in yylval) */

	/* Security option keywords */
none |
sys |
dh |
krb5 |
krb5i |
krb5p |
spkm3 |
spkm3i |
spkm3p |
lkey |
lkeyi |
lkeyp	{
	yylval.string = (char *)strdup(yytext);
	return(SECURITY_VALUE);
	}

	/* Read-write permission keywords */
ro |
rw	{
	yylval.string = (char *)strdup(yytext);
	return(PERMISSION);
	}

\/{PATHNAME}? {
	yylval.string = (char *)strdup(yytext);
	return(PATHNAME);
	}

	/* Ignore whitespace */
{WHITESPACE} ;

	/* Ignore comments */
\#(.*)\n {
	/* Extend the comments buffer */
	if (NFSv4comments == NULL) {
	   NFSv4comments = malloc(strlen(yytext)+1);
	   strcpy(NFSv4comments,"");
	} else {
	   char * newcomments = malloc(strlen(NFSv4comments)+strlen(yytext)+1);
	   strcpy(newcomments, NFSv4comments);
	   free(NFSv4comments);
	   NFSv4comments = newcomments;
	}

	/* Add this comment line to the comments buffer */
	strcat(NFSv4comments,yytext);
	}

	/* Return single character punctuation characters as-is */
.	{
	return(yytext[0]);
	}

	/* END OF RULES SECTION */
%%
	/* USER SUBROUTINE SECTION */
	/* Everything below is copied verbatim to the end of the lex generated C code. */

void yyerror(char *errmsg)
{
   fprintf(stderr, "NFSv4 parser, line %d: %s at '%s'\n", yylineno, errmsg, yytext);
}

