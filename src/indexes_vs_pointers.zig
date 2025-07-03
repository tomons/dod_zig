// Use indexes instead of pointers:
// struct { a: *A, b: *B, c: *C, d: *D } takes 32 bytes on 64-bit CPUs, 16 bytes on 32-bit CPUs
// struct { a: u32, b: u32, c: u32, d: u32 } takes 16 bytes on 64-bit CPUs, 16 bytes on 32-bit CPUs
// However, we need to watch out for type safety.

const std = @import("std");
const zbench = @import("zbench");

const structElementsCount = 100000;

const StructOfPointers = struct {
    a: *u32,
    b: *u32,
    c: *u32,
    d: *u32,
};
var arrayOfStructsOfPointers: [structElementsCount]StructOfPointers = undefined;
var a1: u32 = 1;
var b1: u32 = 2;
var c1: u32 = 3;
var d1: u32 = 4;

fn initStructOfPointers() void {
    std.io.getStdOut().writer().writeAll("initStructOfPointers\n") catch unreachable;
    for (0..structElementsCount) |i| {
        arrayOfStructsOfPointers[i].a = &a1;
        arrayOfStructsOfPointers[i].b = &b1;
        arrayOfStructsOfPointers[i].c = &c1;
        arrayOfStructsOfPointers[i].d = &d1;
    }
}

const StructOfIndexes = struct {
    aIndex: u32,
    bIndex: u32,
    cIndex: u32,
    dIndex: u32,
};
var arrayOfStructsOfIndexes: [structElementsCount]StructOfIndexes = undefined;

var arrayA: [structElementsCount]u32 = undefined;
var arrayB: [structElementsCount]u32 = undefined;
var arrayC: [structElementsCount]u32 = undefined;
var arrayD: [structElementsCount]u32 = undefined;

fn initStructOfIndexes() void {
    std.io.getStdOut().writer().writeAll("initStructOfIndexes\n") catch unreachable;
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
    initStructOfIndexes();
    initStructOfPointers();

    const stdout = std.io.getStdOut().writer();
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

    if (sum == 0) @panic("result is wrong"); // Use result to prevent optimization
}

fn benchmarkStructOfIndexes(_: std.mem.Allocator) void {
    var sum: u64 = 0;
    for (arrayOfStructsOfIndexes) |el| {
        sum += arrayA[el.aIndex] + arrayB[el.bIndex] + arrayC[el.cIndex] + arrayD[el.dIndex];
    }

    if (sum == 0) @panic("result is wrong"); // Use result to prevent optimization
}
