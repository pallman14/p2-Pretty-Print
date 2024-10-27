%{
/*
*  Price, Gorana, Chris, Lian
*  p2.l
*/
#include <stdio.h>
#include "p2.h"

#define TRUE (1)
#define FALSE (0)

#define INDENT (4)

int line = 0;	    /* Holds the current line number (IDE lines start at 1) */
int column = 4;	    /* Sets the starting number of spaces at the beginning of a line */
int paren = 0;	    /* Flags if currently inside parentheses or brackets */
int inComment = 0;  /* Flags if currently within a comment */
int debug = 0;	    /* Flags if debug mode is active */

void write_indent();
void write_html();
void write_html_char(int);
void write_string();
void write_char();
void write_oct();
void write_hex();
void write_int();
void write_fp();
void write_id();
void write_begin();
void write_end();
void write_open();
void write_close();
void write_bopen();
void write_bclose();
void write_sep();
void write_op();
void write_inline();
void write_comment();
void write_comma();
void write_directive();

%}

%option	noyywrap
%option	yylineno

quote	\'
ditto	\"
delim	[ \t\n\v\r\f]
ws	{delim}+
alpha   [a-zA-Z_]
digit   [0-9]
oct	[0-7]
exp	[eE][+-]?{digit}+
hex     [{digit}a-fA-F]
id	{alpha}({alpha}|{digit})*
number	{digit}*\.{digit}*{exp}?

