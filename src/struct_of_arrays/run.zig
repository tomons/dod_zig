const std = @import("std");
const zbench = @import("zbench");

const ArrayOfStructsPerfTest = @import("array_of_structs.zig").ArrayOfStructsPerfTest;
const StructOfArraysPerfTest = @import("struct_of_arrays.zig").StructOfArraysPerfTest;
const initAnimations = @import("common.zig").initAnimations;

const total_monsters = 10_000;
var array_of_structs_perf_test: ArrayOfStructsPerfTest = undefined;
var struct_of_arrays_perf_test: StructOfArraysPerfTest = undefined;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const allocator = std.heap.page_allocator;

    const animationsCount = 8;

    const animations1 = try initAnimations(allocator, animationsCount);
    defer allocator.free(animations1);
    array_of_structs_perf_test = try ArrayOfStructsPerfTest.init(allocator, animations1, total_monsters);
    defer array_of_structs_perf_test.deinit();
    try stdout.print("Size of array of structs approximately: {} bytes\n", .{array_of_structs_perf_test.monstersSizeInBytes()});

    const animations2 = try initAnimations(allocator, animationsCount);
    defer allocator.free(animations2);
    struct_of_arrays_perf_test = try StructOfArraysPerfTest.init(allocator, animations2, total_monsters);
    defer struct_of_arrays_perf_test.deinit(allocator);
    try stdout.print("Size of array struct of arrays approximately: {} bytes\n", .{struct_of_arrays_perf_test.monstersSizeInBytes()});

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("Array of structs", benchmarkArrayOfStructs, .{});
    try bench.add("Struct of arrays", benchmarkStructOfArrays, .{});

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

fn benchmarkStructOfArrays(allocator: std.mem.Allocator) void {
    const failed = struct_of_arrays_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkStructOfArrays: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}
