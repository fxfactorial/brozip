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
  let doc = "brozip is a tool to concurrently compress/decompress files \
             using the Brotli compression algorithm"
  in
  let man = [`S "AUTHOR";
             `P "brozip was written by Edgar Aroutiounian";
             `S "BUGS";
             `P "See development at http://github.com/fxfactorial/ocaml-brotli \
                 and file bug reports there.";
             `S "MISC";
             `P "$(tname) is written in OCaml with bindings to Google's \
                 Brotli C/C++ library"]
  in
  Term.(pure program $ compressed),
  Term.info "brozip" ~version:"0.1" ~doc ~man

let prog =
  match Term.eval cmd with
  | `Ok _ -> ()
  | `Error _ -> ()
  | _ -> ()
