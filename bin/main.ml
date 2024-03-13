let ( - ) = Int64.sub

let spawn _ = Stdlib.Domain.spawn @@ fun () ->
  let _ = Utime.now () in
  let a = Utime.now () in
  Unix.sleepf 0.01;
  let b = Utime.now () in
  Unix.sleepf 0.01;
  let c = Utime.now () in
  b - a, c - b

let foo () =
  let _ = Utime.now () in 
  Format.printf "%.02fGHz\n%!" (Utime.get_freq ());
  let a = Utime.now () in
  Unix.sleepf 0.01;
  let b = Utime.now () in
  Format.printf "dom0: %Ld\n%!" (b - a);
  assert (b - a < 12000000L);
  let a = Utime.now () in
  Unix.sleepf 0.01;
  let b = Utime.now () in
  Format.printf "dom0: %Ld\n%!" (b - a);
  assert (b - a < 12000000L);
  let a = Utime.now () in
  let domains = List.init 2 spawn in
  let b = Utime.now () in
  let[@warning "-8"] [ (x, x'); (y, y') ] = List.map Stdlib.Domain.join domains in
  let c = Utime.now () in
  Format.printf "dom0: %Ld %Ld\n%!" (c - a) (c - b);
  Format.printf "dom1: %Ld %Ld\n%!" x x';
  Format.printf "dom2: %Ld %Ld\n%!" y y';
  assert (x < 12000000L);
  assert (y < 12000000L);
  assert (x' < 12000000L);
  assert (y' < 12000000L);
  let a = Utime.now () in
  Unix.sleepf 0.01;
  let b = Utime.now () in
  Format.printf "dom0: %Ld\n%!" (b - a);
  assert (b - a < 12000000L)

let () =
  let t = Utime.init () in
  for _ = 0 to 1000 do foo () done;
  Utime.kill t
