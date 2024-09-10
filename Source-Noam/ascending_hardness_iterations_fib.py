import os

# Function to generate the OCaml Fibonacci code with changing `num`
def generate_fib_code(num):
    return f"""
fun print (x) {{
  _prim_print x
}}

fun fib (n) {{
  switch
  | n <= 1 -> {{ 1 }}
  | 1 -> {{ fib (n-1) + fib (n-2) }}
  end
}}

let () = print (fib {num})
"""
# Function to write the OCaml code to a file
def write_fib_code_to_file(num, iteration):
    filename = f"fib_expression_{iteration}.ml"
    expression = generate_fib_code(num)
    # Print the expression for debugging purposes
    print(f"Generated Fibonacci expression for iteration {iteration}: {expression}")
    with open(filename, "w") as f:
        f.write(expression)
    return filename

# Main loop for 7 iterations
for i in range(1, 31):
    num = i  # You can adjust how `num` changes according to the iteration

    # Generate and save the Fibonacci expression
    expression_file = write_fib_code_to_file(num, i)

    # Run the `run_300_times_with_time` script with the generated expression
    os.system(f"./run_300_times_with_time {expression_file}")

    # Read the execution times and print the average only
    with open("execution_times.txt", "r") as f:
        times = [float(line.strip()) for line in f.readlines() if line.strip()]
        average_time = sum(times) / len(times) if times else 0
        print(f"Iteration {i}: Average execution time: {average_time:.6f} seconds")

