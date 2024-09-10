# Open the execution_times.txt file and read the lines
with open('execution_times.txt', 'r') as file:
    lines = file.readlines()

# Convert the lines to float numbers
times = [float(line.strip()) for line in lines]

# Calculate the average
average_time = sum(times) / len(times)

# Print the result
print(f"Average time: {average_time:.6f} seconds")

