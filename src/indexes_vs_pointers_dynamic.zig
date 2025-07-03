// This one is a version of indexes_vs_pointers.zig with dynamic memory allocation.

const std = @import("std");
const zbench = @import("zbench");

const structElementsCount = 100000;//add zero and result changes in favor of struct of pointers interestingly

const StructOfPointers = struct {
    a: *u32,
    b: *u32,
    c: *u32,
    d: *u32,
};
var arrayOfStructsOfPointers: []StructOfPointers = undefined;
var a1: u32 = 1;
var b1: u32 = 2;
var c1: u32 = 3;
var d1: u32 = 4;

fn initStructOfPointers(allocator: std.mem.Allocator) !void {
    arrayOfStructsOfPointers = try allocator.alloc(StructOfPointers, structElementsCount);
    for (0..structElementsCount) |i| {
        arrayOfStructsOfPointers[i].a = &a1;
        arrayOfStructsOfPointers[i].b = &b1;
        arrayOfStructsOfPointers[i].c = &c1;
        arrayOfStructsOfPointers[i].d = &d1;
    }
}

fn deinitStructOfPointers(allocator: std.mem.Allocator) void {
    allocator.free(arrayOfStructsOfPointers);
}

const StructOfIndexes = struct {
    aIndex: u32,
    bIndex: u32,
    cIndex: u32,
    dIndex: u32,
};
var arrayOfStructsOfIndexes: []StructOfIndexes = undefined;

var arrayA: [structElementsCount]u32 = undefined;
var arrayB: [structElementsCount]u32 = undefined;
var arrayC: [structElementsCount]u32 = undefined;
var arrayD: [structElementsCount]u32 = undefined;

fn initStructOfIndexes(allocator: std.mem.Allocator) !void {
    arrayOfStructsOfIndexes = try allocator.alloc(StructOfIndexes, structElementsCount);
    for (0..structElementsCount) |i| {
        arrayA[i] = 1;
        arrayB[i] = 2;
        arrayC[i] = 3;
        arrayD[i] = 4;
        arrayOfStructsOfIndexes[i].aIndex = @intCast(i);
        arrayOfStructsOfIndexes[i].bIndex = @intCast(i);
        arrayOfStructsOfIndexes[i].cIndex = @intCast(i);
        arrayOfStructsOfIndexes[i].dIndex = @intCast(i);
    }
}

fn deinitStructOfIndexes(allocator: std.mem.Allocator) void{
    allocator.free(arrayOfStructsOfIndexes);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of StructOfIndexes: {} bytes\n", .{@sizeOf(StructOfIndexes)});
    try stdout.print("Size of StructOfPointers: {} bytes\n", .{@sizeOf(StructOfPointers)});

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
    for (arrayOfStructsOfPointers) |el| {
        sum += el.a.* + el.b.* + el.c.* + el.d.*;
    }

    if (sum != 1000000) @panic("result is wrong"); // Use result to prevent optimization
}

fn benchmarkStructOfIndexes(_: std.mem.Allocator) void {
    var sum: u64 = 0;
    for (arrayOfStructsOfIndexes) |el| {
        sum += arrayA[el.aIndex] + arrayB[el.bIndex] + arrayC[el.cIndex] + arrayD[el.dIndex];
    }

    if (sum != 1000000) @panic("result is wrong"); // Use result to prevent optimization
}
