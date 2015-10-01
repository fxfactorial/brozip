
type exn += Bad_parameter of string
type exn += Bad_input of string

let ( ^.^ ) l r = l ^ "." ^ r

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
  | 10 -> `_10 | 11 -> `_11 | _ -> assert false

let v_w = function
  | 10 -> `_10 | 11 -> `_11 | 12 -> `_12 | 13 -> `_13
  | 14 -> `_14 | 15 -> `_15 | 16 -> `_16 | 17 -> `_17
  | 18 -> `_18 | 19 -> `_19 | 20 -> `_20 | 21 -> `_21
  | 22 -> `_22 | 23 -> `_23 | 24 -> `_24 | _ -> assert false

let v_b = function
  | 0 -> `_0   | 16 -> `_16 | 17 -> `_17
  | 18 -> `_18 | 19 -> `_19 | 20 -> `_20
  | 21 -> `_21 | 22 -> `_22 | 23 -> `_23
  | 24 -> `_24 | _ -> assert false

let m_to_mode m =
  let open Brotli in
  match m with
  | "generic" -> Compress.Generic
  | "text" -> Compress.Text
  | "font" -> Compress.Font
  | _ -> assert false

