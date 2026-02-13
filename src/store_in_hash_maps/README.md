# Store In Hash Maps

Run:

```sh
zig build run_store_in_hash_maps -Doptimize=ReleaseFast
```

Example run (output will vary by machine):

```text
benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
No hash map            100000   1.797s         17.979us ± 2.771us    (10.686us ... 648.277us)     17.81us    26.121us   29.683us
With hash map          86017    1.986s         23.096us ± 4.78us     (21.371us ... 748.012us)     22.559us   36.806us   39.182us
No hash map example memory allocation: 325220 bytes
With hash map example memory allocation: 197844 bytes
```
