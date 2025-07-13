const ArrayList = std.ArrayList;
const std = @import("std");
const Animation = @import("common.zig").Animation;

pub const Monster = struct {
    anim: *Animation,
    hp: u32,
    y: u32,
};

pub const WithoutBoolPerfTest = struct {
    const Self = @This();

    alive_monsters: ArrayList(Monster),
    dead_monsters: ArrayList(Monster),
    animations: []Animation = undefined,
    max_dead_monsters: u32 = undefined,

    pub fn init(allocator: std.mem.Allocator, animations: []Animation, total_monsters: u32, max_dead_monsters: u32) !Self {
        var alive_monsters = ArrayList(Monster).init(allocator);
        try alive_monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const monster = Monster{
                .anim = &(animations[i % animations.len]),
                .hp = 100 + i,
                .y = 10 + i,
            };

            try alive_monsters.append(monster);
        }
        return Self{
            .alive_monsters = alive_monsters,
            .dead_monsters = ArrayList(Monster).init(allocator),
            .animations = animations,
            .max_dead_monsters = max_dead_monsters,
        };
    }

    pub fn deinit(self: *Self) void {
        self.alive_monsters.deinit();
        self.dead_monsters.deinit();
    }

    pub fn run(self: *Self, allocator: std.mem.Allocator) !bool {
        var monsters_to_die_indexes: ArrayList(u32) = ArrayList(u32).init(allocator);
        defer monsters_to_die_indexes.deinit();
        for (self.alive_monsters.items, 0..) |*monster, index| {
            // Simulate some work with the monster
            const max_y = monster.anim.some_value * 10;
            if (monster.y > max_y) {
                monster.y -= monster.anim.some_value;
            } else {
                monster.y += monster.anim.some_value;
            }

            const i: u32 = @intCast(index);
            if (monster.hp > 0 and self.dead_monsters.items.len < self.max_dead_monsters) {
                monster.hp -= 1;
            }

            if (monster.hp == 0) {
                try monsters_to_die_indexes.append(i);
                try self.dead_monsters.append(monster.*);
            }
        }

        for (0..monsters_to_die_indexes.items.len) |i| {
            const reversed_index = monsters_to_die_indexes.items.len - 1 - i;
            const monster_to_die_index = monsters_to_die_indexes.items[reversed_index];
            _ = self.alive_monsters.swapRemove(monster_to_die_index);
        }

        const failed = self.alive_monsters.items.len > 100000;
        return failed;
    }
};
