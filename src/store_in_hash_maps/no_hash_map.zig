const std = @import("std");
const ArrayList = std.ArrayList;

pub const Monster = struct { hp: u32, x: u32, y: u32, held_items: [4]u32 };

pub const NoHashMapPerfTest = struct {
    const Self = @This();
    monsters: ArrayList(Monster) = undefined,

    pub fn init(allocator: std.mem.Allocator, total_monsters: u32, percentageHeldItems: u9) !Self {
        var monsters = ArrayList(Monster).init(allocator);
        try monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const has_held_items: bool = i % 100 < percentageHeldItems;
            const monster = Monster{
                .hp = 100 + i,
                .x = 10 + i,
                .y = 20 + i,
                .held_items = if (has_held_items) [4]u32{ 0, 1, 2, 3 } else [4]u32{ 0, 0, 0, 0 },
            };

            try monsters.append(monster);
        }

        return Self{
            .monsters = monsters,
        };
    }

    pub fn monstersSizeInBytes(self: *Self) usize {
        return self.monsters.items.len * @sizeOf(Monster);
    }

    pub fn deinit(self: *Self) void {
        self.monsters.deinit();
    }

    pub fn run(self: *Self, _: std.mem.Allocator) !bool {
        // Simulate some work with the monsters
        for (self.monsters.items) |*monster| {
            var has_item_2 = false;
            for (monster.held_items) |item| {
                if (item == 1) {
                    has_item_2 = true;
                    break;
                }
            }

            if (has_item_2 and monster.hp > 0) {
                monster.hp -= 1;
            }
        }

        const failed = self.monsters.items[0].hp > 100000;
        return failed;
    }
};
