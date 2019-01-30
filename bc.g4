grammar Bc;

@header {
    import java.util.*;
    import java.math.*;
}

@parser::members {
    public static final BigDecimal ZERO = BigDecimal.ZERO;
    private int scale = 0;
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
            result = num.add(BigDecimal.ONE);
        }else if(op.equals("--")){
            result = num.subtract(BigDecimal.ONE);
        }
        
        varMap.put(var, result);
        return isPost ? num : result;
    }

    public void print(BigDecimal result){
        if(result == null) return;
        System.out.println(result);    
    }

}

bc          : calc+;

calc        : expression NEWLINE  {print($expression.result);}
            ;

// var <op>= expr need to cover this one!
expression returns [BigDecimal result]
            : INC variable
                {$result = evalUnary($variable.text, $INC.text, false);}
            | DEC variable
                {$result = evalUnary($variable.text, $DEC.text, false);}
            | variable INC 
                {$result = evalUnary($variable.text, $INC.text, true);}
            | variable DEC 
                {$result = evalUnary($variable.text, $DEC.text, true);}
            | SUB variable
                {$result = eval(BigDecimal.ZERO, $variable.value, $SUB.text);}
            | left = expression POW right = expression
                {$result = eval($left.result, $right.result, $POW.text);}
            | left = expression MUL right = expression 
                {$result = eval($left.result, $right.result, $MUL.text);}
            | left = expression DIV right = expression
                {$result = eval($left.result, $right.result, $DIV.text);}
            | left = expression MOD right = expression
                {$result = eval($left.result, $right.result, $MOD.text);}
            | left = expression ADD right = expression
                {$result = eval($left.result, $right.result, $ADD.text);}
            | left = expression SUB right = expression
                {$result = eval($left.result, $right.result, $SUB.text);}
            | '(' expression ')' {$result = $expression.result;}
            | variable {$result = $variable.value;}
            | variable EQUAL expression { varMap.put($variable.text, $expression.result);}
            | number  {$result = $number.value;}
            ;

variable returns [BigDecimal value] 
            : VARIABLE  { $value = varMap.getOrDefault($VARIABLE.text, new BigDecimal(0)); }
            ;

number returns [BigDecimal value]
            : NUMBER {  $value = new BigDecimal($NUMBER.text); }
            ;

// SCALE       

INC         : '++'
            ;

DEC         : '--'
            ;

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

WS          : [ \t\r\n]+        ->  skip ;