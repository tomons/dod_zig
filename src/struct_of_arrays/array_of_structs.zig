const std = @import("std");
const ArrayList = std.ArrayList;
const Animation = @import("common.zig").Animation;

pub const Monster = struct {
    anim: *Animation,
    kind: Kind,

    const Kind = enum {
        snake,
        bat,
        wolf,
        dingo,
        human,
    };
};

pub const ArrayOfStructsPerfTest = struct {
    const Self = @This();
    monsters: ArrayList(Monster) = undefined,
    animations: []Animation = undefined,

    pub fn init(allocator: std.mem.Allocator, animations: []Animation, total_monsters: u32) !Self {
        var monsters = ArrayList(Monster).init(allocator);
        try monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const monster = Monster{
                .anim = &(animations[i % animations.len]),
                .kind = switch (i % 5) {
                    0 => Monster.Kind.snake,
                    1 => Monster.Kind.bat,
                    2 => Monster.Kind.wolf,
                    3 => Monster.Kind.dingo,
                    else => Monster.Kind.human,
                },
            };

            try monsters.append(monster);
        }
        return Self{
            .monsters = monsters,
            .animations = animations,
        };
    }

    pub fn deinit(self: *Self) void {
        self.monsters.deinit();
    }

    pub fn run(self: *Self, _: std.mem.Allocator) !bool {
        for (self.monsters.items) |*monster| {
            const some_value = monster.anim.some_value;
            // Simulate some work with the monster
            switch (monster.kind) {
                Monster.Kind.snake => monster.anim.some_value += 1,
                Monster.Kind.bat => monster.anim.some_value += if (some_value > 0) -1 else 1,
                Monster.Kind.wolf => monster.anim.some_value += 1,
                Monster.Kind.dingo => monster.anim.some_value += if (some_value > 0) -1 else 1,
                Monster.Kind.human => monster.anim.some_value += 1,
            }
        }

        const failed = self.monsters.items.len > 100000;
        return failed;
    }
};
