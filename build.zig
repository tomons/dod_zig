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
        const example_module = b.createModule(.{
            .root_source_file = b.path(b.fmt("src/{s}.zig", .{example_name})),
            .target = target,
            .optimize = optimize,
        });

        const exampleExe = b.addExecutable(.{ .name = example_name, .root_module = example_module });
        const install_example = b.addInstallArtifact(exampleExe, .{});
        b.installArtifact(exampleExe);
        const opts = .{ .target = target, .optimize = optimize };
        const zbench_module = b.dependency("zbench", opts).module("zbench");
        exampleExe.root_module.addImport("zbench", zbench_module);
        example_step.dependOn(&exampleExe.step);
        example_step.dependOn(&install_example.step);

        const run_cmd = b.addRunArtifact(exampleExe);
        run_cmd.step.dependOn(b.getInstallStep());

        // This allows the user to pass arguments to the application in the build
        // command itself, like this: `zig build run -- arg1 arg2 etc`
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        // This creates a build step. It will be visible in the `zig build --help` menu,
        // and can be selected like this: `zig build run`
        // This will evaluate the `run` step rather than the default, which is "install".
        const run_step_name = b.fmt("run_{s}", .{example_name});
        const run_step_description = b.fmt("Run the example {s}", .{example_name});
        const run_step = b.step(run_step_name, run_step_description);
        run_step.dependOn(&run_cmd.step);
    }
}
