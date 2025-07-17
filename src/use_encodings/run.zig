const std = @import("std");
const zbench = @import("zbench");

const SimpleMonster = @import("simple.zig").Monster;
const SimpleMonsterPerfTest = @import("simple.zig").SimplePerfTest;

const OOMonster = @import("object_oriented.zig").Monster;
const OOMonsterPerfTest = @import("object_oriented.zig").ObjectOrientedPerfTest;

const EncodedMonster = @import("encoded.zig").Monster;

const total_monsters = 10_000;
const percentage_bees: u9 = 50;
const percentage_clothed_humans: u9 = 50; // out of all humans
var simple_monster_perf_test: SimpleMonsterPerfTest = undefined;
var oo_monster_perf_test: OOMonsterPerfTest = undefined;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of SimpleMonster: {} bytes\n", .{@sizeOf(SimpleMonster)});
    const ooBeeSize: u32 = @sizeOf(OOMonster.Bee);
    const ooHumanSize: u32 = @sizeOf(OOMonster.Human);
    const ooAverageSize: u32 = (ooBeeSize + ooHumanSize) / 2;
    try stdout.print("Size of OOMonster.Bee: {} bytes\n", .{ooBeeSize});
    try stdout.print("Size of OOMonster.Human: {} bytes\n", .{ooHumanSize});
    try stdout.print("Average Size of OOMonster: {} bytes\n", .{ooAverageSize});

    const encodedBeeSizeInMultiArrayList: u32 = @sizeOf(EncodedMonster.Tag) + @sizeOf(EncodedMonster.Common);
    const encodedNakedHumanSizeInMultiArrayList: u32 = encodedBeeSizeInMultiArrayList;
    const encodedClothedHumanSizeInArrayList: u32 = encodedNakedHumanSizeInMultiArrayList + @sizeOf(EncodedMonster.HumanClothed);
    // assuming half are bees, half are humans of which half are naked and half are clothed
    const encodedSum: f32 = @floatFromInt(encodedBeeSizeInMultiArrayList * 2 + encodedNakedHumanSizeInMultiArrayList + encodedClothedHumanSizeInArrayList);
    const encodedAverageSize: f32 = encodedSum / 4;
    try stdout.print("Size of encoded bee monster in multi array list: {} bytes\n", .{encodedBeeSizeInMultiArrayList});
    try stdout.print("Size of encoded naked human monster in multi array list: {} bytes\n", .{encodedNakedHumanSizeInMultiArrayList});
    try stdout.print("Size of encoded clothed human monster in array list: {} bytes\n", .{encodedClothedHumanSizeInArrayList});
    try stdout.print("Average size of encoded monster with use of multi array list and array list: {d} bytes\n", .{encodedAverageSize});

    const allocator = std.heap.page_allocator;

    simple_monster_perf_test = try SimpleMonsterPerfTest.init(allocator, total_monsters, percentage_bees, percentage_clothed_humans);
    defer simple_monster_perf_test.deinit();

    oo_monster_perf_test = try OOMonsterPerfTest.init(allocator, total_monsters, percentage_bees, percentage_clothed_humans);
    defer oo_monster_perf_test.deinit();

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("Simple monster", benchmarkSimpleMonster, .{});
    try bench.add("OO monster", benchmarkOOMonster, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkSimpleMonster(allocator: std.mem.Allocator) void {
    const failed = simple_monster_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkSimpleMonster: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}

fn benchmarkOOMonster(allocator: std.mem.Allocator) void {
    const failed = oo_monster_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkOOMonster: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}
