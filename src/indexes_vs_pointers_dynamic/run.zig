/// This one is a version of indexes_vs_pointers/run.zig with dynamic memory allocation.
const std = @import("std");
const zbench = @import("zbench");

//common data
const struct_elements_count = 1000000;
var array_a: [struct_elements_count]u32 = undefined;
var array_b: [struct_elements_count]u32 = undefined;
var array_c: [struct_elements_count]u32 = undefined;
var array_d: [struct_elements_count]u32 = undefined;

fn initCommonData() void {
    for (0..struct_elements_count) |i| {
        array_a[i] = 1;
        array_b[i] = 2;
        array_c[i] = 3;
        array_d[i] = 4;
    }
}

// StructOfPointers data
const StructOfPointers = struct {
    a: *u32,
    b: *u32,
    c: *u32,
    d: *u32,
};
var array_of_struct_of_pointers: []StructOfPointers = undefined;

fn initStructOfPointers(allocator: std.mem.Allocator) !void {
    array_of_struct_of_pointers = try allocator.alloc(StructOfPointers, struct_elements_count);
    for (0..struct_elements_count) |i| {
        array_of_struct_of_pointers[i].a = &(array_a[i]);
        array_of_struct_of_pointers[i].b = &(array_b[i]);
        array_of_struct_of_pointers[i].c = &(array_c[i]);
        array_of_struct_of_pointers[i].d = &(array_d[i]);
    }
}

fn deinitStructOfPointers(allocator: std.mem.Allocator) void {
    allocator.free(array_of_struct_of_pointers);
}

// StructOfIndexes data
const StructOfIndexes = struct {
    a_index: u32,
    b_index: u32,
    c_index: u32,
    d_index: u32,
};
var array_of_struct_of_indexes: []StructOfIndexes = undefined;

fn initStructOfIndexes(allocator: std.mem.Allocator) !void {
    array_of_struct_of_indexes = try allocator.alloc(StructOfIndexes, struct_elements_count);
    for (0..struct_elements_count) |i| {
        array_a[i] = 1;
        array_b[i] = 2;
        array_c[i] = 3;
        array_d[i] = 4;
        array_of_struct_of_indexes[i].a_index = @intCast(i);
        array_of_struct_of_indexes[i].b_index = @intCast(i);
        array_of_struct_of_indexes[i].c_index = @intCast(i);
        array_of_struct_of_indexes[i].d_index = @intCast(i);
    }
}

fn deinitStructOfIndexes(allocator: std.mem.Allocator) void {
    allocator.free(array_of_struct_of_indexes);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of StructOfIndexes: {} bytes\n", .{@sizeOf(StructOfIndexes)});
    try stdout.print("Size of StructOfPointers: {} bytes\n", .{@sizeOf(StructOfPointers)});

    initCommonData();
    const allocator = std.heap.page_allocator;
    try initStructOfIndexes(allocator);
    defer deinitStructOfIndexes(allocator);

    try initStructOfPointers(allocator);
    defer deinitStructOfPointers(allocator);

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("Struct of Indexes", benchmarkStructOfIndexes, .{});
    try bench.add("Struct of Pointers", benchmarkStructOfPointers, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkStructOfPointers(_: std.mem.Allocator) void {
    var sum: u64 = 0;
    for (array_of_struct_of_pointers) |el| {
        sum += el.a.* + el.b.* + el.c.* + el.d.*;
    }

    if (sum != 10 * struct_elements_count) @panic("sum is wrong"); // Use sum to prevent optimization
}

fn benchmarkStructOfIndexes(_: std.mem.Allocator) void {
    var sum: u64 = 0;
    for (array_of_struct_of_indexes) |el| {
        sum += array_a[el.a_index] + array_b[el.b_index] + array_c[el.c_index] + array_d[el.d_index];
    }

    if (sum != 10 * struct_elements_count) @panic("sum is wrong"); // Use sum to prevent optimization
}
