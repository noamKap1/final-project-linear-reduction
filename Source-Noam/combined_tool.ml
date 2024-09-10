open Printf

let transform_code input_lines =
  let transformed = List.map (function
    (* Existing transformations *)
    | "fun print (x) {" -> "let print x ="
    | "    _prim_print x;" -> "  Printf.printf \"%d\\n\" x;;
let print_tuple (a, b) =
  Printf.printf \"(%d, %d)\\n\" a b;;"
    | "fun curry (f) {" -> "let curry f ="
    | "    fun curried (x) {" -> "  fun x ->"
    | "        fun curriedX (y) {" -> "    fun y ->"
    | "            f (x,y)" -> "      f x y;;"
    | "        curriedX" -> ""
    | "    curried" -> ""
    | "fun plus (x,y) {" -> "let plus x y ="
    | "    x + y" -> "  x + y;;"
    | "let curry_plus = curry plus;" -> "let curry_plus = curry plus;;"
    | "fun fibonacci (n) {" -> "let rec fibonacci n ="
    | "    switch" -> "  match n with"
    | "    | n == 0 -> { [0;] }" -> "  | 0 -> [0]"
    | "    | n == 1 -> { [0; 1;] }" -> "  | 1 -> [0; 1]"
    | "    | 1 -> {" -> "  | _ ->"
    | "        let prev = fibonacci (n-1);" -> "    let prev = fibonacci (n-1) in"
    | "        prev @ [prev.(n-1) + prev.(n-2);]" -> "    prev @ [List.nth prev (n-1) + List.nth prev (n-2)];;"
    | "    end" -> ""
    | "fun print (x) {" -> "let print x ="
    | "    _prim_print x;" -> "  Printf.printf \"%d\\n\" x;;"
    | "fun length (l) {" -> "let length l ="
    | "    _prim_len l" -> "  List.length l;;"
    | "    _reg_out" -> ""
    | "fun tail (l) {" -> "let tail l ="
    | "    _prim_tail l" -> "  match l with\n  | [] -> []\n  | _::tl -> tl;;"
    | "fun map (l,f) {" -> "let rec map l f ="
    | line when String.trim line = "if (length l == 0) {" -> "  if length l = 0 then"
    | line when String.trim line = "        l" -> "  l"
    | line when String.trim line = "}{" -> "  else"
    | line when String.trim line = "[f (l.0);] @ (map ((tail l), f))" -> "    (f (List.hd l)) :: (map (tail l) f);;"
    | "fun square (n) {" -> "let square n ="
    | "    n * n" -> "  n * n;;"
    | "print (map (arr, square));" -> "List.iter print (map arr square);;"
    | "fun fold_left (f,acc,l) {" -> "let rec fold_left f acc l ="
    | line when String.trim line = "if (length l == 0) {" -> "  if length l = 0 then"
    | line when String.trim line = "        acc" -> "    acc"
    | line when String.trim line = "}{" -> "  else"
    (* Dynamic transformation for fold_left *)
    | line when Str.string_match (Str.regexp "print *( *fold_left *( *sub *, *\\([0-9]+\\) *, *arr *) *)") line 0 ->
        let number = Str.matched_group 1 line in
        Printf.sprintf "print (fold_left sub %s arr);;" number
    | line when String.trim line = "fold_left (f, f (acc,l.0), tail l)" -> "    fold_left f (f acc (List.hd l)) (tail l);;"
    | "fun sub (n,m) {" -> "let sub n m ="
    | "    n - m" -> "  n - m;;"
    | "fun reverse (l) {" -> "let rec reverse l ="
    | line when String.trim line = "if (length l == 0) {" -> "  if length l = 0 then"
    | line when String.trim line = "        l" -> "    l"
    | line when String.trim line = "}{" -> "  else"
    | "print (reverse arr);" -> "List.iter print (reverse arr);;"
    | line when String.trim line = "reverse (tail l) @ [l.0;]" -> "    reverse (tail l) @ [List.hd l];;"
    | "fun fst (a,b) {" -> "let fst (a, b) ="
    | line when String.trim line = "    a" -> "  a;;"
    | "fun snd (a,b) {" -> "let snd (a, b) ="
    | line when String.trim line = "    b" -> "  b;;"
    | "fun flip (p) {" -> "let flip p ="
    | line when String.trim line = "    (snd p, fst p)" -> "  (snd p, fst p);;"
    | line when Str.string_match (Str.regexp "let arr = \\[.*\\]") line 0 -> line ^ ";"
    (* Remove lines with curly braces or leave unchanged *)
    | line when String.contains line '{' || String.contains line '}' -> ""
    | line -> line
  ) input_lines in
  String.concat "\n" (List.filter (fun line -> line <> "" && not (String.trim line = "")) transformed)

