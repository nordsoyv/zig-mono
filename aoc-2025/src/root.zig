//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const day1 = @import("day1/root.zig");


pub fn run() !void {
    std.debug.print("day 1.\n", .{});
    try day1.task2( std.heap.page_allocator);
    //try day1.task2( );
}

