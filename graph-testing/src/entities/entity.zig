const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const drawBox = @import("../draw.zig").drawBox;
const drawProgressBar = @import("../draw.zig").drawProgressBar;
const Item = @import("../recipe.zig").Item;
const Recipe = @import("../recipe.zig").Recipe;
const rl = @import("raylib");
const w = @import("../world.zig");
// const getWorld = @import("../world.zig").getWorld;
// const World = @import("../world.zig").World;
const constructor = @import("constructor.zig");

pub const EntityKind = union(enum) { Constructor: constructor.ConstructorData, Link: LinkData };

const LinkData = struct {
    allocator: std.mem.Allocator,
    buffer: std.ArrayList(Item),
    inputId: usize,
    outputId: usize,
    pub fn init(allocator: std.mem.Allocator, input: usize, output: usize) !LinkData {
        return LinkData{ .allocator = allocator, .buffer = std.ArrayList(Item).initCapacity(allocator, 5), .inputId = input, .outputId = output };
    }
    pub fn hasRoom(self: *LinkData) bool {
        if (self.buffer.items.len < 5) return true;
        return false;
    }

    pub fn addItem(self: *LinkData, item: Item) void {
        self.buffer.append(self.allocator, item);
    }
};

pub const UiData = struct {
    rectangle: rl.Rectangle,
    pub fn getInputLocation(self: *const UiData) rl.Vector2 {
        const x = self.rectangle.x;
        const y = self.rectangle.y + self.rectangle.height / 2;
        return rl.Vector2.init(x, y);
    }
    pub fn getOutputLocation(self: *const UiData) rl.Vector2 {
        const x = self.rectangle.x + self.rectangle.width;
        const y = self.rectangle.y + self.rectangle.height / 2;
        return rl.Vector2.init(x, y);
    }
};

pub const Entity = struct {
    id: usize,
    kind: EntityKind,
    uiData: ?UiData,
    allocator: std.mem.Allocator,
    pub fn draw(self: Entity) !void {
        switch (self.kind) {
            EntityKind.Constructor => {
                try constructor.drawConstructor(self);
            },
            EntityKind.Link => {
                try drawLink(self);
            },
            // EntityKind.Output => {
            //     try drawOutput(self);
            // },
        }
    }

    pub fn update(self: *Entity, dt: f32) !void {
        switch (self.kind) {
            EntityKind.Constructor => {
                try constructor.updateConstructor(dt, self);
            },
            EntityKind.Link => {
                return;
            },
            // EntityKind.Output => {
            //     try updateOutput(dt, self);
            // },
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

pub fn createLink(allocator: std.mem.Allocator) !EntityKind {
    const linkData = EntityKind{ .Link = LinkData{ .allocator = allocator, .buffer = try ArrayList(Item).initCapacity(allocator, 5) } };
    return linkData;
}

fn drawLink(e: Entity) !void {
    const entityData = &e.kind.Link;
    const world = w.getWorld();
    const inputEntity = world.getEntity(entityData.inputId) orelse return;
    const outputEntity = world.getEntity(entityData.outputId) orelse return;
    const inputUiData = inputEntity.uiData orelse return;
    const outputUiData = outputEntity.uiData orelse return;
    rl.drawLineEx(inputUiData.getOutputLocation(), outputUiData.getInputLocation(), 1, rl.Color.white);
}

fn updateOutput(dt: f32, entity: *Entity) !void {
    _ = dt;
    _ = entity;
}
