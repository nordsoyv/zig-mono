const rl = @cImport({
    @cInclude("raylib.h");
});
const std = @import("std");
const Recipe = @import("recipe.zig").Recipe;
const ItemPrototype = @import("recipe.zig").ItemPrototype;
const Entity = @import("entity.zig").Entity;
const EntityKind = @import("entity.zig").EntityKind;
const CreateConstructor = @import("entity.zig").CreateConstructor;

const print = std.debug.print;

const ArrayList = std.ArrayList;

const Game = struct {
    allocator: std.mem.Allocator,
    recipes: ArrayList(Recipe),
    itemPrototypes: ArrayList(ItemPrototype),
    entities: ArrayList(Entity),
    pub fn init(allocator: std.mem.Allocator) !Game {
        return Game{ .allocator = allocator, .itemPrototypes = try ArrayList(ItemPrototype).initCapacity(allocator, 0), .recipes = try ArrayList(Recipe).initCapacity(allocator, 0), .entities = try ArrayList(Entity).initCapacity(allocator, 0) };
    }
    pub fn deinit(self: *Game) void {
        self.itemPrototypes.deinit(self.allocator);
        self.recipes.deinit(self.allocator);
        self.entities.deinit(self.allocator);
    }

    pub fn update(self: *Game) !void {
        const dt = rl.GetFrameTime();
        for (self.entities.items) |*entity| {
            try entity.update(dt);
        }
    }

    pub fn addEntity(self: *Game, kind: EntityKind) !void {
        const nextId = self.entities.items.len;
        const entity = try Entity.init(nextId, kind);
        try self.entities.append(self.allocator, entity);
    }

    pub fn addRecipe(self: *Game, name: []const u8, cost: f32, outputName: []const u8) !void {
        const item = self.getItemPrototypeByName(outputName);
        if (item) |i| {
            const recipe = try Recipe.init(self.allocator, name, cost, i);
            try self.recipes.append(self.allocator, recipe);
        } else {
            return error.ItemNotFound;
        }
    }
    pub fn getRecipeByName(self: *Game, name: []const u8) ?*Recipe {
        for (self.recipes.items) |*recipe| {
            if (std.mem.eql(u8, recipe.name, name)) {
                return recipe; // return pointer to the matching prototype
            }
        }
        return null; // not found
    }
    pub fn addItemPrototype(self: *Game, input: []const u8) !void {
        const proto = try ItemPrototype.init(self.allocator, input);
        try self.itemPrototypes.append(self.allocator, proto);
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
    var game = Game.init(allocator) catch |err| {
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

    try game.addRecipe("mine-iron-ore", 1, "iron-ore");
    const r = game.getRecipeByName("mine-iron-ore");
    if (r) |res| {
        print("{f}\n", .{res.*});
        try game.addEntity(try CreateConstructor(allocator, res));
    } else {
        print("Recipe = null\n", .{});
    }

    while (!rl.WindowShouldClose()) {
        try game.update();
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("Hello from Zig on Windows!", 190, 200, 20, rl.LIGHTGRAY);

        // miner.draw();
        rl.EndDrawing();
    }
    rl.CloseWindow();
}
