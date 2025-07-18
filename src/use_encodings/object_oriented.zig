const std = @import("std");
const ArrayList = std.ArrayList;

pub const Monster = struct {
    tag: Tag,
    x: u32,
    y: u32,

    const Tag = enum {
        bee,
        human,
    };

    pub const Bee = struct { //16
        base: Monster, // 12
        color: Color, // 4
        const Color = enum { yellow, black, red };
    };

    pub const Human = struct { // 32
        base: Monster,
        hat: u32,
        shoes: u32,
        shirt: u32,
        pants: u32,
        has_braces: bool,
    };
};

pub const ObjectOrientedPerfTest = struct {
    const Self = @This();
    bees: ArrayList(Monster.Bee) = undefined,
    humans: ArrayList(Monster.Human) = undefined,

    pub fn init(allocator: std.mem.Allocator, total_monsters: u32, percentage_bees: u9, percentageClothedHumans: u9) !Self {
        const bees_total_float: f32 = @as(f32, @floatFromInt(total_monsters * percentage_bees)) / 100.0;
        const bees_total: u32 = @intFromFloat(@round(bees_total_float));
        const humans_total = total_monsters - bees_total;

        var bees = ArrayList(Monster.Bee).init(allocator);

        try bees.ensureTotalCapacity(bees_total);
        var humans = ArrayList(Monster.Human).init(allocator);
        try humans.ensureTotalCapacity(humans_total);

        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const one_to_hundred: u32 = i % 100;
            const is_bee: bool = one_to_hundred < percentage_bees;
            const is_clothed_human: bool = !is_bee and ((one_to_hundred - percentage_bees) < percentageClothedHumans);

            if (is_bee) {
                const bee: Monster.Bee = Monster.Bee{
                    .base = Monster{ .tag = .bee, .x = 10 + i, .y = 20 + i },
                    .color = .red,
                };
                try bees.append(bee);
            } else {
                const human: Monster.Human = Monster.Human{
                    .base = Monster{ .tag = .human, .x = 10 + i, .y = 20 + i },
                    .has_braces = false,
                    .hat = if (is_clothed_human) 1 else 0,
                    .pants = if (is_clothed_human) 2 else 0,
                    .shirt = if (is_clothed_human) 3 else 0,
                    .shoes = if (is_clothed_human) 4 else 0,
                };
                try humans.append(human);
            }
        }

        return Self{
            .bees = bees,
            .humans = humans,
        };
    }

    pub fn deinit(self: *Self) void {
        self.bees.deinit();
        self.humans.deinit();
    }

    pub fn run(self: *Self, _: std.mem.Allocator, max_coordinate: u32) !bool {
        // Simulate some work with the monsters
        for (self.bees.items) |*bee| {
            if (bee.base.x < max_coordinate) {
                bee.base.x += 1;
            }
            if (bee.base.y < max_coordinate) {
                bee.base.y += 2;
            }
        }
        for (self.humans.items) |*human| {
            if (human.base.x < max_coordinate) {
                human.base.x += 1;
                if (human.shoes > 0) {
                    human.base.x += 1;
                }
            }
            if (human.base.y < max_coordinate) {
                human.base.y += 1;
                if (human.has_braces) {
                    human.base.y += 1;
                }
            }
        }

        const failed = self.bees.items[0].base.x > max_coordinate;
        return failed;
    }
};
