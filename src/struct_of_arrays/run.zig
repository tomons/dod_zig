const std = @import("std");
const zbench = @import("zbench");

const ArrayOfStructsPerfTest = @import("array_of_structs.zig").ArrayOfStructsPerfTest;
const initAnimations = @import("common.zig").initAnimations;

const total_monsters = 10000;
var array_of_structs_perf_test: ArrayOfStructsPerfTest = undefined;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    //todo: print size in bytes

    const allocator = std.heap.page_allocator;

    const animations = try initAnimations(allocator, 8);
    defer allocator.free(animations);

    array_of_structs_perf_test = try ArrayOfStructsPerfTest.init(allocator, animations, total_monsters);
    defer array_of_structs_perf_test.deinit();

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("Struct of arrays", benchmarkArrayOfStructs, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkArrayOfStructs(allocator: std.mem.Allocator) void {
    const failed = array_of_structs_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkArrayOfStructs: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}
