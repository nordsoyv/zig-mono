const rl = @cImport({
    @cInclude("raylib.h");
});
const std = @import("std");
const print = std.debug.print;

const ArrayList = std.ArrayList;
const EntityKind = union(enum) { Constructor: ConstructorData };

const ConstructorData = struct { recipe: ?*Recipe, progress : f32 };

const Recipe = struct {
    name: []u8,
    cost: f32,
    output: *ItemPrototype,
    pub fn init(allocator: std.mem.Allocator, input: []const u8, cost: f32, output: *ItemPrototype) !Recipe {
        const buf = try allocator.dupe(u8, input);
        return Recipe{ .name = buf, .cost = cost, .output = output };
    }
    pub fn format(
        self: Recipe,
        writer: anytype,
    ) !void {
        const outputName = self.output.name;
        try writer.print("Recipe( name = \"{s}\", timeTaken: {}, creates: {s} )", .{ self.name, self.cost, outputName });
    }
};

const ItemPrototype = struct {
    name: []u8,
    pub fn init(allocator: std.mem.Allocator, input: []const u8) !ItemPrototype {
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
    id: usize,
    kind: EntityKind,
    uiData: ?UiData,
    pub fn draw(self: Entity) void {
        switch (self.kind) {
            EntityKind.Constructor => {
                DrawConstructor(self);
            },
        }
    }

    pub fn update(self: *Entity, dt: f32) void {
        switch (self.kind) {
            EntityKind.Constructor => {
                UpdateConstructor(dt,self);
            },
        }
    }

    pub fn init(id: usize, kind: EntityKind) !Entity {
        return Entity{ .id = id, .kind = kind, .uiData = null };
    }
    pub fn format(
        self: Entity,
        writer: anytype,
    ) !void {
        try writer.print("Entity( id = {}, kind = {} )", .{ self.id, self.kind });
    }
};

pub fn DrawConstructor(e: Entity) void {
    if (e.uiData) |data| {
        rl.DrawRectangleRounded(data.rectangle, 0.2, 10, rl.BLUE);
    }
}

pub fn UpdateConstructor(dt: f32,entity: *Entity) void {

    var entityData = &entity.kind.Constructor;
    //print("Update Constructor {} {}", .{entityData.progress, dt});
    entityData.progress += dt;
    //print("Progress {}\n", .{entityData.progress});
    if (entityData.recipe) |recipe| {
        if (entityData.progress >= recipe.cost) {
            entityData.progress = 0.0;
            const item = recipe.output.createItem();
            print("Created {s}\n", .{item.name});
        }
    }

}

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

    pub fn update(self: *Game) void {
        const dt = rl.GetFrameTime();
        for (self.entities.items) |*entity| {
            entity.update(dt);
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
        const constData = EntityKind{ .Constructor = ConstructorData{ .recipe = res, .progress = 0.0 } };
        try game.addEntity(constData);
    } else {
        print("Recipe = null\n", .{});
    }

    while (!rl.WindowShouldClose()) {
        game.update();
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("Hello from Zig on Windows!", 190, 200, 20, rl.LIGHTGRAY);

        // miner.draw();
        rl.EndDrawing();
    }
    rl.CloseWindow();
}
