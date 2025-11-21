const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const CreateConstructor = @import("entity.zig").CreateConstructor;
const Entity = @import("entity.zig").Entity;
const EntityKind = @import("entity.zig").EntityKind;
const ItemPrototype = @import("recipe.zig").ItemPrototype;
const Recipe = @import("recipe.zig").Recipe;
const rl = @import("raylib.zig").rl;
const UiData = @import("entity.zig").UiData;

const World = struct {
    allocator: std.mem.Allocator,
    recipes: ArrayList(Recipe),
    itemPrototypes: ArrayList(ItemPrototype),
    entities: ArrayList(Entity),
    pub fn init(allocator: std.mem.Allocator) !World {
        return World{ .allocator = allocator, .itemPrototypes = try ArrayList(ItemPrototype).initCapacity(allocator, 0), .recipes = try ArrayList(Recipe).initCapacity(allocator, 0), .entities = try ArrayList(Entity).initCapacity(allocator, 0) };
    }
    pub fn deinit(self: *World) void {
        self.itemPrototypes.deinit(self.allocator);
        self.recipes.deinit(self.allocator);
        self.entities.deinit(self.allocator);
    }

    pub fn update(self: *World) !void {
        const dt = rl.GetFrameTime();
        for (self.entities.items) |*entity| {
            try entity.update(dt);
        }
    }

    pub fn draw(self: World) !void {
        for (self.entities.items) |*entity| {
            try entity.draw();
        }
    }
    pub fn addEntity(self: *World, kind: EntityKind, uiData: ?UiData) !void {
        const nextId = self.entities.items.len;
        const entity = try Entity.init(self.allocator, nextId, kind, uiData);
        try self.entities.append(self.allocator, entity);
    }

    pub fn addRecipe(self: *World, name: []const u8, cost: f32, outputName: []const u8) !void {
        const item = self.getItemPrototypeByName(outputName);
        if (item) |i| {
            const recipe = try Recipe.init(self.allocator, name, cost, i);
            try self.recipes.append(self.allocator, recipe);
        } else {
            return error.ItemNotFound;
        }
    }
    pub fn getRecipeByName(self: *World, name: []const u8) ?*Recipe {
        for (self.recipes.items) |*recipe| {
            if (std.mem.eql(u8, recipe.name, name)) {
                return recipe; // return pointer to the matching prototype
            }
        }
        return null; // not found
    }
    pub fn addItemPrototype(self: *World, input: []const u8) !void {
        const proto = try ItemPrototype.init(self.allocator, input);
        try self.itemPrototypes.append(self.allocator, proto);
    }
    pub fn getItemPrototypeByName(self: *World, name: []const u8) ?*ItemPrototype {
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
    var world = World.init(allocator) catch |err| {
        print("Failed to init World: {}\n", .{err});
        return; // exit main gracefully
    };
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
        try world.addEntity(try CreateConstructor(allocator, res), .{ .rectangle = .{ .x = 100, .y = 100, .width = 200, .height = 100 } });
    } else {
        print("Recipe = null\n", .{});
    }

    while (!rl.WindowShouldClose()) {
        try world.update();
        rl.BeginDrawing();
        rl.ClearBackground(rl.DARKGRAY);
        try world.draw();
        //rl.DrawText("Hello from Zig on Windows!", 190, 200, 20, rl.LIGHTGRAY);

        // miner.draw();
        rl.EndDrawing();
    }
    rl.CloseWindow();
}
