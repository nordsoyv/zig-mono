const std = @import("std");

pub const Recipe = struct {
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

pub const ItemPrototype = struct {
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
pub const Item = struct { name: []u8 };
