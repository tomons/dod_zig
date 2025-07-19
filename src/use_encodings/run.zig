/// "Use "encodings" instead of OOP/polymorphism" optimization.
///
/// For 50% bees and 50% clothed humans:
/// Size of SimpleMonster: 32 bytes
/// Size of OOMonster.Bee: 16 bytes
/// Size of OOMonster.Human: 32 bytes
/// Average Size of OOMonster: 24 bytes
/// Size of encoded bee monster in multi array list: 13 bytes
/// Size of encoded naked human monster in multi array list: 13 bytes
/// Size of encoded clothed human monster in array list: 29 bytes
/// Average size of encoded monster with use of multi array list and array list: 17 bytes
///
/// For 10_000_000 monsters with 50% bees and 50% clothed humans:
/// benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
/// -----------------------------------------------------------------------------------------------------------------------------
/// Simple monster         157      1.976s         12.589ms ± 49.999us    (12.514ms ... 12.746ms)      12.607ms   12.738ms   12.746ms
/// OO monster             85       1.995s         23.481ms ± 103.102us   (23.342ms ... 23.946ms)      23.513ms   23.946ms   23.946ms
/// Encoded monster        181      1.999s         11.045ms ± 84.941us    (10.964ms ... 11.941ms)      11.058ms   11.292ms   11.941ms
/// SimpleMonster example memory allocation: 349.4597473144531MiB
/// OOMonster example memory allocation: 259.44361877441406MiB
/// EncodedMonster example memory allocation: 261.94763374328613MiB
///
/// Reducing the number of monsters to 10_000 optimizations actually slows down the benchmarks:
/// benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
/// -----------------------------------------------------------------------------------------------------------------------------
/// Simple monster         100000   945.601ms      9.456us ± 10.235us     (7.123us ... 3.222ms)        9.499us    15.435us   16.622us
/// OO monster             100000   1.353s         13.539us ± 1.148us     (11.872us ... 68.863us)      14.247us   20.184us   21.371us
/// Encoded monster        100000   1.128s         11.283us ± 1.118us     (9.498us ... 39.181us)       11.873us   17.81us    18.997us
/// SimpleMonster example memory allocation: 362.96875KiB
/// OOMonster example memory allocation: 269.171875KiB
/// EncodedMonster example memory allocation: 271.7666015625KiB
///
const std = @import("std");
const zbench = @import("zbench");

const SimpleMonster = @import("simple.zig").Monster;
const SimpleMonsterPerfTest = @import("simple.zig").SimplePerfTest;

const OOMonster = @import("object_oriented.zig").Monster;
const OOMonsterPerfTest = @import("object_oriented.zig").ObjectOrientedPerfTest;

const EncodedMonster = @import("encoded.zig").Monster;
const EncodedMonsterPerfTest = @import("encoded.zig").EncodedPerfTest;

const total_monsters = 10_000_000;
const percentage_bees: u9 = 50; // out of all monsters
const percentage_clothed_humans: u9 = 50; // out of all humans
const max_coordinate = std.math.maxInt(u32) - 10;
var simple_monster_perf_test: SimpleMonsterPerfTest = undefined;
var oo_monster_perf_test: OOMonsterPerfTest = undefined;
var encoded_monster_perf_test: EncodedMonsterPerfTest = undefined;

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

    encoded_monster_perf_test = try EncodedMonsterPerfTest.init(allocator, total_monsters, percentage_bees, percentage_clothed_humans);
    defer encoded_monster_perf_test.deinit(allocator);

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("Simple monster", benchmarkSimpleMonster, .{});
    try bench.add("OO monster", benchmarkOOMonster, .{});
    try bench.add("Encoded monster", benchmarkEncodedMonster, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);

    try printMemoryUsageSimpleMonster();
    try printMemoryUsageOOMonster();
    try printMemoryUsageEncodedMonster();
}

fn benchmarkSimpleMonster(allocator: std.mem.Allocator) void {
    const failed = simple_monster_perf_test.run(allocator, max_coordinate) catch |err| catch_block: {
        std.debug.print("Error in benchmarkSimpleMonster: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}

fn benchmarkOOMonster(allocator: std.mem.Allocator) void {
    const failed = oo_monster_perf_test.run(allocator, max_coordinate) catch |err| catch_block: {
        std.debug.print("Error in benchmarkOOMonster: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}

fn benchmarkEncodedMonster(allocator: std.mem.Allocator) void {
    const failed = encoded_monster_perf_test.run(allocator, max_coordinate) catch |err| catch_block: {
        std.debug.print("Error in benchmarkEncodedMonster: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}

fn printMemoryUsageSimpleMonster() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    const allocator = gpa.allocator();

    var temp_test = try SimpleMonsterPerfTest.init(allocator, total_monsters, percentage_bees, percentage_clothed_humans);
    defer temp_test.deinit();

    std.debug.print("SimpleMonster example memory allocation: {}\n", .{
        std.fmt.fmtIntSizeBin(gpa.total_requested_bytes),
    });
}

fn printMemoryUsageOOMonster() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    const allocator = gpa.allocator();

    var temp_test = try OOMonsterPerfTest.init(allocator, total_monsters, percentage_bees, percentage_clothed_humans);
    defer temp_test.deinit();

    std.debug.print("OOMonster example memory allocation: {}\n", .{
        std.fmt.fmtIntSizeBin(gpa.total_requested_bytes),
    });
}

fn printMemoryUsageEncodedMonster() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    const allocator = gpa.allocator();

    var temp_test = try EncodedMonsterPerfTest.init(allocator, total_monsters, percentage_bees, percentage_clothed_humans);
    defer temp_test.deinit(allocator);

    std.debug.print("EncodedMonster example memory allocation: {}\n", .{
        std.fmt.fmtIntSizeBin(gpa.total_requested_bytes),
    });
}
