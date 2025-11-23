const rl = @import("raylib");
const std = @import("std");
const ArrayList = std.ArrayList;
const Recipe = @import("recipe.zig").Recipe;
const ItemPrototype = @import("recipe.zig").ItemPrototype;
const Entity = @import("entities/entity.zig").Entity;
const EntityKind = @import("entities/entity.zig").EntityKind;
const UiData = @import("entities/entity.zig").UiData;

pub var world: ?World = null;

pub fn initWorld(allocator: std.mem.Allocator) !*World {
    if (world == null) {
        world = try World.init(allocator);
    }
    return &world.?;
}

pub fn getWorld() *World {
    return &world.?;
}

pub const World = struct {
    allocator: std.mem.Allocator,
    recipes: std.StringHashMap(Recipe),
    itemPrototypes: std.StringHashMap(ItemPrototype),
    entities: std.AutoHashMap(usize, Entity),
    nextEntityId: usize,
    pub fn init(allocator: std.mem.Allocator) !World {
        return World{
            .allocator = allocator,
            .recipes = std.StringHashMap(Recipe).init(allocator),
            .itemPrototypes = std.StringHashMap(ItemPrototype).init(allocator),
            .entities = std.AutoHashMap(usize, Entity).init(allocator),
            .nextEntityId = 0,
        };
    }
    pub fn deinit(self: *World) void {
        self.itemPrototypes.deinit();
        self.recipes.deinit();
        self.entities.deinit();
    }

    pub fn update(self: *World) !void {
        const dt = rl.getFrameTime();
        var it = self.entities.iterator();
        while (it.next()) |*entry| {
            try entry.value_ptr.*.update(dt);
        }
    }

    pub fn draw(self: World) !void {
        var it = self.entities.iterator();
        while (it.next()) |entry| {
            try entry.value_ptr.*.draw();
        }
    }
    pub fn addEntity(self: *World, kind: EntityKind, uiData: ?UiData) !void {
        const nextId = self.nextEntityId;
        self.nextEntityId += 1;
        const entity = try Entity.init(self.allocator, nextId, kind, uiData);
        try self.entities.put(nextId, entity);
    }

    pub fn getEntity(self: *World, id: usize) ?*Entity {
        if (self.entities.contains(id)) {
            return self.entities.getPtr(id);
        } else {
            return null;
        }
    }

    pub fn addRecipe(self: *World, name: []const u8, cost: f32, outputName: []const u8) !void {
        const item = self.getItemPrototypeByName(outputName);
        if (item) |i| {
            const recipe = try Recipe.init(self.allocator, name, cost, i);
            try self.recipes.put(name, recipe);
        } else {
            return error.ItemNotFound;
        }
    }
    pub fn getRecipeByName(self: *World, name: []const u8) ?*Recipe {
        if (self.recipes.contains(name)) {
            return self.recipes.getPtr(name);
        }
        return null;
    }
    pub fn addItemPrototype(self: *World, input: []const u8) !void {
        const proto = try ItemPrototype.init(self.allocator, input);
        try self.itemPrototypes.put(input, proto);
    }
    pub fn getItemPrototypeByName(self: *World, name: []const u8) ?*ItemPrototype {
        if (self.itemPrototypes.contains(name)) {
            return self.itemPrototypes.getPtr(name);
        }
        return null;
    }
};
