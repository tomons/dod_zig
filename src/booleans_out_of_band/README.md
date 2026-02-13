# Booleans Out Of Band

Run:

```sh
zig build run_booleans_out_of_band -Doptimize=ReleaseFast
```

Example run (output will vary by machine):

```text
Size of WithBoolMonster: 24 bytes
Size of WithoutBoolMonster: 16 bytes
Size of IndexesInsteadOfPointersMonster: 12 bytes

benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
With bool              100000   1.354s         13.545us ± 1.55us     (9.499us ... 85.487us)       14.248us   21.371us   22.559us
No bool                100000   787.463ms      7.874us ± 1.22us      (5.936us ... 106.859us)      8.311us    11.874us   15.436us
No bool no pointers    100000   784.455ms      7.844us ± 1.17us      (2.374us ... 104.484us)      8.311us    11.874us   15.435us
```
