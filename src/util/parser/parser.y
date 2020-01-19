/* DEFINITIONS SECTION */
/* Everything between %{ ... %} is copied verbatim to the start of the parser generated C code. */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "GLOBALS.h"                    /* Contains the custom Linux_SystemSetting classname _SETTINGCLASSNAME */

#include "cmpidt.h"                     /* Contains CIM type definitions */
static CMPIType propertytype;                  /* CIM type of the current property */

extern FILE * NFSv4yyout;
extern char * NFSv4comments;

/* DEFINE ANY GLOBAL VARS HERE */
static char * secname;				/* String to construct security property name */
static int true = 1;

static void startinstance (char * classname);
static void endinstance();
static void startproperty (char * name, CMPIType type);
static void endproperty();
static void setvalue (void * value);

%}

/* All possible CIM property types that can be returned by the lexer */
%union {
   CMPIBoolean          boolean;
   CMPIChar16           char16;
   CMPIUint8            uint8;
   CMPIUint16           uint16;
   CMPIUint32           uint32;
   CMPIUint64           uint64;
   CMPISint8            sint8;
   CMPISint16           sint16;
   CMPISint32           sint32;
   CMPISint64           sint64;
   CMPIReal32           real32;
   CMPIReal64           real64;
   /* Note - we override the CIM definition of string and dateTime to make these data types
      easier to handle in the lexer/parser. Both are instead implemented as simple text strings. */
   char *               string;
   char *               dateTime;
}

/* DEFINE SIMPLE (UNTYPED) LEXICAL TOKENS HERE */
%token PSEUDO SECURITY

/* DEFINE LEXICAL TOKENS THAT RETURN A VALUE HERE, ALONG WITH THEIR RETURN TYPE */
%token <string> SECURITY_VALUE 
%token <string> PERMISSION
%token <string> PATHNAME

/* END OF DEFINITIONS SECTION */
%%
/* RULES SECTION */

/* DESCRIBE THE STRUCTURE OF THE CONFIGURATION FILE, SYNTAX OF EACH ENTRY, ETC */

/* The NFSv4 config file contains one or more exported directory stanzas */
stanzas:	/* empty */
	|	stanza stanzas
	;

/* Each stanza contains the source dir, dest dir (optional), r/w permission (optional) and security options (optional) */ 
stanza:		PATHNAME	{
				startinstance(_SETTINGCLASSNAME);
				startproperty("SettingID",CMPI_string);
				setvalue($1);
				endproperty();
				startproperty("Directory",CMPI_string);
				setvalue($1);
				endproperty();
				free($1);
				}
		options		{
                                /* Check if there are any comments pending */
                                if (NFSv4comments != NULL) {
                                   startproperty("Description",CMPI_string);
                                   /* Strip off the trailing newline */
                                   if (NFSv4comments[strlen(NFSv4comments)-1] == '\n') NFSv4comments[strlen(NFSv4comments)-1] = '\0';
                                   setvalue(NFSv4comments);
                                   endproperty();
                                   free(NFSv4comments); NFSv4comments = NULL;
                                }
				endinstance();
				}
	;

options:	'(' ')'
	|	'(' PSEUDO '=' PATHNAME {
				startproperty("PseudoPath",CMPI_string);
				setvalue($4); free($4);
				endproperty();
				}
		permsec
	;

permsec:	')'
	|	',' permission ')'
	|	',' SECURITY '=' security_values ')'
	|	',' permission ',' SECURITY '=' security_values ')'
	;

permission:	PERMISSION	{
				startproperty("Permission",CMPI_string);
                                setvalue($1); free($1);
                                endproperty();
				}
	;

/* Security settings may contain one or more security options */
security_values:	security_value
	|		security_value ':' security_values
	;	

security_value:		SECURITY_VALUE {
				secname = malloc(strlen($1)+10);
				sprintf(secname, "Security_%s", $1);
				free($1);
				startproperty(secname,CMPI_boolean);
				setvalue(&true);
				free(secname);
				endproperty();
				}

/* END OF RULES SECTION */
%%
/* USER SUBROUTINE SECTION */

/* DO NOT CHANGE ANYTHING BELOW THIS LINE */

/* XML CIM output subroutines */

static void startinstance (char * classname)
/* Start an XML CIM instance specification */
{
   fprintf(NFSv4yyout, "<INSTANCE CLASSNAME=\"%s\">\n", classname);
}

