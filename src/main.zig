// To run in relase fast mode: zig build run -Doptimize=ReleaseFast

const std = @import("std");
const zbench = @import("zbench");

pub fn main() !void {

    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("Struct of Indexes", benchmarkStructOfIndexes, .{});
    try bench.add("Struct of Pointers", benchmarkStructOfPointers, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("dod_design_lib");

fn benchmarkStructOfIndexes(_: std.mem.Allocator) void {
    const result = lib.structOfIndexesPerfTest();
    std.debug.assert(result != 0); // Use result to prevent optimization
}

fn benchmarkStructOfPointers(_: std.mem.Allocator) void {
    const result =lib.structOfPointersPerfTest();
    std.debug.assert(result != 0); // Use result to prevent optimization
}


