import os
from random import randint, choice

def generate_expression(depth, length):
    if depth == 0:
        return str(length)  

    string = ""
    for i in range(length):
        if depth > 0:
            string += "(" + generate_expression(depth - 1, length - 1) + ")"
        string += f" * {i}" 
        if i < length - 1:
            string += " + " 
    return string

def write_expression_to_file(depth, length, iteration):
    filename = f"expression_{iteration}.ml"
    expression = generate_expression(depth, length)
    print(f"Generated expression for iteration {iteration}: {expression}")
    with open(filename, "w") as f:
        f.write(f"_prim_print ({expression});")
    return filename

for i in range(1, 8):
    depth = i
    length = i
    expression_file = write_expression_to_file(depth, length, i)
    os.system(f"./run_300_times_with_time {expression_file}")
    with open("execution_times.txt", "r") as f:
        times = [float(line.strip()) for line in f.readlines() if line.strip()]
        average_time = sum(times) / len(times) if times else 0
        print(f"Iteration {i}: Average execution time: {average_time:.6f} seconds")
