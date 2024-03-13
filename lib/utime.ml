external init :
  init_calibrate_ns:(int64[@unboxed]) ->
  calibrate_interval_ns:(int64[@unboxed]) ->
  unit = "none" "caml_utime_init"

external calibrate : unit -> unit = "caml_utime_calibrate"
external now : unit -> (int64[@unboxed]) = "none" "caml_utime_rdns" [@@noalloc]
external sleep_1s : unit -> unit = "caml_utime_sleep_1s"

external unsafe_get_freq : unit -> (float[@unboxed]) = "none" "caml_utime_unsafe_get_freq"
  [@@noalloc]

type t = unit Stdlib.Domain.t option
let continue = Atomic.make true
let freq = Atomic.make 0.

let calibrate () =
  while Atomic.get continue do
    sleep_1s ();
    calibrate ();
    Atomic.set freq (unsafe_get_freq ());
  done

let init ?(calibration= Some (20000000L, 3000000000L)) () = match calibration with
  | None -> None
  | Some (init_calibrate_ns, calibrate_interval_ns) ->
    init ~init_calibrate_ns ~calibrate_interval_ns;
    Atomic.set freq (unsafe_get_freq ());
    Some (Stdlib.Domain.spawn calibrate)

let get_freq () = Atomic.get freq

let kill = function
  | None -> ()
  | Some domain ->
    Atomic.set continue false;
    Domain.join domain