static void endinstance()
/* End XML CIM instance */
{
   fprintf(NFSv4yyout, "</INSTANCE>\n");
}

static void startproperty (char * name, CMPIType type)
/* Start an XML CIM property specification */
{
   fprintf(NFSv4yyout, " <PROPERTY NAME=\"%s\"", name);
   propertytype = type;
   switch(propertytype) {
      case CMPI_boolean:        fprintf(NFSv4yyout, " TYPE=\"boolean\""); break;
      case CMPI_char16:         fprintf(NFSv4yyout, " TYPE=\"char16\""); break;
      case CMPI_uint8:          fprintf(NFSv4yyout, " TYPE=\"uint8\""); break;
      case CMPI_sint8:          fprintf(NFSv4yyout, " TYPE=\"sint8\""); break;
      case CMPI_uint16:         fprintf(NFSv4yyout, " TYPE=\"uint16\""); break;
      case CMPI_sint16:         fprintf(NFSv4yyout, " TYPE=\"sint16\""); break;
      case CMPI_uint32:         fprintf(NFSv4yyout, " TYPE=\"uint32\""); break;
      case CMPI_sint32:         fprintf(NFSv4yyout, " TYPE=\"sint32\""); break;
      case CMPI_uint64:         fprintf(NFSv4yyout, " TYPE=\"uint64\""); break;
      case CMPI_sint64:         fprintf(NFSv4yyout, " TYPE=\"sint64\""); break;
      case CMPI_real32:         fprintf(NFSv4yyout, " TYPE=\"real32\""); break;
      case CMPI_real64:         fprintf(NFSv4yyout, " TYPE=\"real64\""); break;
      case CMPI_string:         fprintf(NFSv4yyout, " TYPE=\"string\""); break;
      case CMPI_dateTime:       fprintf(NFSv4yyout, " TYPE=\"dateTime\""); break;
      default:                  fprintf(stderr, "Unknown property type CMPIType=%d\n", propertytype);
                                exit(1);
                                break;
   }
   fprintf(NFSv4yyout, ">");
}

static void endproperty()
/* End XML CIM property */
{
   fprintf(NFSv4yyout, " </PROPERTY>\n");
}

static void setvalue (void * value)
/* Set an XML CIM value */
{
   fprintf(NFSv4yyout, " <VALUE>");
   switch(propertytype) {
      case CMPI_boolean:        fprintf(NFSv4yyout, *((CMPIBoolean *)value)? "true":"false"); break;
      case CMPI_char16:         fprintf(NFSv4yyout, "%c", *((CMPIChar16 *)value)); break;
      case CMPI_uint8:          fprintf(NFSv4yyout, "%d", *((CMPIUint8 *)value)); break;
      case CMPI_sint8:          fprintf(NFSv4yyout, "%d", *((CMPISint8 *)value)); break;
      case CMPI_uint16:         fprintf(NFSv4yyout, "%d", *((CMPIUint16 *)value)); break;
      case CMPI_sint16:         fprintf(NFSv4yyout, "%d", *((CMPISint16 *)value)); break;
      case CMPI_uint32:         fprintf(NFSv4yyout, "%d", *((CMPIUint32 *)value)); break;
      case CMPI_sint32:         fprintf(NFSv4yyout, "%d", *((CMPISint32 *)value)); break;
      case CMPI_uint64:         fprintf(NFSv4yyout, "%d", *((CMPIUint64 *)value)); break;
      case CMPI_sint64:         fprintf(NFSv4yyout, "%d", *((CMPISint64 *)value)); break;
      case CMPI_real32:         fprintf(NFSv4yyout, "%f", *((CMPIReal32 *)value)); break;
      case CMPI_real64:         fprintf(NFSv4yyout, "%f", *((CMPIReal64 *)value)); break;
      case CMPI_string:         fprintf(NFSv4yyout, "%s", (char *)value); break;
      case CMPI_dateTime:       fprintf(NFSv4yyout, "%s", (char *)value); break;
      default:                  fprintf(stderr, "Unknown property type CMPIType=%d\n", propertytype);
                                exit(1);
                                break;
   }
   fprintf(NFSv4yyout, "</VALUE>");
}


/* yacc parser subroutines */

int NFSv4yyparsefile(FILE * infile, FILE * outfile)
{
   NFSv4yyrestart(infile);
   NFSv4yyout = outfile;
   return(NFSv4yyparse());
}

int main ()
{
   return NFSv4yyparse();
}

