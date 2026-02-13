[![CI](https://github.com/tomons/dod_zig/actions/workflows/ci.yml/badge.svg)](https://github.com/tomons/dod_zig/actions/workflows/ci.yml)

## Data-Oriented Design (DOD) Examples in Zig

This repository contains performance tests based on examples from the
talk ["Andrew Kelley - Practical DOD"](https://vimeo.com/649009599). For the Q&A portion of the talk,
see: ["Practical DOD - Q&A"](https://vimeo.com/649016743).

The examples are hypothetical with dummy logic aiming to demonstrate potential performance
optimizations using DOD principles in Zig.

Used zig version: 0.15.2

### Building and Running Examples

Use indexes instead of pointers:

```sh
zig build run_indexes_vs_pointers -Doptimize=ReleaseFast
```

Details and example run: [`src/indexes_vs_pointers/README.md`](src/indexes_vs_pointers/README.md)

Use indexes instead of pointers (with dynamically allocated memory):

```sh
zig build run_indexes_vs_pointers_dynamic -Doptimize=ReleaseFast
```

Details and example run: [`src/indexes_vs_pointers_dynamic/README.md`](src/indexes_vs_pointers_dynamic/README.md)

Store booleans out of band:

```sh
zig build run_booleans_out_of_band -Doptimize=ReleaseFast
```

Details and example run: [`src/booleans_out_of_band/README.md`](src/booleans_out_of_band/README.md)

Eliminate padding with struct of arrays instead of array of structs:

```sh
zig build run_struct_of_arrays -Doptimize=ReleaseFast
```

Details and example run: [`src/struct_of_arrays/README.md`](src/struct_of_arrays/README.md)

Store sparse data in hash maps:

```sh
zig build run_store_in_hash_maps -Doptimize=ReleaseFast
```

Details and example run: [`src/store_in_hash_maps/README.md`](src/store_in_hash_maps/README.md)

Use "encodings" instead of OOP/polymorphism:

```sh
zig build run_use_encodings -Doptimize=ReleaseFast
```

Details and example run: [`src/use_encodings/README.md`](src/use_encodings/README.md)

See list of all build steps (including run commands for all the examples):

```sh
zig build --list-steps
```
