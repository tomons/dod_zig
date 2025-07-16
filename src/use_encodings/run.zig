const std = @import("std");
const SimpleMonster = @import("simple.zig").Monster;
const OOMonster = @import("object_oriented.zig").Monster;
const EncodedMonster = @import("encoded.zig").Monster;

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
}
