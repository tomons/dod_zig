## Data-Oriented Design (DOD) Examples in Zig

This repository contains performance tests based on examples from the
talk ["Andrew Kelley - Practical DOD"](https://vimeo.com/649009599). For the Q&A portion of the talk,
see: ["Practical DOD - Q&A"](https://vimeo.com/649016743).

The examples are hypothetical with (my) dubious simplified logic aiming to demonstrate potential performance
optimizations using DOD principles in Zig.

### Building and Running Examples

Use indexes instead of pointers:

```sh
zig build run_indexes_vs_pointers -Doptimize=ReleaseFast
```

Use indexes instead of pointers (with dynamically allocated memory):

```sh
zig build run_indexes_vs_pointers_dynamic -Doptimize=ReleaseFast
```

Store booleans out of band:

```sh
zig build run_booleans_out_of_band -Doptimize=ReleaseFast
```

Eliminate padding with struct of arrays instead of array of structs:

```sh
zig build run_struct_of_arrays -Doptimize=ReleaseFast
```

Store sparse data in hash maps:

```sh
zig build run_store_in_hash_maps -Doptimize=ReleaseFast
```

Use "encodings" instead of OOP/polymorphism:

```sh
zig build run_use_encodings -Doptimize=ReleaseFast
```

See list of all build steps (including run commands for all the examples):

```sh
zig build --list-steps
```