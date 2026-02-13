# Indexes vs Pointers

Run:

```sh
zig build run_indexes_vs_pointers -Doptimize=ReleaseFast
```

Example run (output will vary by machine):

```text
Size of StructOfPointers: 32 bytes
Size of StructOfIndexes: 16 bytes

benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Struct of Pointers     10494    1.996s         190.244us ± 10.684us  (175.724us ... 682.71us)     193.534us  218.467us  235.09us
Struct of Indexes      12901    2.015s         156.211us ± 11.513us  (142.479us ... 530.733us)    157.914us  206.594us  216.093us
```
