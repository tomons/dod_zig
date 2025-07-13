const std = @import("std");
const MultiArrayList = std.MultiArrayList;
const Animation = @import("common.zig").Animation;

pub const Monster = struct {
    anim: *Animation,
    kind: Kind,
};

const Kind = enum {
    snake,
    bat,
    wolf,
    dingo,
    human,
};

pub const StructOfArraysPerfTest = struct {
    const Self = @This();
    monsters: MultiArrayList(Monster) = undefined,
    animations: []Animation = undefined,

    pub fn init(allocator: std.mem.Allocator, animations: []Animation, total_monsters: u32) !Self {
        var monsters: MultiArrayList(Monster) = .{};
        try monsters.ensureTotalCapacity(allocator, total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const monster = Monster{
                .anim = &(animations[i % animations.len]),
                .kind = switch (i % 5) {
                    0 => Kind.snake,
                    1 => Kind.bat,
                    2 => Kind.wolf,
                    3 => Kind.dingo,
                    else => Kind.human,
                },
            };

            try monsters.append(allocator, monster);
        }
        return Self{
            .monsters = monsters,
            .animations = animations,
        };
    }

    pub fn monstersSizeInBytes(self: *Self) usize {
        const animItems = self.monsters.items(.anim);
        const kindItems = self.monsters.items(.kind);
        return animItems.len * @sizeOf(*Animation) + kindItems.len * @sizeOf(Kind);
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.monsters.deinit(allocator);
    }

    pub fn run(self: *Self, _: std.mem.Allocator) !bool {
        for (self.monsters.items(.anim), self.monsters.items(.kind)) |anim, kind| {
            const some_value = anim.some_value;
            // Simulate some work with the monster
            switch (kind) {
                Kind.snake => anim.some_value += 1,
                Kind.bat => anim.some_value += if (some_value > 0) -1 else 1,
                Kind.wolf => anim.some_value += 1,
                Kind.dingo => anim.some_value += if (some_value > 0) -1 else 1,
                Kind.human => anim.some_value += 1,
            }
        }

        const failed = self.monsters.len > 100000;
        return failed;
    }
};
