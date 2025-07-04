// Use indexes instead of pointers:
// struct { a: *A, b: *B, c: *C, d: *D } takes 32 bytes on 64-bit CPUs, 16 bytes on 32-bit CPUs
// struct { a: u32, b: u32, c: u32, d: u32 } takes 16 bytes on 64-bit CPUs, 16 bytes on 32-bit CPUs
// However, we need to watch out for type safety.

const std = @import("std");
const zbench = @import("zbench");

//common data
const structElementsCount = 100000;
var arrayA: [structElementsCount]u32 = undefined;
var arrayB: [structElementsCount]u32 = undefined;
var arrayC: [structElementsCount]u32 = undefined;
var arrayD: [structElementsCount]u32 = undefined;

fn initCommonData() void {
    for (0..structElementsCount) |i| {
        arrayA[i] = 1;
        arrayB[i] = 2;
        arrayC[i] = 3;
        arrayD[i] = 4;
    }
}

// StructOfPointers data
const StructOfPointers = struct {
    a: *u32,
    b: *u32,
    c: *u32,
    d: *u32,
};
var arrayOfStructsOfPointers: [structElementsCount]StructOfPointers = undefined;

fn initStructOfPointers() void {
    for (0..structElementsCount) |i| {
        arrayOfStructsOfPointers[i].a = &(arrayA[i]);
        arrayOfStructsOfPointers[i].b = &(arrayB[i]);
        arrayOfStructsOfPointers[i].c = &(arrayC[i]);
        arrayOfStructsOfPointers[i].d = &(arrayD[i]);
    }
}

// StructOfIndexes data
const StructOfIndexes = struct {
    aIndex: u32,
    bIndex: u32,
    cIndex: u32,
    dIndex: u32,
};
var arrayOfStructsOfIndexes: [structElementsCount]StructOfIndexes = undefined;

fn initStructOfIndexes() void {
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

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of StructOfIndexes: {} bytes\n", .{@sizeOf(StructOfIndexes)});
    try stdout.print("Size of StructOfPointers: {} bytes\n", .{@sizeOf(StructOfPointers)});

    initCommonData();
    initStructOfIndexes();
    initStructOfPointers();

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

    if (sum != 10 * structElementsCount) @panic("sum is wrong"); // Use sum to prevent optimization
}

fn benchmarkStructOfIndexes(_: std.mem.Allocator) void {
    var sum: u64 = 0;
    for (arrayOfStructsOfIndexes) |el| {
        sum += arrayA[el.aIndex] + arrayB[el.bIndex] + arrayC[el.cIndex] + arrayD[el.dIndex];
    }

    if (sum != 10 * structElementsCount) @panic("sum is wrong"); // Use sum to prevent optimization
}
