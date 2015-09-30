open Cmdliner
open Lwt
open Brotli

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
  Arg.(value & opt int 8 & info ["q"; "quality"] ~doc)

let no_concurrency_on =
  let doc = "Turn off concurrency, do work serially" in
  Arg.(value & flag & info ["s"; "serial"] ~doc)

let lgwin_level =
  let doc = "Base 2 logarithm of the sliding window size. \
             Range is 10 to 24."
  in
  Arg.(value & opt int 16 & info ["w"; "lgwin"] ~doc)

let mode =
  let doc = "Mode to use. Can be generic, text assuming UTF-8 \
             or font assuming WOFF 2.0"
  in
  Arg.(value & opt string "generic" & info ["m"; "mode"] ~doc)

let suffix =
  let doc = "What suffix to use on outputted files" in
  Arg.(value & opt string "" & info ["S"; "suffix"] ~doc)

let lgblock_level =
  let doc = "Base 2 logarithm of the maximum input block size. \
             Range is 16 to 24. If set to 0, the value will \
             be set based on the quality. "
  in
  Arg.(value & opt int 10 & info ["b"; "lgblock"] ~doc)

let dest_directory =
  let doc = "What directory to output files to, defaults to \
             this current directory"
  in
  Arg.(value & opt string "" & info ["d"; "directory"] ~doc)

let files =
  let doc = "Input files" in
  Arg.(value & pos_all file [] & info [] ~doc )


let chorus
    do_compress
    quality
    mode
    no_concurrency_on
    suffix
    dest_directory
    lgwin_level
    lgblock_level
    files =

  return ()

let entry_point =
  Term.(pure
         chorus
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
  Term.info "brozip" ~version:"0.1" ~doc ~man

let brozip =
  (match Term.eval (entry_point, top_level_info) with
   | `Ok a -> ()
   | `Error e -> ()
   | _ -> ())
  |> return

let () = Lwt_main.run brozip
