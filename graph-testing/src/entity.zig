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
        const xStartPos: c_int = @intFromFloat(data.rectangle.x);
        const yStartPos: c_int = @intFromFloat(data.rectangle.y);
        rl.DrawRectangleRounded(data.rectangle, 0.2, 10, rl.WHITE);
        rl.DrawRectangleRoundedLines(data.rectangle, 0.2, 10, rl.PURPLE);
        rl.DrawRectangleRounded(.{ .width = data.rectangle.width, .x = data.rectangle.x, .y = data.rectangle.y, .height = 20 }, 1, 10, rl.SKYBLUE);
        rl.DrawText("Constructor", xStartPos + 20, yStartPos + 5, 10, rl.WHITE);

        const entityData = &e.kind.Constructor;
        rl.DrawText("Recipe: ", xStartPos + 20, yStartPos + 20, 10, rl.BLACK);
        if (entityData.recipe) |recipe| {
            rl.DrawText(@ptrCast(recipe.name.ptr), xStartPos + 60, yStartPos + 20, 10, rl.BLACK);
        }
        rl.DrawText("Progress: ", xStartPos + 20, yStartPos + 40, 10, rl.BLACK);
        // rl.DrawText(@intFromFloat(entityData.progress),  @intFromFloat(data.rectangle.x + 20), @intFromFloat(data.rectangle.y+85), 10, rl.WHITE);
        DrawProgressBar(xStartPos + 20, yStartPos + 50, data.rectangle.width - 60, entityData.progress);
        rl.DrawText("Output: ", xStartPos + 20, yStartPos + 60, 10, rl.BLACK);
        if (entityData.output.items.len > 0) {
            var buffer: [20]u8 = undefined;
            const result = try std.fmt.bufPrintZ(&buffer, "{}", .{entityData.output.items.len});
            // result[result.len] = 0;
            rl.DrawText(@ptrCast(result), @intFromFloat(data.rectangle.x + 60), @intFromFloat(data.rectangle.y + 60), 10, rl.BLACK);
            const item = &entityData.output.getLast();
            rl.DrawText(@ptrCast(item.name), @intFromFloat(data.rectangle.x + 70), @intFromFloat(data.rectangle.y + 60), 10, rl.BLACK);
        }
    }
}

fn DrawProgressBar(xPos: c_int, yPos: c_int, width: f32, progress: f32) void {
    rl.DrawRectangleLines(xPos, yPos, @intFromFloat(width), 5, rl.PURPLE);
    rl.DrawRectangle(xPos + 1, yPos, @intFromFloat((width * progress) - 1), 5, rl.BLACK);
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
        // print("Output full\n", .{});
    }
}
