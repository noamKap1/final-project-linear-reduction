open Unix

let run_tool input_file output_file =
  let start_time = gettimeofday () in
  let command = Printf.sprintf "./main %s y> /dev/null" input_file in
  let _ = Sys.command command in
  let end_time = gettimeofday () in
  let exec_time = end_time -. start_time in
  (* Append the execution time to the specified file *)
  let out_channel = open_out_gen [Open_append; Open_creat] 0o666 output_file in
  Printf.fprintf out_channel "%.6f\n" exec_time;
  close_out out_channel

let run_multiple_times input_file iterations output_file =
  let _ = Sys.command (Printf.sprintf "> %s" output_file) in
  for i = 1 to iterations do
    run_tool input_file output_file;
  done;
  let times = ref [] in
  let in_channel = open_in output_file in
  try
    while true do
      let line = input_line in_channel in
      if String.length line > 0 then
        times := float_of_string line :: !times
    done
  with End_of_file ->
    close_in in_channel;
    let sum = List.fold_left ( +. ) 0.0 !times in
    let average_time = sum /. float_of_int (List.length !times) in
    Printf.printf "Average execution time: %.6f seconds\n" average_time

let () =
  if Array.length Sys.argv < 2 then (
    Printf.printf "Usage: %s <input_file.ml>\n" Sys.argv.(0);
    exit 1
  );
  let input_file = Sys.argv.(1) in
  let output_file = "execution_times.txt" in  (* All execution times will go here *)
  let iterations = 500 in
  run_multiple_times input_file iterations output_file;
  Printf.printf "Ran combine_tool.ml %d times and saved execution times to %s\n" iterations output_file;
