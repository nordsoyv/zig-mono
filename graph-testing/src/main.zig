const rl = @cImport({
    @cInclude("raylib.h");
});
const std = @import("std");
const print = std.debug.print;


const ArrayList = std.ArrayList;
const EntityType = union(enum) { Constructor: ConstructorData };

const ConstructorData = struct { recipe: ?*Recipe };

const Recipe = struct {
    name: []u8,
    timeTaken: f32,
    output: ItemPrototype,
    pub fn init(allocator: *std.mem.Allocator, input: []const u8, time: f32) Recipe {
        //const buf = try allocator.alloc(u8, input.len);
        // Copy the string into the buffer
        const buf = try allocator.dupe(u8, input);
        return Recipe{ .name = buf, .allocator = allocator, .timeTaken = time };
    }
};

const ItemPrototype = struct {
    name: []u8,
    pub fn init(allocator: *const std.mem.Allocator, input: []const u8) !ItemPrototype {
        const buf = try allocator.dupe(u8, input);
        return ItemPrototype{
            .name = buf,
        };
    }
    pub fn createItem(self: ItemPrototype) Item {
        const item = Item{ .name = self.name[0..self.name.len] };
        return item;
    }
    pub fn format(
        self: ItemPrototype,
        writer: anytype,
    ) !void {
        try writer.print("ItemPrototype( name = \"{s}\" )", .{self.name});
    }
};
const Item = struct { name: []u8 };
const UiData = struct { rectangle: rl.Rectangle };

const Entity = struct {
    id: u32,
    type: EntityType,
    uiData: ?UiData,
    pub fn draw(self: Entity) void {
        switch (self.type) {
            EntityType.Constructor => {
                DrawConstructor(self);
            },
        }
    }
};

pub fn DrawConstructor(e: Entity) void {
    if (e.uiData) |data| {
        rl.DrawRectangleRounded(data.rectangle, 0.2, 10, rl.BLUE);
    }
}

const Game = struct {
    allocator: *const std.mem.Allocator,
    recipes: ArrayList(Recipe),
    itemPrototypes: ArrayList(ItemPrototype),
    pub fn init(allocator: *const std.mem.Allocator) !Game {
        return Game{ .allocator = allocator, .itemPrototypes = try ArrayList(ItemPrototype).initCapacity(allocator.*, 0), .recipes = try ArrayList(Recipe).initCapacity(allocator.*, 0) };
    }
    pub fn deinit(self: *Game) void {
        self.itemPrototypes.deinit(self.allocator.*);
        self.recipes.deinit(self.allocator.*);
    }
    pub fn addItemPrototype(self: *Game, input: []const u8) !void {
        // Create a new ItemPrototype using the allocator
        const proto = try ItemPrototype.init(self.allocator, input);
        // Append it to the ArrayList
        try self.itemPrototypes.append(self.allocator.*, proto);
    }
    pub fn getItemPrototypeByName(self: *Game, name: []const u8) ?*ItemPrototype {
        for (self.itemPrototypes.items) |*proto| {
            if (std.mem.eql(u8, proto.name, name)) {
                return proto; // return pointer to the matching prototype
            }
        }
        return null; // not found
    }
};

pub fn main() !void {
    rl.InitWindow(800, 600, "Hello Zig + Raylib");
    const allocator = std.heap.page_allocator;
    var game = Game.init(&allocator) catch |err| {
       print("Failed to init Game: {}\n", .{err});
        return; // exit main gracefully
    };
    defer game.deinit();
    // const miner = Entity{ .id = 1, .type = EntityType.Constructor, .uiData = .{
    //     .rectangle = .{ .x = 20, .y = 20, .width = 100, .height = 100 },
    // } };
    //

    try game.addItemPrototype("iron-ore");
    const proto = game.getItemPrototypeByName("iron-ore");
    if (proto) |p| {
        print("{f}\n", .{p.*});
    } else {
        print("ItemPrototype = null\n", .{});
    }
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("Hello from Zig on Windows!", 190, 200, 20, rl.LIGHTGRAY);
        // miner.draw();
        rl.EndDrawing();
    }
    rl.CloseWindow();
}
