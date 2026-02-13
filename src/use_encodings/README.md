# Use Encodings

Run:

```sh
zig build run_use_encodings -Doptimize=ReleaseFast
```

Example run (output will vary by machine):

```text
Size of SimpleMonster: 32 bytes
Size of OOMonster.Bee: 16 bytes
Size of OOMonster.Human: 32 bytes
Average Size of OOMonster: 24 bytes
Size of encoded bee monster in multi array list: 13 bytes
Size of encoded naked human monster in multi array list: 13 bytes
Size of encoded clothed human monster in array list: 29 bytes
Average size of encoded monster with use of multi array list and array list: 17 bytes

benchmark              runs     total time     time/run (avg ± σ)    (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
Simple monster         153      1.956s         12.785ms ± 660.575us  (12.273ms ... 18.729ms)      12.837ms   16.262ms   18.729ms
OO monster             150      1.96s          13.071ms ± 340.271us  (12.773ms ... 16.216ms)      13.21ms    14.313ms   16.216ms
Encoded monster        202      1.99s          9.853ms ± 582.37us    (9.479ms ... 14.192ms)       9.798ms    12.46ms    12.9ms
SimpleMonster example memory allocation: 366435104 bytes
OOMonster example memory allocation: 272046352 bytes
EncodedMonster example memory allocation: 274672002 bytes
```
