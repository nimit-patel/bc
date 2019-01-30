grammar bc;

comment     : SLCMNT
            | MLCMNT;

/*  Matches integer */
INT         : [0-9]+;

/* Mathces single line comment */
SLCMNT      : '#' .*?           ->  skip;

/* Matches multiline comment */
MLCMNT      : '/*' .*? '*/'     ->  skip;

/* Matches new line */
NEWLINE     : '\r'?'\n';
WS          : [ \t\r\n]+ -> skip ;