const std = @import("std");
const ArrayList = std.ArrayList;
const MultiArrayList = std.MultiArrayList;

pub const Monster = struct {
    tag: Tag,
    common: Common,

    pub const Tag = enum {
        bee_yellow,
        bee_black,
        bee_red,

        human_naked,
        human_braces_naked,
        human_clothed,
        human_braces_clothed,
    };

    pub const Common = struct {
        x: u32,
        y: u32,
        extra_index: u32,
    };

    pub const HumanClothed = struct {
        hat: u32,
        shoes: u32,
        shirt: u32,
        pants: u32,
    };
};

pub const EncodedPerfTest = struct {
    const Self = @This();
    monsters: MultiArrayList(Monster) = undefined,
    monster_extras: ArrayList(Monster.HumanClothed) = undefined,

    pub fn init(allocator: std.mem.Allocator, total_monsters: u32, percentage_bees: u9, percentage_clothed_humans: u9) !Self {
        var monsters: MultiArrayList(Monster) = .{};
        try monsters.ensureTotalCapacity(allocator, total_monsters);

        const bees_total_float: f32 = @as(f32, @floatFromInt(total_monsters * percentage_bees)) / 100.0;
        const bees_total: u32 = @intFromFloat(@round(bees_total_float));
        const humans_total = total_monsters - bees_total;
        const naked_humans_total_float: f32 = @as(f32, @floatFromInt(humans_total * (100 - percentage_clothed_humans))) / 100.0;
        const naked_humans_total: u32 = @intFromFloat(@round(naked_humans_total_float));

        var monster_extras: ArrayList(Monster.HumanClothed) = .empty;
        try monster_extras.ensureTotalCapacity(allocator, naked_humans_total);

        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const one_to_hundred: u32 = i % 100;
            const is_bee: bool = one_to_hundred < percentage_bees;
            const is_clothed_human: bool = !is_bee and ((one_to_hundred - percentage_bees) < percentage_clothed_humans);

            const monster: Monster = Monster{
                .tag = if (is_bee)
                    .bee_red
                else if (is_clothed_human)
                    .human_clothed
                else
                    .human_naked,
                .common = Monster.Common{
                    .x = 10,
                    .y = 20,
                    .extra_index = if (is_clothed_human) @intCast(monster_extras.items.len) else 0,
                },
            };
            try monsters.append(allocator, monster);

            if (is_clothed_human) {
                try monster_extras.append(allocator, Monster.HumanClothed{
                    .hat = 1,
                    .shoes = 2,
                    .shirt = 3,
                    .pants = 4,
                });
            }
        }

        return Self{
            .monsters = monsters,
            .monster_extras = monster_extras,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.monsters.deinit(allocator);
        self.monster_extras.deinit(allocator);
    }

    pub fn run(self: *Self, _: std.mem.Allocator, max_coordinate: u32) !bool {
        // Simulate some work with the monsters
        for (self.monsters.items(.tag), self.monsters.items(.common)) |tag, *common| {
            const is_clothed_human = tag == .human_clothed or tag == .human_braces_clothed;
            const is_bee = tag == .bee_red or tag == .bee_yellow or tag == .bee_black;
            common.x += 1;
            if (is_clothed_human) {
                const extra = self.monster_extras.items[common.extra_index];
                if (extra.shoes > 0) {
                    common.x += 1;
                }
            }

            if (is_bee) {
                common.y += 2;
            } else if (is_clothed_human) {
                common.y += 1;
                if (tag == .human_braces_clothed) {
                    common.y += 1;
                }
            }

            if (common.x > max_coordinate) common.x = 1;
            if (common.y > max_coordinate) common.y = 1;
        }

        const failed = self.monsters.items(.common)[0].x > max_coordinate;
        return failed;
    }
};
