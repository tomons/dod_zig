## DOD (Data-Oriented Design) examples in Zig

Tried to implement performance tests of examples from talk "Andrew Kelley - Practical DOD" https://vimeo.com/649009599

### Build

Run one of the examples:

```sh
zig build run_indexes_vs_pointers -Doptimize=ReleaseFast
```

See list of all build steps (including run commands for all the examples):

```sh
zig build --list-steps
```