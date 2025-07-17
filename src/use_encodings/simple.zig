const std = @import("std");
const ArrayList = std.ArrayList;

pub const Monster = struct {
    x: u32,
    y: u32,
    extra: HumanOrBee,

    const HumanOrBee = union(enum) {
        bee: Bee,
        human: Human,
    };

    const Bee = struct {
        color: Color,
        const Color = enum { yellow, black, red };
    };

    const Human = struct {
        hat: u32,
        shoes: u32,
        shirt: u32,
        pants: u32,
        has_braces: bool,
    };
};

pub const SimplePerfTest = struct {
    const Self = @This();
    monsters: ArrayList(Monster) = undefined,

    pub fn init(allocator: std.mem.Allocator, total_monsters: u32, percentageBees: u9, percentageClothedHumans: u9) !Self {
        var monsters = ArrayList(Monster).init(allocator);
        try monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const one_to_hundred: u32 = i % 100;
            const is_bee: bool = one_to_hundred < percentageBees;
            const is_clothed_human: bool = !is_bee and ((one_to_hundred - percentageBees) < percentageClothedHumans);

            const human_or_bee: Monster.HumanOrBee = human_or_bee: {
                if (is_bee) {
                    break :human_or_bee .{ .bee = Monster.Bee{ .color = .red } };
                } else if (is_clothed_human) {
                    break :human_or_bee .{ .human = Monster.Human{ .hat = 1, .pants = 2, .shirt = 3, .shoes = 4, .has_braces = false } };
                } else { // naked human
                    break :human_or_bee .{ .human = Monster.Human{ .hat = 0, .pants = 0, .shirt = 0, .shoes = 0, .has_braces = false } };
                }
            };

            const monster = Monster{
                .x = 10 + i,
                .y = 20 + i,
                .extra = human_or_bee,
            };

            try monsters.append(monster);
        }

        return Self{
            .monsters = monsters,
        };
    }

    pub fn deinit(self: *Self) void {
        self.monsters.deinit();
    }

    pub fn run(self: *Self, _: std.mem.Allocator) !bool {
        // Simulate some work with the monsters
        for (self.monsters.items) |*monster| {
            if (monster.x < 1000) {
                monster.x += 1;
            }

            switch (monster.extra) {
                .bee => {
                    if (monster.y < 1000) {
                        monster.y += 2;
                    }
                },
                .human => {
                    if (monster.y < 1000) {
                        monster.y += 1;
                    }

                    if (monster.extra.human.has_braces) {
                        monster.x -= 1;
                    }
                },
            }
        }

        const failed = self.monsters.items[0].x > 100000;
        return failed;
    }
};
