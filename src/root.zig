const std = @import("std");
const time = std.time;
const Instant = time.Instant;
const Timer = time.Timer;

// Use indexes instead of pointers:
// struct { a: *A, b: *B, c: *C, d: *D } takes 32 bytes on 64-bit CPUs, 16 bytes on 32-bit CPUs
// struct { a: u32, b: u32, c: u32, d: u32 } takes 16 bytes on 64-bit CPUs, 16 bytes on 32-bit CPUs
// However, we need to watch out for type safety.

const structElementsCount = 100000;
const repeats: u32 = 100;

pub export fn structOfPointersPerfTest() u64 {
    var a1: u32 = 1;
    var b1: u32 = 2;
    var c1: u32 = 3;
    var d1: u32 = 4;

    const StructOfPointers = struct {
        a: *u32,
        b: *u32,
        c: *u32,
        d: *u32,
    };

    var arrayOfStructs: [structElementsCount]StructOfPointers = undefined;

    for (0..structElementsCount) |i| {
        arrayOfStructs[i].a = &a1;
        arrayOfStructs[i].b = &b1;
        arrayOfStructs[i].c = &c1;
        arrayOfStructs[i].d = &d1;
    }

    var sum: u64 = 0;

    for (0..repeats) |i| {
        sum = i;
        for (arrayOfStructs) |el| {
            sum += el.a.* + el.b.* + el.c.* + el.d.*;
        }
    }

    return sum;
}

pub export fn structOfIndexesPerfTest() u64 {
    var arrayA: [structElementsCount]u32 = undefined;
    var arrayB: [structElementsCount]u32 = undefined;
    var arrayC: [structElementsCount]u32 = undefined;
    var arrayD: [structElementsCount]u32 = undefined;

    const StructOfIndexes = struct {
        aIndex: u32,
        bIndex: u32,
        cIndex: u32,
        dIndex: u32,
    };

    var arrayOfStructs: [structElementsCount]StructOfIndexes = undefined;
    for (0..structElementsCount) |i| {
        arrayA[i] = 1;
        arrayB[i] = 2;
        arrayC[i] = 3;
        arrayD[i] = 4;
        arrayOfStructs[i].aIndex = @intCast(i);
        arrayOfStructs[i].bIndex = @intCast(i);
        arrayOfStructs[i].cIndex = @intCast(i);
        arrayOfStructs[i].dIndex = @intCast(i);
    }

    var sum: u64 = 0;
    for (0..repeats) |i| {
        sum = i;
        for (arrayOfStructs) |el| {
            sum += arrayA[el.aIndex] + arrayB[el.bIndex] + arrayC[el.cIndex] + arrayD[el.dIndex];
        }
    }

    return sum;
}
