const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const DrawBox = @import("draw.zig").DrawBox;
const DrawProgressBar = @import("draw.zig").DrawProgressBar;
const Item = @import("recipe.zig").Item;
const Recipe = @import("recipe.zig").Recipe;
const rl = @import("raylib");

pub const EntityKind = union(enum) { Constructor: ConstructorData };

const ConstructorData = struct {
    allocator: std.mem.Allocator,
    recipe: ?*Recipe,
    progress: f32,
    output: ArrayList(Item),
};
pub const UiData = struct { rectangle: rl.Rectangle };
pub const Entity = struct {
    id: usize,
    kind: EntityKind,
    uiData: ?UiData,
    allocator: std.mem.Allocator,
    pub fn draw(self: Entity) !void {
        switch (self.kind) {
            EntityKind.Constructor => {
                try DrawConstructor(self);
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

    pub fn init(allocator: std.mem.Allocator, id: usize, kind: EntityKind, uiData: ?UiData) !Entity {
        return Entity{ .allocator = allocator, .id = id, .kind = kind, .uiData = uiData orelse null };
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

fn DrawConstructor(e: Entity) !void {
    if (e.uiData) |data| {
        var buffer: [100]u8 = undefined;
        const xStartPos: c_int = @intFromFloat(data.rectangle.x);
        const yStartPos: c_int = @intFromFloat(data.rectangle.y);
        DrawBox(data.rectangle, "Constructor");
        const entityData = &e.kind.Constructor;
        if (entityData.recipe) |recipe| {
            const result = try std.fmt.bufPrintZ(&buffer, "Recipe: {s}", .{recipe.name});
            rl.drawText(@ptrCast(result), xStartPos + 20, yStartPos + 20, 10, rl.Color.black);
        }
        rl.drawText("Progress: ", xStartPos + 20, yStartPos + 40, 10, rl.Color.black);
        DrawProgressBar(xStartPos + 20, yStartPos + 50, data.rectangle.width - 60, entityData.progress);
        if (entityData.output.items.len > 0) {
            const result = try std.fmt.bufPrintZ(&buffer, "Output: {} {s}", .{ entityData.output.items.len, entityData.output.getLast().name });
            rl.drawText(@ptrCast(result), xStartPos + 20, yStartPos + 60, 10, rl.Color.black);
        }
        rl.drawCircle(@intFromFloat(data.rectangle.x + data.rectangle.width), @intFromFloat(data.rectangle.y + data.rectangle.height / 2), 5, rl.Color.white);
    }
}

fn UpdateConstructor(dt: f32, entity: *Entity) !void {
    if (entity.uiData) |*data| {
        const pos = rl.getMousePosition();
        if (rl.checkCollisionPointRec(pos, data.rectangle) and rl.isMouseButtonDown(rl.MouseButton.left)) {
            const delta = rl.getMouseDelta();
            data.rectangle.x += delta.x;
            data.rectangle.y += delta.y;
        }
    }

    var entityData = &entity.kind.Constructor;
    if (entityData.output.items.len < 5) {
        if (entityData.recipe) |recipe| {
            entityData.progress += dt;
            if (entityData.progress >= recipe.cost) {
                entityData.progress = 0.0;
                const item = recipe.output.createItem();
                try entityData.output.append(entityData.allocator, item);
            }
        }
    } else {
        // print("Output full\n", .{});
    }
}