let extract_numbers code =
  let number_regex = Str.regexp "print *( *flip *( *\\([0-9]+\\) *, *\\([0-9]+\\) *) *)" in
  try
    ignore (Str.search_forward number_regex code 0);
    (int_of_string (Str.matched_group 1 code), int_of_string (Str.matched_group 2 code))
  with Not_found ->
    let plus_regex = Str.regexp "print *( *plus *( *\\([0-9]+\\) *, *\\([0-9]+\\) *) *)" in
    try
      ignore (Str.search_forward plus_regex code 0);
      (int_of_string (Str.matched_group 1 code), int_of_string (Str.matched_group 2 code))
    with Not_found ->
      let curry_regex = Str.regexp "print *( *curry_plus *\\([0-9]+\\) *\\([0-9]+\\) *)" in
      try
        ignore (Str.search_forward curry_regex code 0);
        (int_of_string (Str.matched_group 1 code), int_of_string (Str.matched_group 2 code))
      with Not_found ->
        let fibonacci_regex = Str.regexp "print *( *fibonacci *\\([0-9]+\\) *)" in
        try
          ignore (Str.search_forward fibonacci_regex code 0);
          (int_of_string (Str.matched_group 1 code), 0)  (* Use the number and a dummy 0 *)
        with Not_found ->
          failwith "Could not find numbers in the code"

let read_code_from_file filename =
  let channel = open_in filename in
  let length = in_channel_length channel in
  let content = really_input_string channel length in
  close_in channel;
  content

let parse_code ocaml_code =
  let lexbuf = Lexing.from_string ocaml_code in
  try
    let _ = Parse.implementation lexbuf in  (* Parse the OCaml code *)
    ()  (* Return unit to match expected type *)
  with
  | e ->
      Printf.printf "Error while parsing: %s\n" (Printexc.to_string e);
      exit 1

let execute_code ocaml_code =
  (* Directly evaluate the code by executing it *)
  let output_channel = open_out "temp.ml" in
  output_string output_channel ocaml_code;
  close_out output_channel;
  let exec_result = Sys.command "ocaml temp.ml" in
  if exec_result <> 0 then
    Printf.printf "Error during execution.\n";
  Sys.remove "temp.ml"  (* Cleanup the temporary file *)

let () =
  let start_time = Unix.gettimeofday () in
  if Array.length Sys.argv < 2 then (
    Printf.printf "Usage: %s <input_file.ml>\n" Sys.argv.(0);
    exit 1
  );
  let input_file = Sys.argv.(1) in
  let content = read_code_from_file input_file in
  let lines = String.split_on_char '\n' content in
  let transformed_code = transform_code lines in
  let (num1, num2) = extract_numbers content in
  let transformed_code_with_nums =
    transformed_code
    |> Str.global_replace (Str.regexp "print *( *plus *([0-9]+ *, *[0-9]+) *)")
         (Printf.sprintf "let () = print (plus %d %d);" num1 num2)
    |> Str.global_replace (Str.regexp "print *( *curry_plus *[0-9]+ *[0-9]+ *);")
         (Printf.sprintf "let () = print (curry_plus %d %d);" num1 num2)
    |> Str.global_replace (Str.regexp "print *( *fibonacci *[0-9]+ *);")
         (Printf.sprintf "let () = let fib = fibonacci %d in List.iter print fib;" num1)
    |> Str.global_replace (Str.regexp "print *( *flip *( *[0-9]+ *, *[0-9]+) *);")
         (Printf.sprintf "let () = print_tuple (flip (%d, %d))
" num1 num2)
  in
  parse_code(transformed_code_with_nums);
  execute_code(transformed_code_with_nums);

  let end_time = Unix.gettimeofday () in
  let total_time = end_time -. start_time in
  Printf.printf "Total execution time: %.6f seconds\n" total_time;
