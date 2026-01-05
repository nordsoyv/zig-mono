const std = @import("std");
const cdl = @import("cdl");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stderr_buf: [1024]u8 = undefined;
    var stderr_writer = std.fs.File.stderr().writer(&stderr_buf);
    const stderr = &stderr_writer.interface;

    var stdout_buf: [4096]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2 or std.mem.eql(u8, args[1], "help") or std.mem.eql(u8, args[1], "-h") or std.mem.eql(u8, args[1], "--help")) {
        try stderr.print(
            "Usage:\n  cdl lex <path/to/file.cdl>\n",
            .{},
        );
        try stderr.flush();
        return;
    }

    if (std.mem.eql(u8, args[1], "lex")) {
        if (args.len != 3) {
            try stderr.print(
                "Usage:\n  cdl lex <path/to/file.cdl>\n",
                .{},
            );
            try stderr.flush();
            return;
        }

        const path = args[2];
        const input = std.fs.cwd().readFileAlloc(allocator, path, 100 * 1024 * 1024) catch |err| {
            try stderr.print("Failed to read '{s}': {s}\n", .{ path, @errorName(err) });
            try stderr.flush();
            return;
        };
        defer allocator.free(input);

        var comp = cdl.compiler.Compiler.init(allocator);
        defer comp.deinit();

        comp.dumpTokens(stdout, input) catch |err| {
            try stderr.print("Lex failed: {s}\n", .{@errorName(err)});
            try stderr.flush();
            return;
        };
        try stdout.flush();
        return;
    }

    try stderr.print("Unknown command: {s}\n", .{args[1]});
    try stderr.flush();
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
