grammar Bc;
// import lexerRules;

@header {
    import java.util.*;
    import java.math.*;
}

@parser::members {
    private static final BigDecimal ZERO = BigDecimal.ZERO;
    private static final BigDecimal ONE = BigDecimal.ONE;
    private int scale = 0;
    //default precision is set to 20 with rounding mode down
    private MathContext mathContext = new MathContext(20, RoundingMode.DOWN); 
    Map<String, BigDecimal> varMap = new HashMap<String, BigDecimal>();
    public BigDecimal eval(BigDecimal left, BigDecimal right, String op){
        if(op.equals("^"))
            return left.pow(right.intValue());

        if(op.equals("%"))
            return left.remainder(right);

        if(op.equals("*"))
            return left.multiply(right);

        if(op.equals("/"))
            return left.divide(right, scale, RoundingMode.DOWN);
        
        if(op.equals("+"))
            return left.add(right);

        return left.subtract(right); 
    }

    public BigDecimal evalUnary(String var, String op, boolean isPost){
        BigDecimal num = varMap.getOrDefault(var, ZERO);
        BigDecimal result = null;
        
        if(op.equals("++")){
            result = num.add(ONE);
        }else if(op.equals("--")){
            result = num.subtract(ONE);
        }
        
        varMap.put(var, result);
        return isPost ? num : result;
    }

    public BigDecimal evalBoolean(BigDecimal left, BigDecimal right, String op){
        BigDecimal result = null;

        if(op.equals("!")){
            result = left.equals(ZERO) ? ONE : ZERO;
        }else if(op.equals("&&")){
            result = !left.equals(ZERO) && !right.equals(ZERO) ? ONE : ZERO;
        }else{
            result = !left.equals(ZERO) || !right.equals(ZERO) ? ONE : ZERO;
        }

        return result;
    }

    public BigDecimal sin(BigDecimal value){
        return new BigDecimal(Math.sin(value.doubleValue()), mathContext);
    }

    public BigDecimal cos(BigDecimal value){
        return new BigDecimal(Math.cos(value.doubleValue()), mathContext);
    }

    public BigDecimal log(BigDecimal value){
        return new BigDecimal(Math.log(value.doubleValue()), mathContext);
    }

    public BigDecimal exp(BigDecimal value){
        return new BigDecimal(Math.exp(value.doubleValue()), mathContext);
    }

    /* source: StackOverflow */
    public BigDecimal sqrt(BigDecimal num){
        if(num.equals(ZERO))
            return ZERO;

        RoundingMode mode = RoundingMode.FLOOR;
        BigDecimal sqrt = new BigDecimal(1);
        BigDecimal store = new BigDecimal(num.toString());
        boolean first = true;
        sqrt.setScale(scale, mode);

        do{
            if (!first){
                store = new BigDecimal(sqrt.toString());
            }else{
                first = false;
            }

            store.setScale(scale, mode);
            sqrt = num.divide(store, scale, mode).add(store).divide(
                    BigDecimal.valueOf(2), scale, mode);
        }while (!store.equals(sqrt));

        return sqrt.setScale(scale, mode);
    }

    public void setScale(int newScale){
        scale = newScale;
    }

    public void print(BigDecimal result){
        if(result == null) return;
        varMap.put("last", result);
        System.out.println(result);    
    }

}

bc          : calc;

calc        : expression                    { print($expression.result); }
            ;

expression returns [BigDecimal result]
            : op = ( INC | DEC) variable    { $result = evalUnary($variable.text, $op.text, false);}
            | variable op = ( INC | DEC)    { $result = evalUnary($variable.text, $op.text, true);}
            | SUB variable                  { $result = eval(BigDecimal.ZERO, $variable.value, $SUB.text);}
            | left = expression POW right = expression 
                                            { $result = eval($left.result, $right.result, $POW.text);}
            | left = expression op = (MUL | DIV) right = expression 
                                            { $result = eval($left.result, $right.result, $op.text);}
            | left = expression MOD right = expression
                                            { $result = eval($left.result, $right.result, $MOD.text);}
            | left = expression op = (ADD | SUB) right = expression
                                            { $result = eval($left.result, $right.result, $op.text);}
            | NOT expression
                                            { $result = evalBoolean($expression.result, $expression.result, $NOT.text);}
            | left = expression AND right = expression
                                            { $result = evalBoolean($left.result, $right.result, $AND.text);}
            | left = expression OR right = expression
                                            { $result = evalBoolean($left.result, $right.result, $OR.text);}
            | LPAREN expression RPAREN      { $result = $expression.result;}
            | READ LPAREN expression RPAREN { $result = $expression.result;}
            | SQRT LPAREN expression RPAREN { $result = sqrt($expression.result);}
            | SIN LPAREN expression RPAREN  { $result = sin($expression.result);}
            | COS LPAREN expression RPAREN  { $result = cos($expression.result);}
            | LOG LPAREN expression RPAREN  { $result = log($expression.result);}
            | EXP LPAREN expression RPAREN  { $result = exp($expression.result);}
            | variable op = (MUL | DIV | ADD | SUB | MOD | POW) EQUAL expression
                                            { varMap.put($variable.text, eval($variable.value, $expression.result, $op.text)); }
            | variable EQUAL expression     { varMap.put($variable.text, $expression.result);}
            | variable EQUAL read           {
                                              $result = $read.value;
                                              varMap.put($variable.text, $result);
                                            }
            | SCALE EQUAL expression        { setScale($expression.result.intValue()); }
            | variable                      { $result = $variable.value;}
            | number                        { $result = $number.value; }
            | last                          { $result = $last.value; }
            ;
            

variable returns [BigDecimal value] 
            : VARIABLE                      { $value = varMap.getOrDefault($VARIABLE.text, new BigDecimal(0)); }
            ;

number returns [BigDecimal value]
            : NUMBER                        { $value = new BigDecimal($NUMBER.text); }
            ;
read  returns [BigDecimal value]
            : READ number                   { $value = $number.value; }
            ;
last  returns [BigDecimal value]
            : LAST                          { $value = varMap.getOrDefault($LAST.text, ZERO); }
            ;
/*
    TO DO: print expressions
    ->  Statements: expressions (print value on the screen when executed), 
 */

 
/* Special functions */
SCALE       : 'scale'
            ;

READ        : 'read()' NEWLINE
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
ADD         : '+'
            ;

SUB         : '-'
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

/* Terminating character */
SEMICOLON   : ';'
            ;

/* Matches variables */
VARIABLE    : [a-z]+[0-9]*;

/*  Matches whole or real number */
NUMBER      : [0-9]+('.'[0-9]+)?;

/* Matches new line */
NEWLINE     : '\r'?'\n';

/* Mathces single line comment */
SLCMNT      : '#'.*?'\n'       ->  skip;

/* Matches multiline comment */
MLCMNT      : '/*'.*?'*/'       ->  skip;

WS          : [ \t\r\n]+        ->  skip ;
