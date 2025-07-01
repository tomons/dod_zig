// To run in relase fast mode: zig build run -Doptimize=ReleaseFast

const std = @import("std");
const time = std.time;
const print = std.debug.print;

pub fn main() !void {
    for (0..10) |_| {
        const repeats: u32 = 100;
        const res1 = lib.structOfIndexesPerfTest(repeats);
        const res2 = lib.structOfPointersPerfTest(repeats);

        print("Sum is {} . structOfIndexes time elapsed is: {d:.3}ms\n", .{
            res1.sum,
            res1.elapsed / time.ns_per_ms,
        });

        print("Sum is {} . structOfPointers time elapsed is: {d:.3}ms\n", .{
            res2.sum,
            res2.elapsed / time.ns_per_ms,
        });
    }
}

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("dod_design_lib");
