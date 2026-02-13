/// "Store sparse data in hash maps" optimization.
///
/// For 10_000 monsters with 10% held items:
/// No hash map example memory allocation: 317.59765625KiB
/// With hash map example meomry allocation: 193.20703125KiB
const std = @import("std");
const zbench = @import("zbench");

const NoHashMapPerfTest = @import("no_hash_map.zig").NoHashMapPerfTest;
const WithHashMapPerfTest = @import("with_hash_map.zig").WithHashMapPerfTest;

const total_monsters = 10_000;
const percentage_held_items: u9 = 10;
var no_hash_map_perf_test: NoHashMapPerfTest = undefined;
var with_hash_map_perf_test: WithHashMapPerfTest = undefined;

pub fn main() !void {
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const allocator = std.heap.page_allocator;

    no_hash_map_perf_test = try NoHashMapPerfTest.init(allocator, total_monsters, percentage_held_items);
    defer no_hash_map_perf_test.deinit();

    with_hash_map_perf_test = try WithHashMapPerfTest.init(allocator, total_monsters, percentage_held_items);
    defer with_hash_map_perf_test.deinit();

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("No hash map", benchmarkNoHashMap, .{});
    try bench.add("With hash map", benchmarkWithHashMap, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
    try stdout.flush();

    try printMemoryUsageNoHashMap();
    try printMemoryUsageWithHashMap();
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

fn printMemoryUsageNoHashMap() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    const allocator = gpa.allocator();

    var temp_test = try NoHashMapPerfTest.init(allocator, total_monsters, percentage_held_items);
    defer temp_test.deinit();

    std.debug.print("No hash map example memory allocation: {d} bytes\n", .{
        gpa.total_requested_bytes,
    });
}

fn printMemoryUsageWithHashMap() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    const allocator = gpa.allocator();

    var temp_test = try WithHashMapPerfTest.init(allocator, total_monsters, percentage_held_items);
    defer temp_test.deinit();

    std.debug.print("With hash map example memory allocation: {d} bytes\n", .{
        gpa.total_requested_bytes,
    });
}
