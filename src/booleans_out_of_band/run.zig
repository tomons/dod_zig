/// "Store booleans out of band" optimization.
///
/// WithBoolMonster: 24 bytes
/// WithoutBoolMonster: 16 bytes
/// IndexesInsteadOfPointersMonster: 12 bytes
const std = @import("std");
const zbench = @import("zbench");

const WithBoolPerfTest = @import("with_bool_perf_test.zig").WithBoolPerfTest;
const WithBoolMonster = @import("with_bool_perf_test.zig").Monster;

const WithoutBoolPerfTest = @import("without_bool_perf_test.zig").WithoutBoolPerfTest;
const WithoutBoolMonster = @import("without_bool_perf_test.zig").Monster;

const IndexesInsteadOfPointersPerfTest = @import("indexes_instead_of_pointers_perf_test.zig").IndexesInsteadOfPointersPerfTest;
const IndexesInsteadOfPointersMonster = @import("indexes_instead_of_pointers_perf_test.zig").Monster;

const initAnimations = @import("common.zig").initAnimations;

const total_monsters = 1000;
const max_dead_monsters = 100;

var with_bool_perf_test: WithBoolPerfTest = undefined;
var without_bool_perf_test: WithoutBoolPerfTest = undefined;
var indexes_instead_of_pointers_perf_test: IndexesInsteadOfPointersPerfTest = undefined;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of WithBoolMonster: {} bytes\n", .{@sizeOf(WithBoolMonster)});
    try stdout.print("Size of WithoutBoolMonster: {} bytes\n", .{@sizeOf(WithoutBoolMonster)});
    try stdout.print("Size of IndexesInsteadOfPointersMonster: {} bytes\n", .{@sizeOf(IndexesInsteadOfPointersMonster)});

    const allocator = std.heap.page_allocator;

    const animations = try initAnimations(allocator, 8);
    defer allocator.free(animations);

    with_bool_perf_test = try WithBoolPerfTest.init(allocator, animations, total_monsters, max_dead_monsters);
    defer with_bool_perf_test.deinit();

    without_bool_perf_test = try WithoutBoolPerfTest.init(allocator, animations, total_monsters, max_dead_monsters);
    defer without_bool_perf_test.deinit();

    indexes_instead_of_pointers_perf_test = try IndexesInsteadOfPointersPerfTest.init(allocator, animations, total_monsters, max_dead_monsters);
    defer indexes_instead_of_pointers_perf_test.deinit();

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("With bool", benchmarkWithBool, .{});
    try bench.add("No bool", benchmarkWithoutBool, .{});
    try bench.add("No bool no pointers", benchmarkIndexesInsteadOfPointers, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkWithBool(allocator: std.mem.Allocator) void {
    const failed = with_bool_perf_test.run(allocator);
    if (failed) @panic("test failed");
}

fn benchmarkWithoutBool(allocator: std.mem.Allocator) void {
    const failed = without_bool_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkWithoutBool: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}

fn benchmarkIndexesInsteadOfPointers(allocator: std.mem.Allocator) void {
    const failed = indexes_instead_of_pointers_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkIndexesInsteadOfPointers: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}
