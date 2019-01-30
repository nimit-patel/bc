grammar bc;

@header {
    import java.util.*;
    import java.math.*;
}

@parser::members {
    Map<String, BigDecimal> varMap = new HashMap<String, BigDecimal>();
}

calc        : expression
                { System.out.println("Result :" +  varMap); }
            ;

// handle when variable is typed and value is assigned
// default value is 0
// variable = expr
// variable
// expression end on new line or semicolon
expression returns [BigDecimal result]: 
            | variable 
                {
                    $result = varMap.getOrDefault($variable.text, new BigDecimal(0));
                }
            | variable EQUAL expression 
                {
                    varMap.put($variable.text, $expression.result);
                }
            | number  {$result = $number.value;}
            ;

variable    : VARIABLE;

number returns [BigDecimal value]:
            | NUMBER 
            {  $value = new BigDecimal($NUMBER.text); }
            ;

EQUAL       : '='
            ;

SEMICOLON   : ';'
            ;

/* Matches variables */
VARIABLE    : [a-z]+[0-9]*;

/*  Matches whole or real number */
NUMBER      : [0-9]+('.'[0-9]+)?;

/* Matches new line */
NEWLINE     : '\r'?'\n';

/* Mathces single line comment */
SLCMNT      : '#' .*?           ->  skip;

/* Matches multiline comment */
MLCMNT      : '/*' .*? '*/'     ->  skip;

WS          : [ \t\r\n]+ -> skip ;