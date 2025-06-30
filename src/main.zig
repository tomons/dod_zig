// To run in relase fast mode: zig build run -Doptimize=ReleaseFast
pub fn main() !void {
    for (0..10) |_| {
        lib.structOfIndexesPerfTest();
        lib.structOfPointersPerfTest();
    }
}

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("dod_design_lib");
