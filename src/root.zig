const std = @import("std");
const time = std.time;
const Instant = time.Instant;
const Timer = time.Timer;
const print = std.debug.print;

pub export fn structOfPointersPerfTest() void {
    const cycles = 100000;

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

    var arrayOfStructs: [cycles]StructOfPointers = undefined;

    for (0..cycles) |i| {
        arrayOfStructs[i].a = &a1;
        arrayOfStructs[i].b = &b1;
        arrayOfStructs[i].c = &c1;
        arrayOfStructs[i].d = &d1;
    }

    var sum: u64 = 0;
    const start = Instant.now() catch unreachable;
    for (0..100) |i| {
        sum = i;
        for (arrayOfStructs) |el| {
            sum += el.a.* + el.b.* + el.c.* + el.d.*;
        }
    }
    const end = Instant.now() catch unreachable;
    const elapsed1: f64 = @floatFromInt(end.since(start));
    print("Sum is {} .Time elapsed is: {d:.3}ms\n", .{
        sum,
        elapsed1 / time.ns_per_ms,
    });
}
