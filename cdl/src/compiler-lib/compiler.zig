const std = @import("std");
const lexer = @import("lexer.zig");

pub const Compiler = struct {
    arena: std.heap.ArenaAllocator,

    pub fn init(gpa: std.mem.Allocator) Compiler {
        return .{ .arena = std.heap.ArenaAllocator.init(gpa) };
    }

    pub fn deinit(self: *Compiler) void {
        self.arena.deinit();
    }

    pub fn allocator(self: *Compiler) std.mem.Allocator {
        return self.arena.allocator();
    }

    pub fn tokenize(self: *Compiler, input: []const u8) ![]lexer.Token {
        var l = lexer.Lexer.init(input);
        return l.tokenize(self.allocator());
    }

    pub fn dumpTokens(self: *Compiler, writer: anytype, input: []const u8) !void {
        const toks = try self.tokenize(input);
        try lexer.dumpTokens(writer, toks);
    }
};
