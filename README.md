# bc
Basic Calculator (bc) ANTLR4 grammar with embedded actions.

##  Currently working Functionalities
  
    Comments: Single line (# ... ) and multi-line commens /* ... */
    Basic expressions with variables (++, --, -, =, <op>=)
    Boolean Expressions (&&, ||, !)
    Precedence of (+,-,*,/,%, etc)
    Special Expression: read() and sqrt()
    Statements: expressions value is printed on execution, print expresstions
    Math library functions: sin, cos, log, exp functions
    
    Note: New line is required after expression just like bc to  execute expressions.
          print expressions prints new line after evaluating each expression for readability.
          


##  Running the tests

### For file input
Type expression to a text file and run the following commands.

```
   antlr -no-listener Calculator.g4 && javac Calc*.java
   grun Calculator bc testfile.txt
```

### For interactive mode
Type expression directly to the console for instant response 
after running the following commands. 
```
   antlr -no-listener Calculator.g4 && javac Calc*.java
   java Calc
```
