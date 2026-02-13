/// "Eliminate padding with struct of arrays instead of array of structs" optimization.
///
/// For 10_000 monsters with 8 animations:
/// Array of structs example memory allocation: 162.21875KiB
/// Struct of arrays example memory allocation: 122.767578125KiB
const std = @import("std");
const zbench = @import("zbench");

const ArrayOfStructsPerfTest = @import("array_of_structs.zig").ArrayOfStructsPerfTest;
const StructOfArraysPerfTest = @import("struct_of_arrays.zig").StructOfArraysPerfTest;
const initAnimations = @import("common.zig").initAnimations;

const total_monsters = 10_000;
const animationsCount = 8;
var array_of_structs_perf_test: ArrayOfStructsPerfTest = undefined;
var struct_of_arrays_perf_test: StructOfArraysPerfTest = undefined;

pub fn main() !void {
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const allocator = std.heap.page_allocator;

    const animations1 = try initAnimations(allocator, animationsCount);
    defer allocator.free(animations1);
    array_of_structs_perf_test = try ArrayOfStructsPerfTest.init(allocator, animations1, total_monsters);
    defer array_of_structs_perf_test.deinit();

    const animations2 = try initAnimations(allocator, animationsCount);
    defer allocator.free(animations2);
    struct_of_arrays_perf_test = try StructOfArraysPerfTest.init(allocator, animations2, total_monsters);
    defer struct_of_arrays_perf_test.deinit(allocator);

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("Array of structs", benchmarkArrayOfStructs, .{});
    try bench.add("Struct of arrays", benchmarkStructOfArrays, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
    try stdout.flush();

    try printMemoryArrayOfStructs();
    try printMemoryStructOfArrays();
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

fn printMemoryArrayOfStructs() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    const allocator = gpa.allocator();
    const animations = try initAnimations(allocator, animationsCount);
    defer allocator.free(animations);
    var temp_test = try ArrayOfStructsPerfTest.init(allocator, animations, total_monsters);
    defer temp_test.deinit();

    std.debug.print("Array of structs example memory allocation: {d} bytes\n", .{
        gpa.total_requested_bytes,
    });
}

fn printMemoryStructOfArrays() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    const allocator = gpa.allocator();
    const animations = try initAnimations(allocator, animationsCount);
    defer allocator.free(animations);
    var temp_test = try StructOfArraysPerfTest.init(allocator, animations, total_monsters);
    defer temp_test.deinit(allocator);

    std.debug.print("Struct of arrays example memory allocation: {d} bytes\n", .{
        gpa.total_requested_bytes,
    });
}
