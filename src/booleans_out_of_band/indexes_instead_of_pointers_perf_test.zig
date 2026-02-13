const ArrayList = std.ArrayList;
const std = @import("std");
const Animation = @import("common.zig").Animation;

pub const Monster = struct {
    anim_index: u32,
    hp: u32,
    y: u32,
};

pub const IndexesInsteadOfPointersPerfTest = struct {
    const Self = @This();

    alive_monsters: ArrayList(Monster),
    dead_monsters: ArrayList(Monster),
    animations: []Animation = undefined,
    max_dead_monsters: u32 = undefined,
    allocator: std.mem.Allocator = undefined,

    pub fn init(allocator: std.mem.Allocator, animations: []Animation, total_monsters: u32, max_dead_monsters: u32) !Self {
        var alive_monsters: ArrayList(Monster) = .empty;
        try alive_monsters.ensureTotalCapacity(allocator, total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const len: u32 = @intCast(animations.len);
            const anim_index: u32 = i % len;
            const monster = Monster{
                .anim_index = anim_index,
                .hp = 100 + i,
                .y = 10 + i,
            };

            try alive_monsters.append(allocator, monster);
        }
        return Self{
            .alive_monsters = alive_monsters,
            .dead_monsters = .empty,
            .animations = animations,
            .max_dead_monsters = max_dead_monsters,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.alive_monsters.deinit(self.allocator);
        self.dead_monsters.deinit(self.allocator);
    }

    pub fn run(self: *Self, allocator: std.mem.Allocator) !bool {
        var monsters_to_die_indexes: ArrayList(u32) = .empty;
        defer monsters_to_die_indexes.deinit(allocator);
        for (self.alive_monsters.items, 0..) |*monster, index| {
            // Simulate some work with the monster
            const anim = self.animations[monster.anim_index];
            const max_y = anim.some_value * 10;
            if (monster.y > max_y) {
                monster.y -= anim.some_value;
            } else {
                monster.y += anim.some_value;
            }
            const i: u32 = @intCast(index);

            if (monster.hp > 0 and self.dead_monsters.items.len < self.max_dead_monsters) {
                monster.hp -= 1;
            }

            if (monster.hp == 0) {
                try monsters_to_die_indexes.append(allocator, i);
                try self.dead_monsters.append(allocator, monster.*);
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
