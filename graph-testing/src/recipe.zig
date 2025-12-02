const std = @import("std");

pub const RecipeIngredient = struct{
    amount: u32,
    item:  []u8,
};

pub const Recipe = struct {
    name: []u8,
    cost: f32,
    output: *ItemPrototype,
    outputAmount: u32,
    ingredients: std.ArrayList(RecipeIngredient),
    pub fn init(allocator: std.mem.Allocator, input: []const u8, cost: f32, output: *ItemPrototype, ingredients: std.ArrayList(RecipeIngredient)) !Recipe {
        const buf = try allocator.dupe(u8, input);
        return Recipe{ .name = buf, .cost = cost, .output = output , .ingredients = ingredients, .outputAmount = 1};
    }
    pub fn create(self: *Recipe) []Item {
        const items = try std.ArrayList(Item).initCapacity(self.allocator, self.outputAmount);
        for (0..self.outputAmount) |i| {
            items.append(self.output.createItem());
        }
        return items.toOwnedSlice();
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
