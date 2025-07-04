const std = @import("std");
const ArrayList = std.ArrayList;
const zbench = @import("zbench");

// Common data
const totalMonsters = 1000;

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
        const alive = i % 10 != 0; // every 10th monster is dead
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

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Size of MonsterWithBool: {} bytes\n", .{@sizeOf(MonsterWithBool)});

    const allocator = std.heap.page_allocator;

    initCommonData();
    try initMonstersWithBool(allocator);
    defer deinitMonstersWithBool();

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("With bool", benchmarkWithBool, .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}

fn benchmarkWithBool(_: std.mem.Allocator) void {
    for (monstersWithBool.items) |*monster| {
        if (monster.alive) {
            // Simulate some work with the monster
            monster.anim.current_frame += 1;
            if (monster.anim.current_frame >= monster.anim.frame_count) {
                monster.anim.current_frame = 0;
            }
            monster.hp -= 1;
            if (monster.hp == 0) {
                // Monster dies
                monster.alive = false;
            }
        }
    }

    // Use monstersWithBool to prevent optimization
    if (monstersWithBool.items[12].anim.current_frame > 100) @panic("Current frame of monster 12 is too high");
}
