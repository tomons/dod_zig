# Indexes vs Pointers (Dynamic Memory)

Run:

```sh
zig build run_indexes_vs_pointers_dynamic -Doptimize=ReleaseFast
```

Example run (output will vary by machine):

```text
Size of StructOfPointers: 32 bytes
Size of StructOfIndexes: 16 bytes

benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Struct of Pointers     935      1.935s         2.069ms ± 117.644us   (1.935ms ... 3.053ms)        2.106ms    2.528ms    2.635ms
Struct of Indexes      1214     1.918s         1.58ms ± 101.622us    (1.434ms ... 2.208ms)        1.619ms    1.934ms    2.014ms
```
