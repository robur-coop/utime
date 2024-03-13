(** A domain-safe highly precise timestamp counter.

    utime is a library that provides a unit of time without asking the system
    for this information. To do this, utime uses the cycle counter and attempts
    to deduce the time using this counter and the processor frequency. In this
    way, it is possible to accurately deduce the time spent between 2 points in
    a programme.

    utime has a calibration mechanism in case the processor frequency changes.
    It launches a parallel domain which will attempt a calibration every second
    if necessary.

    Finally, this unit of time is accessible to all domains.
*)

type t
(** Type of the calibration domains. *)

val init : ?calibration:(int64 * int64) option -> unit -> t
(** [init ~calibation:(init_calibration_ns, calibration_interval_ns) ()] spawns
    a new domain which will calibrate our internal counter every
    [calibration_interval_ns] nanosecond(s) (defaults to 3s). Calibration is
    carried out from the initial stage. The user can specify the time for this
    initial calibration (defaults to 20ms).

    The user can choose not to have background calibration. In this case, set
    the value [calibration] to None. *)

val now : unit -> int64
(** [now ()] returns the current time according to our counter. This time
    {b does not} correspond to the actual date. However, the difference between
    2 values returned by now should be more accurate. This is known as a
    monotonic clock. *)

val get_freq : unit -> float
(** [get_freq ()] It returns the current processor frequency. This value is
    recalculated at each calibration and can potentially change. *)

val kill : t -> unit
(** If the user wishes to end the programme, they must stop the calibration
    using the kill function. *)
