# Compiler final project
My MiniLisp interpreter for compiler final project at NCU

### Compilation
Enter ```make build``` in the shell to compile the source code and link the object files; it will generate the binary interpreter into **bin** directory.

### Execution
Enter ```bin/interpreter``` to execute the MiniLisp interpreter.

### Prerequisites
1. bison ((GNU Bison) 3.5.1)
2. flex (2.6.4)
3. gcc

### Mechanism of the miniLisp interpreter
First, it only interpretes little Lisp expression; it doesn't even support function definition / declaration and function call.  

Internally, it works with a stack to handle expressoin evaluation. AST is not constucted. The interpreter just parses the source code and performs the specified behavior directly with the compiled C code within the interpreter itself.

