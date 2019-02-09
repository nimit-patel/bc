lexer grammar lexerRules;

/* Special functions */
SCALE       : 'scale'
            ;

READ        : 'read'
            ;

PRINT       : 'print'
            ;

LAST        : 'last'
            ;

/* Boolean operators precedence (highest to lowest): !, &&, || */
AND         : '&&'
            ;

OR          : '||'
            ;

NOT         : '!'
            ;

/* Unary operators */
INC         : '++'
            ;

DEC         : '--'
            ;

/* Binary operators (highest to lowest): *, /, +, -*/
PLUS        : '+'
            ;

MINUS       : '-'
            ;

DIV         : '/'
            ;

MUL         : '*'
            ;

MOD         : '%'
            ;

POW         : '^'
            ;
            
EQUAL       : '='
            ;

/* Math functions */
            
SQRT        : 'sqrt'
            ;

SIN         : 's'
            ;

COS         : 'c'
            ;

LOG         : 'l'
            ;

EXP         : 'e'
            ;

/* Extra Chracters */
LPAREN      : '('
            ;

RPAREN      : ')'
            ;

COMMA       : ','
            ;

/* Terminating character */
TERMINATOR  : ';'
            ;

/* Matches variables */
VARIABLE    : [a-z]+[0-9]*;

/*  Matches whole or real number */
NUMBER      : [0-9]+('.'[0-9]+)?;

/* Matches new line */
NEWLINE     : '\r\n';

/* Mathces single line comment */
SLCMNT      : '#'.*?'\r\n'          ->  skip;

/* Matches multiline comment */
MLCMNT      : '/*'.*?'*/''\r\n'?    ->  skip;

WS          : [ \t\r\n]+            ->  skip ;