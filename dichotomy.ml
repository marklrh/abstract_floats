(* double dichotomy to determine floating point range for x
   in ``x + a == b``, given value of ``a`` and ``b`` *)

let ppf f = Printf.printf "%.16e\n" f

let largest_neg = -4.94e-324
let smallest_pos = +4.94e-324
let smallest_neg = -.max_float
let largest_pos = max_float

type t =
  | Range of float * float
  | Single of float
  | Empty

let to_string = function
  | Range (l, u) -> Printf.sprintf "{%.16e ... %.16e}" l u
  | Single f -> Printf.sprintf "{%.16e}" f
  | Empty -> "empty range"

let neg_zero = Int64.float_of_bits 0x8000_0000_0000_0000L
let pos_zero = Int64.float_of_bits 0x0000_0000_0000_0000L

let fsucc f = Int64.(float_of_bits @@ succ @@ bits_of_float f)
let fpred f = Int64.(float_of_bits @@ pred @@ bits_of_float f)

let m1 = 0x4000_0000_0000_0000L
let m2 = 0xBFFF_FFFF_FFFF_FFFFL

let on_bit f pos =
  let mask = Int64.(shift_right m1 pos) in
  Int64.(float_of_bits @@ logor (bits_of_float f) mask)

let off_bit f pos =
  let mask = Int64.(shift_right m2 pos) in
  Int64.(float_of_bits @@ logand (bits_of_float f) mask)

let dichotomy restore init a b =
  let rec approach f i =
    if i >= 63 then f else
      let tf = on_bit f i in
      if restore tf a b then approach f (i + 1) else approach tf (i + 1)
  in approach init 0

(* not really inlined *)
let upper_neg = dichotomy (fun f a b -> f +. a <= b) neg_zero

let lower_neg = dichotomy (fun f a b -> f +. a < b) neg_zero

let upper_pos = dichotomy (fun f a b -> f +. a > b) pos_zero

let lower_pos = dichotomy (fun f a b -> f +. a >= b) pos_zero

(* smallest pos normalish such that there exists a number x such that
 [pos_cp +. x = infinity] *)
let pos_cp = 9.9792015476736e+291
let neg_cp = -9.9792015476736e+291

let dump a b =
  Printf.printf "upper_neg : %.16e\n" (upper_neg a b);
  Printf.printf "lower_neg : %.16e\n" (lower_neg a b);
  Printf.printf "upper_pos : %.16e\n" (upper_pos a b);
  Printf.printf "lower_pos : %.16e\n" (lower_pos a b)

let range a b =
  try begin
  let l, u =
    if a = b then
      lower_neg a b, upper_pos a b else
    if a < b then begin
      if a +. max_float < b then raise Not_found else
      if b = infinity then
        fsucc (lower_pos a infinity), max_float
      else
        fsucc (lower_pos a b), upper_pos a b
    end
    else begin
      if a -. max_float > b then raise Not_found else
      if b = neg_infinity then
        (-.max_float), fsucc (upper_neg a neg_infinity)
      else
        lower_neg a b, fsucc (upper_neg a b)
    end in
  if l = u && l <> 0. then Single l else
  if l = u then Range (l, u) else
  if l > u then begin
    if l +. a = b then Single l else
    if u +. a = b then Single u else
      Empty
  end else
    Range (l, u)
  end
  with _ -> Empty

let normalize = function
  | Range (l, u) ->
    if l = 0.0 then
      if u = 0.0 then Some (l, u), None, None else
      if u > 0.0 then Some (l, l), None, Some (smallest_pos, u) else
      assert false else
    if l > 0.0 then None, None, Some (l, u) else
    if u = 0.0 then Some (u, u), Some (l, largest_neg), None else
    if u < 0.0 then None, Some (l, u), None else
      Some (-0.0, 0.0), Some (l, largest_neg), Some (smallest_pos, u)
  | Single n ->
    if n = 0.0 then Some (n, n), None, None else
    if n > 0.0 then None, None, Some (n, n)
    else None, Some (n, n), None
  | Empty -> None, None, None

let combine t1 t2 =
  match t1, t2 with
  | Empty, r | r, Empty -> r
  | Range (l1, u1), Range (l2, u2) ->
    Range (min l1 l2, max u1 u2)
  | Range (l, u) as r, Single n | Single n, (Range (l, u) as r) ->
    if n < l then Range (n, u) else
    if n > u then Range (l, n) else r
  | Single n1, Single n2 ->
    if n1 = n2 then t1 else
    if n1 > n2 then Range (n2, n1) else Range (n1, n2)