%%
{ws}				{ /* No action or return needed */ }
{quote}([^']|\\')*{quote}	write_char();
{ditto}([^"]|\\\")*{ditto}	write_string();
0{oct}+		                write_oct();
0(x|X){hex}+			    write_hex();
{digit}+		            write_int();
{number}                    write_fp();
"\{"		write_begin();
"\}"		write_end();
"\("		write_open();
"\)"		write_close();
"\["		write_bopen();
"\]"		write_bclose();
";"		write_sep();
","		write_comma();
"="             |
"+="            |
"-="            |
"*="            |
"/="            |
"%="            |
"<<="           |
"">>=""         |
"&="            |
"^="            |
"|="            |
"++"            |
"--"            |
"\+"            |
"-"             |
"\*"            |
"\/"            |
"%"             |
"~"             |
"=="            |
"!="            |
"<="            |
">="            |
"<"             |
">"             |
"&&"            |
"||"            |
"!"             |
"<<"            |
">>"            |
"&"             |
"|"             |
"^"             |
"?"             |
":"             |
sizeof          |
"::"		    write_op();	
{id}            write_id();
\/\/.*		    write_inline(); 
\/\*([^*]|(\*+[^*/]))*\*+\/    write_comment(); 
#.*   		    write_directive();		
.		printf("unrecognized input at line %d", yylineno);
%%


int main() {
    myInit();
    // Starts HTML preformatted code block
    printf("<html><pre>\n");
    // Outputs line number (d), left-aligned (-), occupying 'column' spaces
    // column is initially 4, so outputs 1___
    // Begins on line 0
    printf("%-*d",column, line++);
    
    // Initiates pattern matching and respective actions
    yylex();
    // Ends the HTML preformatted block
    printf("\n</pre></html>\n");
    return 0;
}

void write_indent() {
    // Outputs line number (d), left-aligned (-), occupying 'column' spaces
    // Initially, column is 4, so it outputs 1___
    printf("\n%-*d", column, line++);
}

void write_html_char(int c) {
    switch (c) {
    // Outputs specific characters in HTML-encoded format
    case '<':
        printf("&lt;");
        break;
    case '>':
        printf("&gt;");
        break;
    case '"':
        printf("&quot;");
        break;
    // Included as standard HTML encoding, though may not be necessary
    case '\'':
        printf("&apos;");
        break;
    case '&':
        printf("&amp;");
        break;
    case '\n':
        // If within a comment, goes to the next line;
        // otherwise, ignores the whitespace
        if (inComment) {
	    // Previously here; invokes write_indent();
            printf("\n%-*d", column, line++);
        }
        break;
    default:
        // Outputs character c as-is
        putchar(c);
    }
}

void write_html() {
    // Sets string s to the matched lexeme
    char *s = yytext;

    // Outputs each character in string s
    while (*s) {
	write_html_char(*s++);
    }
}

void write_char() {
    if (debug) {
    	fprintf(stderr, "write_char: %s\n", yytext);
    }
    
    // Character literals are styled in brown and underlined
    printf("<u><font color='brown'>");
    // write_html() outputs the lexeme in yytext
    write_html();
    // Ends brown color and underline
    printf("</font></u>");
}

void write_string() {
    if (debug) {
	fprintf(stderr, "write_string: %s\n", yytext);
    }
    
    // String literals are styled in red
    printf("<font color='red'>");
    // write_html() outputs the lexeme in yytext
    write_html();
    // Ends red color
    printf("</font>");
}

void write_oct() {
    if (debug) {
    	fprintf(stderr, "write_oct: %s\n", yytext);
    }
    
    // Octal numbers are styled in brown and italicized
    printf("<i><font color='brown'>");
    // write_html() outputs the lexeme in yytext
    write_html();
    // Ends brown color and italics
    printf("</font></i>");
}

void write_hex() {
    if (debug) {
	fprintf(stderr, "write_hex: %s\n", yytext);
    }
    
    // Hexadecimal numbers are styled in brown and italicized
    printf("<i><font color='brown'>");
    // write_html() outputs the lexeme in yytext
    write_html();
    // Ends brown color and italics
    printf("</font></i>");
}

void write_int() {
    if (debug) {
    	fprintf(stderr, "write_int: %s\n", yytext);
    }
    
    // Integers are styled in brown
    printf("<font color='brown'>");
    // write_html() outputs the lexeme in yytext
    write_html();
    // Ends brown color
    printf("</font>");
}

void write_fp() {
    if (debug) {
    	fprintf(stderr, "write_fp: %s\n", yytext);
    }
    
    // Floating point numbers are styled in brown
    printf("<font color='brown'>");
    // write_html() outputs the lexeme in yytext
    write_html();
    // Ends brown color
    printf("</font>");
}

void write_id() {
    int kw = FALSE;	// Identifies if the id is a keyword
    // Sets id as the varIndex of the identifier
    int id = lookupVar_index(yytext);

    // Previously checked for 0; now checks for -2 
    // since values 0, 1, and 2 are no longer used for local frame
    if (id == -2) {
    	// First occurrence of this ID; adds it to the symbol table, 
    	// which stores lexeme, token, and first appearance line
    	installID(yytext, ID, line);
    	// Sets the first ID’s name to the lexeme for reference
    	printf("<a name='%s'>", yytext);
    } else if (id >= 0) {
        // If ID already declared, sets destination to first occurrence, 
	// enabling navigation on click
    	printf("<a href='#%s'>", yytext);
    } else {
        // Highlights keywords in bold
    	printf("<b>");
    	kw = TRUE;
    }
    if (debug) {
    	fprintf(stderr, "write_id: %s; kw = %d\n", yytext, kw);
    }

    // Keywords and identifiers are both styled in blue
    printf("<font color='blue'>");
    write_html();
    printf("</font>");

    // Closes bold for keywords or anchor for variables.
    // Adds space after keywords but not after variables
    if (kw)  {
    	printf("</b>");
	putchar(' ');
    } else {
    	printf("</a>");
    }
}

void write_begin() {
    // Applies inline style, preferred over block style
    putchar(' ');
    write_html();
    // Increments indentation for the next line
    column += INDENT;
    // Advances to the next line with new indentation
    write_indent();
}

void write_end() {
    // Reduces indentation to match corresponding statement
    // Often preceded by a line from write_sep()
    column -= INDENT;
    // Advances to the next line with reduced indentation
    write_indent();
    // Outputs } and moves to the next line, keeping indentation
    write_html();
    write_indent();
}

void write_open() {
    // No spaces after opening parentheses, per preference
    write_html();
    paren++;
}

void write_close() {
    // Outputs ) without surrounding spaces
    write_html();
    paren--;
}

void write_bopen() {
    // Square brackets similarly require no spaces
    write_html();
    paren++;
}

void write_bclose() {
    // Outputs ] without surrounding spaces
    write_html();
    paren--;
}

void write_sep() {
    if (debug) {
	fprintf(stderr, "write_sep: %s\n", yytext);
    }
    // Outputs a semicolon; if inside parentheses or brackets,
    // appends a space; otherwise, moves to the next line
    write_html();
    if (!paren) {
	write_indent();
    } else  {
	putchar(' ');
    }
}

// Although unnecessary, improves readability of commas
void write_comma() {
    if (debug) {
        fprintf(stderr, "write_comma: %s\n", yytext);
    }
    // Outputs a comma, followed by a space
    write_html();
    putchar(' ');
}

void write_op() {
    if (debug) {
	fprintf(stderr, "write_op: %s\n", yytext);
    }
    // Adds spaces around operators
    // Slightly inconvenient in some cases, e.g., ( *  * p), but suitable for this example
    putchar(' ');
    // Outputs operator in bold
    printf("<b>");
    write_html();
    printf("</b>");
    putchar(' ');
}

void write_inline() {
    if(debug) {
        fprintf(stderr, "write_inline: %s\n", yytext);
    }
    // Inline comments appear in green
    printf("<font color = 'green'>");
    // Outputs inline comment at the current position, then moves to the next line
    write_html();
    printf("</font>");
    write_indent();
}

void write_comment() {
    if (debug) {
	fprintf(stderr, "write_comment: %s\n", yytext);
    }
    
    // Activates inComment, so if there’s a newline in the comment, 
    // HTML moves to the next line with matching indentation
    inComment = TRUE;
    
    // Surrounds with empty lines on both sides for clarity
    write_indent();
    // Colors the comment green
    printf("<font color='green'>");
    write_html();
    printf("</font>");
    
    // Outputs an empty line and advances to the next line
    write_indent();
    write_indent();
    inComment = FALSE;
}

void write_directive() {
    if(debug){
        fprintf(stderr, "write_directive: %s\n", yytext);
    }
    // Directives appear bold and magenta
    printf("<b><font color='magenta'>");
    write_html();
    printf("</font></b>");
    write_indent();
}