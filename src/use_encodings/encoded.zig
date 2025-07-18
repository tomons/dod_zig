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

    pub fn init(allocator: std.mem.Allocator, total_monsters: u32, percentageBees: u9, percentageClothedHumans: u9) !Self {
        var monsters: MultiArrayList(Monster) = .{};
        try monsters.ensureTotalCapacity(allocator, total_monsters);

        const beesTotal = total_monsters * percentageBees / 100; // todo use float and round
        const humansTotal = total_monsters - beesTotal;
        const nakedHumansTotal = humansTotal * (100 - percentageClothedHumans) / 100; // todo use float and round;

        var monster_extras = ArrayList(Monster.HumanClothed).init(allocator);
        try monster_extras.ensureTotalCapacity(nakedHumansTotal);

        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const one_to_hundred: u32 = i % 100;
            const is_bee: bool = one_to_hundred < percentageBees;
            const is_clothed_human: bool = !is_bee and ((one_to_hundred - percentageBees) < percentageClothedHumans);

            const monster: Monster = Monster{
                .tag = if (is_bee)
                    .bee_red
                else if (is_clothed_human)
                    .human_clothed
                else
                    .human_naked,
                .common = Monster.Common{
                    .x = 10 + i,
                    .y = 20 + i,
                    .extra_index = if (is_clothed_human) @intCast(monster_extras.items.len) else 0,
                },
            };
            try monsters.append(allocator, monster);

            if (is_clothed_human) {
                try monster_extras.append(Monster.HumanClothed{
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
        self.monster_extras.deinit();
    }

    pub fn run(self: *Self, _: std.mem.Allocator, max_coordinate: u32) !bool {
        // Simulate some work with the monsters
        for (self.monsters.items(.tag), self.monsters.items(.common)) |tag, *common| {
            const is_clothed_human = tag == .human_clothed or tag == .human_braces_clothed;
            const is_bee = tag == .bee_red or tag == .bee_yellow or tag == .bee_black;
            if (common.x < max_coordinate) {
                common.x += 1;
                if (is_clothed_human) {
                    const extra = self.monster_extras.items[common.extra_index];
                    if (extra.shoes > 0 and common.x < max_coordinate) {
                        common.x += 1;
                    }
                }
            }

            if (common.y < max_coordinate) {
                if (is_bee) {
                    common.y += 2;
                } else if (is_clothed_human) {
                    common.y += 1;
                    if (tag == .human_braces_clothed) {
                        common.y += 1;
                    }
                }
            }
        }

        const failed = self.monsters.items(.common)[0].x > max_coordinate;
        return failed;
    }
};
