/// "Store sparse data in hash maps" optimization.
///
/// Size of no hash map example approximately: 280000 bytes
/// Size of with hash map example approximately: 140000 bytes
const std = @import("std");
const zbench = @import("zbench");

const NoHashMapPerfTest = @import("no_hash_map.zig").NoHashMapPerfTest;
const WithHashMapPerfTest = @import("with_hash_map.zig").WithHashMapPerfTest;

const total_monsters = 10_000;
const percentage_held_items: u9 = 10;
var no_hash_map_perf_test: NoHashMapPerfTest = undefined;
var with_hash_map_perf_test: WithHashMapPerfTest = undefined;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const allocator = std.heap.page_allocator;

    no_hash_map_perf_test = try NoHashMapPerfTest.init(allocator, total_monsters, percentage_held_items);
    defer no_hash_map_perf_test.deinit();
    try stdout.print("Size of no hash map example approximately: {} bytes\n", .{no_hash_map_perf_test.monstersSizeInBytes()});

    with_hash_map_perf_test = try WithHashMapPerfTest.init(allocator, total_monsters, percentage_held_items);
    defer with_hash_map_perf_test.deinit();
    try stdout.print("Size of with hash map example approximately: {} bytes\n", .{with_hash_map_perf_test.monstersSizeInBytes()});

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("No hash map", benchmarkNoHashMap, .{});
    try bench.add("With hash map", benchmarkWithHashMap, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkNoHashMap(allocator: std.mem.Allocator) void {
    const failed = no_hash_map_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkNoHashMap: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}

fn benchmarkWithHashMap(allocator: std.mem.Allocator) void {
    const failed = with_hash_map_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkWithHashMap: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}
