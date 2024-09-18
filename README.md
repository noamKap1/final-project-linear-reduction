# final-project-linear-reduction

This project provides tools for running and benchmarking our created OCaml models with fixed and variable programs.

## Commands

### Running Models with Fixed Programs

Three example programs are available in the `demos` directory. Some programs to evalute running a specific model:

1.
```bash
./runAvg needinput.ml 300
```
This will run the needinput.ml code with the specific model that runAvg was compile with for 300 times and print each one with the time it took to run.

2.
```bash
./combined_tool needinput.ml 
```
This will run the needinput.ml code with Noam's model - combined_tool, and print the outcome.

3.
```bash
./main needinput.ml
```
This will run the needinput.ml code with Ari's model - main, and print the outcome.

### Benchmarking

To run a model 300 times and measure average execution time:

```bash
./run_300_times_with_time needinput.ml
```

Example output:
```
Average execution time: 0.016490 seconds
Ran combine_tool.ml 500 times and saved execution times to execution_times.txt
```

And then you can view the saved execution times:
```bash
cat < execution_times.txt
```

### Running Models with Variable Programs

1. For ascending hardness iterations:
   ```bash
   python3 ascending_hardness_iterations.py
   ```

2. To calculate average execution times:
   ```bash
   python3 calculate_average.py
   ```

3. For ascending hardness iterations with Fibonacci:
   ```bash
   python3 ascending_hardness_iterations_fib.py
   ```

Note: Both `ascending_hardness_iterations.py` and `ascending_hardness_iterations_fib.py` use the `./run_300_times_with_time` file. To change the models being run, modify as explained now:
To switch between models:
(in running runAvg, run_300_times_with_time)
1. To edit the `runAvg.ml` file:
   ```bash
   nano runAvg.ml
   ```
Change the line:
   ```ocaml
   let command = Printf.sprintf "./combined_tool %s" input_file in
   ```
   to:
   ```ocaml
   let command = Printf.sprintf "./main %s y" input_file in
   ```
   (or vice versa)
and then recompile.
2. To edit the `run_300_times_with_time` file:
    ```bash
   nano run_300_times_with_time.ml
   ```
change the line:
   ```ocaml
     let command = Printf.sprintf "./main %s y> /dev/null" input_file in
   ```
   to:
   ```ocaml
     let command = Printf.sprintf "./combined_tool %s> /dev/null" input_file in
   ```
   (or vice versa)
and then recomplie.

## Compilation

Compile the project components using the following commands:
first, make sure all the files from Source-Noam and Source-Ari directories is downloaded to your directory.
This is the compile commands:
```bash
ocamlc -o run_300_times_with_time unix.cma run_300_times_with_time.ml
ocamlc -o combined_tool unix.cma -I +compiler-libs ocamlcommon.cma str.cma combined_tool.ml
ocamlopt -o main lexer.ml reducer.ml main.ml
ocamlc -o runAvg unix.cma runAvg.ml
```

### Detailed Explanation of Compilation Commands

1. `ocamlc -o run_300_times_with_time unix.cma run_300_times_with_time.ml`
   - This command compiles the `run_300_times_with_time.ml` file.
   - `ocamlc` is the OCaml bytecode compiler.
   - `-o run_300_times_with_time` specifies the output executable name.
   - `unix.cma` is a library that provides access to many Unix system calls.
   - `run_300_times_with_time.ml` is the source file being compiled.

2. `ocamlc -o combined_tool unix.cma -I +compiler-libs ocamlcommon.cma str.cma combined_tool.ml`
   - This command compiles the `combined_tool.ml` file.
   - `-I +compiler-libs` adds the compiler libraries to the search path.
   - `ocamlcommon.cma` is a library that provides access to the OCaml compiler's internal APIs.
   - `str.cma` is the OCaml string processing library.

3. `ocamlopt -o main lexer.ml reducer.ml main.ml`
   - This command compiles and links multiple source files into a native code executable.
   - `ocamlopt` is the OCaml native-code compiler.
   - `lexer.ml`, `reducer.ml`, and `main.ml` are the source files being compiled and linked.

4. `ocamlc -o runAvg unix.cma runAvg.ml`
   - This command compiles the `runAvg.ml` file.
   - It's similar to the first command but for a different source file.

These compilation commands create the necessary executables for running and benchmarking the models in the project.
