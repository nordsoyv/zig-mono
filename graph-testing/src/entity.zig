const rl = @cImport({
    @cInclude("raylib.h");
});
const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Recipe = @import("recipe.zig").Recipe;
const Item = @import("recipe.zig").Item;

pub const EntityKind = union(enum) { Constructor: ConstructorData };

const ConstructorData = struct {
    allocator: std.mem.Allocator,
    recipe: ?*Recipe,
    progress: f32,
    output: ArrayList(Item),
};
const UiData = struct { rectangle: rl.Rectangle };
pub const Entity = struct {
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

    pub fn update(self: *Entity, dt: f32) !void {
        switch (self.kind) {
            EntityKind.Constructor => {
                try UpdateConstructor(dt, self);
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

pub fn CreateConstructor(allocator: std.mem.Allocator, res: *Recipe) !EntityKind {
    const constData = EntityKind{ .Constructor = ConstructorData{ .recipe = res, .progress = 0.0, .allocator = allocator, .output = try ArrayList(Item).initCapacity(allocator, 5) } };
    return constData;
}

fn DrawConstructor(e: Entity) void {
    if (e.uiData) |data| {
        rl.DrawRectangleRounded(data.rectangle, 0.2, 10, rl.BLUE);
    }
}

fn UpdateConstructor(dt: f32, entity: *Entity) !void {
    var entityData = &entity.kind.Constructor;
    if (entityData.output.items.len < 5) {
        if (entityData.recipe) |recipe| {
            entityData.progress += dt;
            if (entityData.progress >= recipe.cost) {
                entityData.progress = 0.0;
                const item = recipe.output.createItem();
                try entityData.output.append(entityData.allocator, item);
                print("Created {s}\n", .{item.name});
            }
        }
    } else {
        print("Output full\n", .{});
    }
}
