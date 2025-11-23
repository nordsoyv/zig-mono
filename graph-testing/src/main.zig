const rl = @import("raylib");
const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const createConstructor = @import("entities/constructor.zig").createConstructor;

const World = @import("world.zig");

pub fn main() !void {
    rl.initWindow(800, 600, "Hello Zig + Raylib");
    const allocator = std.heap.page_allocator;
    var world = try World.initWorld(allocator);
    defer world.deinit();
    try world.addItemPrototype("iron-ore");
    const proto = world.getItemPrototypeByName("iron-ore");
    if (proto) |p| {
        print("{f}\n", .{p.*});
    } else {
        print("ItemPrototype = null\n", .{});
    }

    try world.addRecipe("mine-iron-ore", 1, "iron-ore");
    const r = world.getRecipeByName("mine-iron-ore");
    if (r) |res| {
        _ = try world.addEntity(try createConstructor(allocator, res), .{ .rectangle = .{ .x = 100, .y = 100, .width = 200, .height = 100 } });
    } else {
        print("Recipe = null\n", .{});
    }

    while (!rl.windowShouldClose()) {
        try world.update();
        rl.beginDrawing();
        rl.clearBackground(rl.Color.dark_gray);
        try world.draw();
        //rl.DrawText("Hello from Zig on Windows!", 190, 200, 20, rl.LIGHTGRAY);

        // miner.draw();
        rl.endDrawing();
    }
    rl.closeWindow();
}
