const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const example_step = b.step("examples", "Build examples");
    const example_names = [_][]const u8{
        "indexes_vs_pointers",
        "indexes_vs_pointers_dynamic",
    };

    for (example_names) |example_name| {
        const example = b.addExecutable(.{
            .name = example_name,
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = b.fmt("src/{s}.zig", .{example_name}) } },
            .target = target,
            .optimize = optimize,
        });
        const install_example = b.addInstallArtifact(example, .{});
        const opts = .{ .target = target, .optimize = optimize };
        const zbench_module = b.dependency("zbench", opts).module("zbench");
        example.root_module.addImport("zbench", zbench_module);
        example_step.dependOn(&example.step);
        example_step.dependOn(&install_example.step);
    }

}
