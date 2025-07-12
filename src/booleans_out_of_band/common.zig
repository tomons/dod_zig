const std = @import("std");

pub const Animation = struct {
    frame_count: u32,
    some_value: u32,
};

pub fn initAnimations(allocator: std.mem.Allocator, length: u32) ![]Animation {
    var animations = try allocator.alloc(Animation, length);
    for (0..length) |index| {
        const i: u32 = @intCast(index);
        animations[i] = Animation{
            .frame_count = 10 + i,
            .some_value = i,
        };
    }
    return animations;
}
