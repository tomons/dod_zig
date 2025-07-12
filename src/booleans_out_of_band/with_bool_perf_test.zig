const ArrayList = std.ArrayList;
const std = @import("std");
const Animation = @import("common.zig").Animation;

pub const Monster = struct {
    anim: *Animation,
    hp: u32,
    y: u32,
    alive: bool,
};

pub const WithBoolPerfTest = struct {
    const Self = @This();

    monsters: ArrayList(Monster) = undefined,
    animations: []Animation = undefined,
    max_dead_monsters: u32 = undefined,

    pub fn init(allocator: std.mem.Allocator, animations: []Animation, total_monsters: u32, max_dead_monsters: u32) !Self {
        var monsters = ArrayList(Monster).init(allocator);
        try monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const monster = Monster{
                .anim = &(animations[i % animations.len]),
                .hp = 100 + i,
                .y = 10 + i,
                .alive = true,
            };
            try monsters.append(monster);
        }

        return Self{
            .monsters = monsters,
            .animations = animations,
            .max_dead_monsters = max_dead_monsters,
        };
    }

    pub fn deinit(self: Self) void {
        self.monsters.deinit();
    }

    pub fn run(self: Self, _: std.mem.Allocator) bool {
        var dead_count: u32 = 0;
        for (self.monsters.items) |*monster| {
            if (!monster.alive) dead_count += 1;
        }

        for (self.monsters.items) |*monster| {
            if (!monster.alive) continue;

            // Simulate some work with the monster
            const max_y = monster.anim.some_value * 10;
            if (monster.y > max_y) {
                monster.y -= monster.anim.some_value;
            } else {
                monster.y += monster.anim.some_value;
            }

            if (monster.hp > 0 and dead_count < self.max_dead_monsters) {
                monster.hp -= 1;
            }

            if (monster.hp == 0) {
                // Monster dies
                monster.alive = false;
            }
        }

        const failed = self.monsters.items.len > 100000;
        return failed;
    }
};
