// To run in relase fast mode: zig build run -Doptimize=ReleaseFast
pub fn main() !void {
    lib.structOfPointersPerfTest();
}

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("dod_design_lib");
