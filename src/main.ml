open Cmdliner
open Lwt
open Brotli
open Args
open Utils

let rec walk_and_action action node =
  if Sys.is_directory node
  then (Sys.readdir node
        |> Array.to_list
        |> List.map (Filename.concat node)
        |> Lwt_list.iter_p (walk_and_action action))
  else action node

let handle_decompression
    (files, no_con, suffix, dest_directory)
    do_recurse =
  Lwt_unix.chdir dest_directory >>= fun () -> match files with
  | [] ->
    Lwt_io.read Lwt_io.stdin >>= Decompress.to_bytes >>= Lwt_io.write Lwt_io.stdout
  | some_files -> match no_con with
    | false ->
      if not do_recurse then
        some_files |> Lwt_list.iter_p Decompress.to_path
      else some_files |> Lwt_list.iter_p (walk_and_action Decompress.to_path)
    | true ->
      some_files |> Lwt_list.iter_s Decompress.to_path

let handle_compression
    (files, no_con, suffix, dest_directory)
    (mode, quality, lgwin_level, lgblock_level)
    do_recurse =
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
        (a_file ^.^ suffix)
        |> Compress.to_path ~mode ~quality ~lgwin ~lgblock ~file_src:a_file
      end
    | true ->
      some_files |> Lwt_list.iter_s begin fun a_file ->
        (a_file ^.^ suffix)
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
    recursive
    files =
  (* Sanity Checks *)
  if not (Sys.file_exists dest_directory) ||
     (Sys.file_exists dest_directory && not (Sys.is_directory dest_directory))
  then raise (Bad_input "Destination given either \
                         doesn't exist or isn't a direcotry");
  files |> List.iter begin fun an_input ->
    if not recursive && Sys.is_directory an_input
    then raise (Bad_input "Can't compress a directory, \
                           create an archive first");
  end;
  verify_params mode quality lgwin_level lgblock_level;

  (* Good to go, spin up Lwt *)
  Lwt_main.run begin
    match do_compress with
    | true ->
      recursive
      |> handle_compression
        (files, no_concurrency_on, suffix, dest_directory)
        (mode, quality, lgwin_level, lgblock_level)
    | false ->
      recursive
      |> handle_decompression (files, no_concurrency_on, suffix, dest_directory)
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
        $ recursive
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
  Term.info "brozip" ~version:"1.0" ~doc ~man

let () =
  match Term.eval (entry_point, top_level_info) with
  | `Ok a -> ()
  | `Error _ -> prerr_endline "If this error is unexpected then, \
                               please report to github.com/fxfactorial/issues"
  | _ -> ()
