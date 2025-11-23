const std = @import("std");
const rl = @import("raylib");
const r = @import("../recipe.zig");
const e = @import("entity.zig");
const draw = @import("../draw.zig");

pub const ConstructorData = struct {
    allocator: std.mem.Allocator,
    recipe: ?*r.Recipe,
    progress: f32,
    output: std.ArrayList(r.Item),
};

pub fn createConstructor(allocator: std.mem.Allocator, res: *r.Recipe) !e.EntityKind {
    const constData = e.EntityKind{ .Constructor = ConstructorData{ .recipe = res, .progress = 0.0, .allocator = allocator, .output = try std.ArrayList(r.Item).initCapacity(allocator, 5) } };
    return constData;
}

pub fn drawConstructor(entity: e.Entity) !void {
    if (entity.uiData) |data| {
        var buffer: [100]u8 = undefined;
        const xStartPos: c_int = @intFromFloat(data.rectangle.x);
        const yStartPos: c_int = @intFromFloat(data.rectangle.y);
        draw.drawBox(data.rectangle, "Constructor");
        const entityData = &entity.kind.Constructor;
        if (entityData.recipe) |recipe| {
            const result = try std.fmt.bufPrintZ(&buffer, "Recipe: {s}", .{recipe.name});
            rl.drawText(@ptrCast(result), xStartPos + 20, yStartPos + 20, 10, rl.Color.black);
        }
        rl.drawText("Progress: ", xStartPos + 20, yStartPos + 40, 10, rl.Color.black);
        draw.drawProgressBar(xStartPos + 20, yStartPos + 50, data.rectangle.width - 60, entityData.progress);
        if (entityData.output.items.len > 0) {
            const result = try std.fmt.bufPrintZ(&buffer, "Output: {} {s}", .{ entityData.output.items.len, entityData.output.getLast().name });
            rl.drawText(@ptrCast(result), xStartPos + 20, yStartPos + 60, 10, rl.Color.black);
        }
        // rl.drawCircle(@intFromFloat(data.rectangle.x + data.rectangle.width), @intFromFloat(data.rectangle.y + data.rectangle.height / 2), 5, rl.Color.white);
    }
}

pub fn updateConstructor(dt: f32, entity: *e.Entity) !void {
    if (entity.uiData) |*data| {
        const pos = rl.getMousePosition();
        if (rl.checkCollisionPointRec(pos, data.rectangle) and rl.isMouseButtonDown(rl.MouseButton.left)) {
            const delta = rl.getMouseDelta();
            data.rectangle.x += delta.x;
            data.rectangle.y += delta.y;
        }
    }

    var entityData = &entity.kind.Constructor;
    // var world = getWorld();
    // var outputEntity = world.getEntity(entityData.outputId);
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
