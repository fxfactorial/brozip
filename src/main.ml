open Cmdliner
open Lwt
open Brotli

let lwt_program files =
  files |> Lwt_list.iter_p begin fun file_src ->
    Decompress.to_path file_src
  end

let program items =
  lwt_program items |> Lwt_main.run

let compressed =
  let doc = "Source file(s) to copy." in
  Arg.(value & (pos_all file) [] & info [] ~docv:"FILE or DIR" ~doc)

let cmd =
  (* let doc = "brozip is a tool to concurrently compress/decompress files \ *)
     (*            using the Brotli compression algorithm" *)
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
                 existence, as will the file with the suffix added. \
                 Each file argument must contain a separate complete \
                 archive; when multiple files are indicated, \
                 each is decompressed in turn.";
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
  Term.(pure program $ compressed),
  Term.info "brozip" ~version:"0.1" ~doc ~man

let prog =
  match Term.eval cmd with
  | `Ok _ -> ()
  | `Error _ -> ()
  | _ -> ()
