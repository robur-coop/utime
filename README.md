# Utime, a domain-safe highly precise timestamp counter

Time precision, especially when it comes to knowing how long a programme will
run, is generally imprecise for several reasons:
- as such, we are not interested in the actual date but in a metric. For this
  reason, it is often advisable to use a so-called _monotonic_ clock rather than
  a real clock.
- requesting such a clock from the system can take some time (a lot of things
  happen between your application and the system). It is advisable to use the
  cycle counter of your processor.
- Finally, the frequency of your processor may change. If the frequency
  increases, the number of possible cycles for your processor also increases.
  Recalibration is therefore necessary.

For all these reasons, getting a good metric that is viable on most computers
becomes complex:
- portability: does your process give access to the number of cycles made?
- accuracy: is obtaining such a counter not 'polluted' with noise (such as a
  kernel request)?
- correction: can the time calculation be corrected according to the state of
  the processor?

`Utime` attempts to answer all these questions by offering such a counter on
several systems and architectures. Also, the counter, as a single resource, can
be available from several domains. Access is "domain-safe".

## How to use it?

`Utime` requires an initialisation that will freeze the internal elements in
relation to the current date and processor frequency. Even if what `Utime` can
return seems close to the real current date, it is above all more important to
be precise about the metric than about the value itself. So it may be possible
to observe a _drift_ between what `Utime` returns and the true date.

By default, `Utime` launches a parallel domain that takes care of calibration
every second. However, the user can choose not to calibrate.

Here's a basic example of how to use `Utime`:
```sh
$ cat >main.ml<<EOF
let fact = function
  | 0 -> 1
  | n -> n * (fact (n - 1))

let () =
  let t = Utime.init () in
  let a = Utime.now () in
  let _ = fact 120 in
  let b = Utime.now () in
  Format.printf "fact(120): %Ldns\n" (Int64.sub b a);
  Utime.kill t
EOF
$ opam install utime
$ ocamlfind opt -linkpkg -package utime main.ml
$ ./a.out
fact(120): 2550ns
```
