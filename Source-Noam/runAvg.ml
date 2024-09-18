open Printf

let run_command command =
  let start_time = Unix.gettimeofday () in
  let result = Sys.command command in
  let end_time = Unix.gettimeofday () in
  let elapsed_time = end_time -. start_time in
  (result, elapsed_time)

let average lst =
  let sum = List.fold_left (+.) 0.0 lst in
  sum /. float_of_int (List.length lst)

let () =
  if Array.length Sys.argv < 3 then (
    printf "Usage: %s <input_file.ml> <number_of_runs>\n" Sys.argv.(0);
    exit 1
  );
  let input_file = Sys.argv.(1) in
  let num_runs = int_of_string Sys.argv.(2) in
  let command = Printf.sprintf "./combined_tool %s" input_file in
  let times = ref [] in
  for i = 1 to num_runs do
    let (result, elapsed_time) = run_command command in
    if result <> 0 then (
      printf "Error: Command failed with code %d\n" result;
      exit 1
    );
    times := elapsed_time :: !times
  done;

