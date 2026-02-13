# Struct Of Arrays

Run:

```sh
zig build run_struct_of_arrays -Doptimize=ReleaseFast
```

Example run (output will vary by machine):

```text
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Array of structs       100000   655.059ms      6.55us ± 1.089us      (4.749us ... 98.547us)       7.124us    9.499us    13.06us
Struct of arrays       100000   841.668ms      8.416us ± 1.105us     (3.562us ... 96.173us)       8.312us    11.873us   15.435us
Array of structs example memory allocation: 166112 bytes
Struct of arrays example memory allocation: 125714 bytes
```
