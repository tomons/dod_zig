const std = @import("std");
const ArrayList = std.ArrayList;
const zbench = @import("zbench");

// Common data
const totalMonsters = 1000;
const everyNthMonsterIsDeadInitially = 100; // every 100th monster is dead
const maxDeadMonsters = 200;

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

// MonsterWithBool data
const MonsterWithBool = struct {
    anim: *Animation,
    hp: u32,
    y: u32,
    alive: bool,
};

var monstersWithBool: ArrayList(MonsterWithBool) = undefined;

fn initMonstersWithBool(allocator: std.mem.Allocator) !void {
    monstersWithBool = ArrayList(MonsterWithBool).init(allocator);
    try monstersWithBool.ensureTotalCapacity(totalMonsters);
    for (0..totalMonsters) |index| {
        const i: u32 = @intCast(index);
        const alive = i % everyNthMonsterIsDeadInitially != 0;
        const monster = MonsterWithBool{
            .anim = &animations[i % animations.len],
            .hp = if (alive) 100 + i else 0,
            .y = 10 + i,
            .alive = alive,
        };
        try monstersWithBool.append(monster);
    }
}

fn deinitMonstersWithBool() void {
    monstersWithBool.deinit();
}

// MonstersWithoutBool data
const MonsterWithoutBool = struct {
    anim: *Animation,
    hp: u32,
    y: u32,
};

var alive_monsters_without_bool: ArrayList(MonsterWithoutBool) = undefined;
var dead_monsters_without_bool: ArrayList(MonsterWithoutBool) = undefined;

fn initMonstersWithoutBool(allocator: std.mem.Allocator) !void {
    alive_monsters_without_bool = ArrayList(MonsterWithoutBool).init(allocator);
    try alive_monsters_without_bool.ensureTotalCapacity(totalMonsters);
    dead_monsters_without_bool = ArrayList(MonsterWithoutBool).init(allocator);
    for (0..totalMonsters) |index| {
        const i: u32 = @intCast(index);
        const alive = i % everyNthMonsterIsDeadInitially != 0; // every 100th monster is dead
        const monster = MonsterWithoutBool{
            .anim = &animations[i % animations.len],
            .hp = if (alive) 100 + i else 0,
            .y = 10 + i,
        };
        if (alive) {
            try alive_monsters_without_bool.append(monster);
        } else {
            try dead_monsters_without_bool.append(monster);
        }
    }
}

fn deinitMonstersWithoutBool() void {
    alive_monsters_without_bool.deinit();
    dead_monsters_without_bool.deinit();
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of MonsterWithBool: {} bytes\n", .{@sizeOf(MonsterWithBool)});
    try stdout.print("Size of MonsterWithoutBool: {} bytes\n", .{@sizeOf(MonsterWithoutBool)});

    const allocator = std.heap.page_allocator;

    initCommonData();

    try initMonstersWithBool(allocator);
    defer deinitMonstersWithBool();

    try initMonstersWithoutBool(allocator);
    defer deinitMonstersWithoutBool();

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("With bool", benchmarkWithBool, .{});
    try bench.add("Without bool", benchmarkWithoutBool, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkWithBool(_: std.mem.Allocator) void {
    var dead_count: u32 = 0;
    for (monstersWithBool.items) |*monster| {
        if (!monster.alive) dead_count += 1;
    }

    for (monstersWithBool.items) |*monster| {
        if (monster.alive) {
            // Simulate some work with the monster
            monster.anim.current_frame += 1;
            if (monster.anim.current_frame >= monster.anim.frame_count) {
                monster.anim.current_frame = 0;
            }

            if (monster.hp > 0 and dead_count < maxDeadMonsters) {
                monster.hp -= 1;
            }

            if (monster.hp == 0) {
                // Monster dies
                monster.alive = false;
            }
        }
    }

    // Use monstersWithBool to prevent optimization
    if (monstersWithBool.items[12].anim.current_frame > 100) @panic("Current frame of monster 12 is too high");
}

fn benchmarkWithoutBool(allocator: std.mem.Allocator) void {
    var monsters_to_die_indexes: ArrayList(u32) = ArrayList(u32).init(allocator);
    defer monsters_to_die_indexes.deinit();
    for (alive_monsters_without_bool.items, 0..) |*monster, index| {
        // Simulate some work with the monster
        const i: u32 = @intCast(index);
        monster.anim.current_frame += 1;
        if (monster.anim.current_frame >= monster.anim.frame_count) {
            monster.anim.current_frame = 0;
        }

        if (monster.hp > 0 and dead_monsters_without_bool.items.len < maxDeadMonsters) {
            monster.hp -= 1;
        }

        if (monster.hp == 0) {
            monsters_to_die_indexes.append(i) catch unreachable;
            dead_monsters_without_bool.append(monster.*) catch unreachable;
        }
    }

    for (0..monsters_to_die_indexes.items.len) |i| {
        const reversed_index = monsters_to_die_indexes.items.len - 1 - i;
        const monster_to_die_index = monsters_to_die_indexes.items[reversed_index];
        _ = alive_monsters_without_bool.swapRemove(monster_to_die_index);
    }

    // Use monstersWithBool to prevent optimization
    if (alive_monsters_without_bool.items.len > 100000) @panic("wrong items length");
}
