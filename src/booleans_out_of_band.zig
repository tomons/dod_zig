const std = @import("std");
const ArrayList = std.ArrayList;
const zbench = @import("zbench");

// Common data
const total_monsters = 1000;
const max_dead_monsters = 100;

const Animation = struct {
    frame_count: u32,
    current_frame: u32,
};

var animations: [8]Animation = undefined;

fn initCommonData() void {
    // init animations
    for (0..animations.len) |index| {
        const i: u32 = @intCast(index);
        animations[i] = Animation{
            .frame_count = 10 + i,
            .current_frame = 0,
        };
    }
}

const WithBoolPerfTest = struct {
    monsters: ArrayList(Monster) = undefined,

    const Monster = struct {
        anim: *Animation,
        hp: u32,
        y: u32,
        alive: bool,
    };

    fn init(allocator: std.mem.Allocator) !WithBoolPerfTest {
        var monsters = ArrayList(Monster).init(allocator);
        try monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const monster = Monster{
                .anim = &animations[i % animations.len],
                .hp = 100 + i,
                .y = 10 + i,
                .alive = true,
            };
            try monsters.append(monster);
        }

        return WithBoolPerfTest{
            .monsters = monsters,
        };
    }

    fn deinit(self: WithBoolPerfTest) void {
        self.monsters.deinit();
    }

    fn run(self: WithBoolPerfTest, _: std.mem.Allocator) bool {
        var dead_count: u32 = 0;
        for (self.monsters.items) |*monster| {
            if (!monster.alive) dead_count += 1;
        }

        for (self.monsters.items) |*monster| {
            if (!monster.alive) continue;

            // Simulate some work with the monster
            monster.anim.current_frame += 1;
            if (monster.anim.current_frame >= monster.anim.frame_count) {
                monster.anim.current_frame = 0;
            }

            if (monster.hp > 0 and dead_count < max_dead_monsters) {
                monster.hp -= 1;
            }

            if (monster.hp == 0) {
                // Monster dies
                monster.alive = false;
            }
        }

        const failed = self.monsters.items[12].anim.current_frame > 100;
        return failed;
    }
};

const WithoutBoolPerfTest = struct {
    alive_monsters: ArrayList(Monster),
    dead_monsters: ArrayList(Monster),

    const Monster = struct {
        anim: *Animation,
        hp: u32,
        y: u32,
    };

    fn init(allocator: std.mem.Allocator) !WithoutBoolPerfTest {
        var alive_monsters = ArrayList(Monster).init(allocator);
        try alive_monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const monster = Monster{
                .anim = &animations[i % animations.len],
                .hp = 100 + i,
                .y = 10 + i,
            };

            try alive_monsters.append(monster);
        }
        return WithoutBoolPerfTest{
            .alive_monsters = alive_monsters,
            .dead_monsters = ArrayList(Monster).init(allocator),
        };
    }

    fn deinit(self: WithoutBoolPerfTest) void {
        self.alive_monsters.deinit();
        self.dead_monsters.deinit();
    }

    fn run(self: *WithoutBoolPerfTest, allocator: std.mem.Allocator) !bool {
        var monsters_to_die_indexes: ArrayList(u32) = ArrayList(u32).init(allocator);
        defer monsters_to_die_indexes.deinit();
        for (self.alive_monsters.items, 0..) |*monster, index| {
            // Simulate some work with the monster
            const i: u32 = @intCast(index);
            monster.anim.current_frame += 1;
            if (monster.anim.current_frame >= monster.anim.frame_count) {
                monster.anim.current_frame = 0;
            }

            if (monster.hp > 0 and self.dead_monsters.items.len < max_dead_monsters) {
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

const IndexesInsteadOfPointersPerfTest = struct {
    alive_monsters: ArrayList(Monster),
    dead_monsters: ArrayList(Monster),

    const Monster = struct {
        anim_index: u32,
        hp: u32,
        y: u32,
    };

    fn init(allocator: std.mem.Allocator) !IndexesInsteadOfPointersPerfTest {
        var alive_monsters = ArrayList(Monster).init(allocator);
        try alive_monsters.ensureTotalCapacity(total_monsters);
        for (0..total_monsters) |index| {
            const i: u32 = @intCast(index);
            const len: u32 = @intCast(animations.len);
            const anim_index: u32 = i % len;
            const monster = Monster{
                .anim_index = anim_index,
                .hp = 100 + i,
                .y = 10 + i,
            };

            try alive_monsters.append(monster);
        }
        return IndexesInsteadOfPointersPerfTest{
            .alive_monsters = alive_monsters,
            .dead_monsters = ArrayList(Monster).init(allocator),
        };
    }

    fn deinit(self: IndexesInsteadOfPointersPerfTest) void {
        self.alive_monsters.deinit();
        self.dead_monsters.deinit();
    }

    fn run(self: *IndexesInsteadOfPointersPerfTest, allocator: std.mem.Allocator) !bool {
        var monsters_to_die_indexes: ArrayList(u32) = ArrayList(u32).init(allocator);
        defer monsters_to_die_indexes.deinit();
        for (self.alive_monsters.items, 0..) |*monster, index| {
            // Simulate some work with the monster
            const i: u32 = @intCast(index);
            const animation = &(animations[monster.anim_index]);
            animation.current_frame += 1;
            if (animation.current_frame >= animation.frame_count) {
                animation.current_frame = 0;
            }

            if (monster.hp > 0 and self.dead_monsters.items.len < max_dead_monsters) {
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

var with_bool_perf_test: WithBoolPerfTest = undefined;
var without_bool_perf_test: WithoutBoolPerfTest = undefined;
var indexes_instead_of_pointers_perf_test: IndexesInsteadOfPointersPerfTest = undefined;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of WithBoolPerfTest.Monster: {} bytes\n", .{@sizeOf(WithBoolPerfTest.Monster)});
    try stdout.print("Size of WithoutBoolPerfTest.Monster: {} bytes\n", .{@sizeOf(WithoutBoolPerfTest.Monster)});
    try stdout.print("Size of IndexesInsteadOfPointersPerfTest.Monster: {} bytes\n", .{@sizeOf(IndexesInsteadOfPointersPerfTest.Monster)});

    const allocator = std.heap.page_allocator;

    initCommonData();

    with_bool_perf_test = try WithBoolPerfTest.init(allocator);
    defer with_bool_perf_test.deinit();

    without_bool_perf_test = try WithoutBoolPerfTest.init(allocator);
    defer without_bool_perf_test.deinit();

    indexes_instead_of_pointers_perf_test = try IndexesInsteadOfPointersPerfTest.init(allocator);
    defer indexes_instead_of_pointers_perf_test.deinit();

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("With bool", benchmarkWithBool, .{});
    try bench.add("Without bool", benchmarkWithoutBool, .{});
    try bench.add("No bool indexes", benchmarkIndexesInsteadOfPointersBool, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkWithBool(allocator: std.mem.Allocator) void {
    const failed = with_bool_perf_test.run(allocator);
    if (failed) @panic("test failed");
}

fn benchmarkWithoutBool(allocator: std.mem.Allocator) void {
    const failed = without_bool_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkWithoutBool: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}

fn benchmarkIndexesInsteadOfPointersBool(allocator: std.mem.Allocator) void {
    const failed = indexes_instead_of_pointers_perf_test.run(allocator) catch |err| catch_block: {
        std.debug.print("Error in benchmarkIndexesInsteadOfPointersBool: {}\n", .{err});
        break :catch_block true;
    };
    if (failed) @panic("test failed");
}
