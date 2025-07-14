const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;

pub const Monster = struct { hp: u32, x: u32, y: u32 };

pub const WithHashMapPerfTest = struct {
    const Self = @This();
    monsters: ArrayList(Monster) = undefined,
    held_items: AutoHashMap(u32, [4]u32) = undefined,

    pub fn init(allocator: std.mem.Allocator, total_monsters: u32, percentageHeldItems: u9) !Self {
        var monsters = ArrayList(Monster).init(allocator);
        try monsters.ensureTotalCapacity(total_monsters);
        var held_items = AutoHashMap(u32, [4]u32).init(allocator);
        try held_items.ensureTotalCapacity(total_monsters / 100 * percentageHeldItems);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const monster = Monster{
                .hp = 100 + i,
                .x = 10 + i,
                .y = 20 + i,
            };

            try monsters.append(monster);

            if (i % 100 < percentageHeldItems) {
                try held_items.put(i, [4]u32{ 0, 1, 2, 3 });
            }
        }

        return Self{
            .monsters = monsters,
            .held_items = held_items,
        };
    }

    pub fn monstersSizeInBytes(self: *Self) usize {
        return self.monsters.items.len * @sizeOf(Monster) + self.held_items.count() * @sizeOf([4]u32) + self.held_items.count() * @sizeOf(u32);
    }

    pub fn deinit(self: *Self) void {
        self.monsters.deinit();
        self.held_items.deinit();
    }

    pub fn run(self: *Self, _: std.mem.Allocator) !bool {
        // Simulate some work with the monsters
        for (self.monsters.items, 0..) |*monster, index| {
            var has_item_2 = false;
            const i: u32 = @intCast(index);
            const held_items = self.held_items.get(i);

            if (held_items != null) {
                has_item_2 = held_items.?[1] > 0;
            }

            if (has_item_2 and monster.hp > 0) {
                monster.hp -= 1;
            }
        }

        const failed = self.monsters.items[0].hp > 100000;
        return failed;
    }
};
