open Cmdliner
open Lwt
open Brotli

type exn += Bad_parameter of string

let do_compress =
  let doc = "compress files, if flag not given then $(b,$(tname)) \
             will decompress files "
  in
  Arg.(value & flag & info ["c"; "compress"] ~doc)

let quality_level =
  let doc = "Controls the compression-speed vs compression-density \
             tradeoffs. The higher the quality, the slower the \
             compression. Range is 0 to 11."
  in
  Arg.(value & opt int 11 & info ["q"; "quality"] ~doc)

let no_concurrency_on =
  let doc = "Turn off concurrency, do work serially" in
  Arg.(value & flag & info ["s"; "serial"] ~doc)

let lgwin_level =
  let doc = "Base 2 logarithm of the sliding window size. \
             Range is 10 to 24."
  in
  Arg.(value & opt int 22 & info ["w"; "lgwin"] ~doc)

let mode =
  let doc = "Mode to use. Can be $(b,generic), $(b,text) assuming UTF-8, \
             or $(b,font) assuming WOFF 2.0"
  in
  Arg.(value & opt string "generic" & info ["m"; "mode"] ~doc)

let suffix =
  let doc = "What suffix to use on outputted files" in
  Arg.(value & opt string "bro" & info ["S"; "suffix"] ~doc)

let lgblock_level =
  let doc = "Base 2 logarithm of the maximum input block size. \
             Range is 16 to 24. If set to 0, the value will \
             be set based on the quality. "
  in
  Arg.(value & opt int 0 & info ["b"; "lgblock"] ~doc)

let dest_directory =
  let doc = "What directory to output files to, defaults to \
             this current directory"
  in
  Arg.(value & opt string "." & info ["d"; "directory"] ~doc)

let files =
  let doc = "Input files" in
  Arg.(value & pos_all file [] & info [] ~doc )

let handle_decompression (files, no_con, suffix, dest_directory) =
  Lwt_unix.chdir dest_directory >>= fun () -> match files with
  | [] ->
    Lwt_io.read Lwt_io.stdin >>= Decompress.to_bytes >>= Lwt_io.write Lwt_io.stdout
  | some_files -> match no_con with
    | false ->
      (* This is the default case *)
      some_files |> Lwt_list.iter_p Decompress.to_path
    | true ->
      some_files |> Lwt_list.iter_s Decompress.to_path

let verify_params mode quality lgwin_level lgblock_level =
  (match String.lowercase mode with
   | "generic" | "text" | "font" -> ()
   | _ ->
     raise (Bad_parameter "mode must be one of generic, text or font"));
  (match quality with
   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 -> ()
   | _ -> raise (Bad_parameter "quality must be in 0 to 11 range"));
  (match lgwin_level with
   | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 -> ()
   | _ -> raise (Bad_parameter "lgwin_level must be in 10 to 24 range"));
  (match lgblock_level with
   | 0 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 -> ()
   | _ -> raise (Bad_parameter "lgblock_level must be either 0 or \
                                a value in 16 to 24 range "))

(* TODO Must be a smarter way, isn't there subtyping with polyvariants ? *)
let v_q = function
  | 0 -> `_0 | 1 -> `_1 | 2 -> `_2 | 3 -> `_3 | 4 -> `_4
  | 5 -> `_5 | 6 -> `_6 | 7 -> `_7 | 8 -> `_8 | 9 -> `_9
  | _ -> assert false

let v_w = function
  | 10 -> `_10 | 11 -> `_11 | 12 -> `_12 | 13 -> `_13
  | 14 -> `_14 | 15 -> `_15 | 16 -> `_16 | 17 -> `_17
  | 18 -> `_18 | 19 -> `_19 | 20 -> `_20 | 21 -> `_21
  | 22 -> `_22 | 23 -> `_23 | 24 -> `_24 | _ -> assert false

let v_b = function
  | 0 -> `_0 |16 -> `_16 | 17 -> `_17 | 18 -> `_18
  | 19 -> `_19 | 20 -> `_20 | 21 -> `_21
  | 22 -> `_22 | 23 -> `_23 | 24 -> `_24
  | _ -> assert false

let m_to_mode = function
  | "mode" -> Compress.Generic
  | "text" -> Compress.Text
  | "font" -> Compress.Font
  | _ -> assert false

let handle_compression
    (files, no_con, suffix, dest_directory)
    (mode, quality, lgwin_level, lgblock_level) =
  let (mode, quality, lgwin, lgblock) =
    m_to_mode mode, v_q quality, v_w lgwin_level, v_b lgblock_level
  in
  Lwt_unix.chdir dest_directory >>= fun () -> match files with
  | [] ->
    Lwt_io.read Lwt_io.stdin >>= Compress.to_bytes >>= Lwt_io.write Lwt_io.stdout
  | some_files -> match no_con with
    | false ->
      (* This is the default case *)
      some_files |> Lwt_list.iter_p begin fun a_file ->
        (a_file ^ suffix)
        |> Compress.to_path ~mode ~quality ~lgwin ~lgblock ~file_src:a_file
      end
    | true ->
      some_files |> Lwt_list.iter_s begin fun a_file ->
        (a_file ^ suffix)
        |> Compress.to_path ~mode ~quality ~lgwin ~lgblock ~file_src:a_file
      end

let begin_program
    do_compress
    quality
    mode
    no_concurrency_on
    suffix
    dest_directory
    lgwin_level
    lgblock_level
    files =
  Lwt_main.run begin
    verify_params mode quality lgwin_level lgblock_level;
    match do_compress with
    | true ->
      handle_compression
        (files, no_concurrency_on, suffix, dest_directory)
        (mode, quality, lgwin_level, lgblock_level)
    | false ->
      handle_decompression (files, no_concurrency_on, suffix, dest_directory)
  end

let entry_point =
  Term.(pure
          begin_program
        $ do_compress
        $ quality_level
        $ mode
        $ no_concurrency_on
        $ suffix
        $ dest_directory
        $ lgwin_level
        $ lgblock_level
        $ files )

let top_level_info =
  let doc =
    "concurrently compress, decompress files using the Brotli algorithm"
  in
  let man = [`S "DESCRIPTION";
             `P "The $(b,$(tname)) program compresses and decompresses \
                 files using Google's Brotli algorithm. If no files are \
                 specified, $(b,$(tname)) will compress from standard input, \
                 or decompress to standard ouput. When in compression mode, each \
                 file will be replaced with another file with the suffix, set by \
                 the $(b,-S) suffix option, added, if possible";
             `P "In decompression mode, each file will be checked for \
                 existence, as will the file with the suffix added";
             `P "$(b,$(tname)) exposes compression options and \
                 defaults to values used by Google";
             `S "AUTHOR";
             `P "brozip was written by Edgar Aroutiounian";
             `S "BUGS";
             `P "See development at http://github.com/fxfactorial/brozip \
                 and file bug reports there.";
             `S "MISC";
             `P "$(tname) is written in OCaml with bindings to Google's \
                 Brotli C/C++ library. Those bindings are available here: \
                 http://github.com/fxfactorial/ocaml-brotli"]
  in
  Term.info "brozip" ~version:"0.1" ~doc ~man

let () =
  match Term.eval (entry_point, top_level_info) with
  | `Ok a -> ()
  | `Error _ -> prerr_endline "Some kind of error"
  | _ -> ()
