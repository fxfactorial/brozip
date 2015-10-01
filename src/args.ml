open Cmdliner

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

let recursive =
  let doc = "This option is used to $(b,$(tname)) the files in a directory tree" in
  Arg.(value & flag & info ["r";"recursive"] ~doc)
