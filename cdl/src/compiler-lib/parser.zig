const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: []const lexer.Token,
    i: usize = 0,

    pub fn init(allocator: std.mem.Allocator, tokens: []const lexer.Token) Parser {
        return .{ .allocator = allocator, .tokens = tokens };
    }

    pub fn parseScript(self: *Parser) !*ast.AstScript {
        if (self.tokens.len == 0) return error.UnexpectedEof;
        if (self.tokens[self.tokens.len - 1].kind != .eof) return error.ExpectedEof;

        var entities: std.ArrayList(ast.AstEntity) = .empty;
        errdefer entities.deinit(self.allocator);

        while (true) {
            self.skipSeparators();
            if (self.peek().kind == .eof) break;
            const ent = try self.parseEntity();
            try entities.append(self.allocator, ent);
        }

        const node = try self.allocator.create(ast.AstScript);
        node.* = ast.AstScript.init(self.tokens, try entities.toOwnedSlice(self.allocator));
        return node;
    }

    fn parseEntity(self: *Parser) !ast.AstEntity {
        const main_type_tok = self.peek();
        if (main_type_tok.kind != .identifier) return error.ExpectedEntityType;
        _ = self.advance();

        const main_type = try self.allocator.dupe(u8, main_type_tok.lexeme);

        var sub_type: ?[]const u8 = null;
        var name: ?[]const u8 = null;
        var ref: ?ast.AstReference = null;
        while (true) {
            const t = self.peek();
            if (t.kind == .eof) return error.UnexpectedEof;
            if (t.kind == .l_brace) break;

            if (t.kind == .identifier and sub_type == null) {
                sub_type = try self.allocator.dupe(u8, t.lexeme);
                _ = self.advance();
                continue;
            }

            if (t.kind == .hash and name == null) {
                _ = self.advance();
                const id = self.peek();
                if (id.kind != .identifier) return error.UnexpectedToken;
                name = try self.allocator.dupe(u8, id.lexeme);
                _ = self.advance();
                continue;
            }

            if (t.kind == .at and ref == null) {
                ref = try self.parseReference();
                continue;
            }

            _ = self.advance();
        }

        _ = try self.expect(.l_brace);

        const body_start = self.i;
        var depth: usize = 1;
        while (depth > 0) {
            const t = self.peek();
            if (t.kind == .eof) return error.UnexpectedEof;
            _ = self.advance();
            switch (t.kind) {
                .l_brace => depth += 1,
                .r_brace => depth -= 1,
                else => {},
            }
        }

        // body is everything between the outer braces, excluding the closing '}' we just consumed
        const body_end = self.i - 1;
        return ast.AstEntity.init(main_type, sub_type, name, ref, self.tokens[body_start..body_end]);
    }

    fn parseReference(self: *Parser) !ast.AstReference {
        _ = try self.expect(.at);

        const first = self.peek();
        if (first.kind != .identifier) return error.UnexpectedToken;
        _ = self.advance();

        var buf: std.ArrayList(u8) = .empty;
        errdefer buf.deinit(self.allocator);

        try buf.appendSlice(self.allocator, first.lexeme);
        while (self.peek().kind == .dot) {
            _ = self.advance();
            const part = self.peek();
            if (part.kind != .identifier) return error.UnexpectedToken;
            _ = self.advance();

            try buf.append(self.allocator, '.');
            try buf.appendSlice(self.allocator, part.lexeme);
        }

        return ast.AstReference.init(try buf.toOwnedSlice(self.allocator));
    }

    fn skipSeparators(self: *Parser) void {
        while (true) {
            const t = self.peek();
            switch (t.kind) {
                .backslash, .semicolon => _ = self.advance(),
                else => return,
            }
        }
    }

    fn expect(self: *Parser, kind: lexer.Kind) !lexer.Token {
        const t = self.peek();
        if (t.kind != kind) return error.UnexpectedToken;
        _ = self.advance();
        return t;
    }

    fn peek(self: *Parser) lexer.Token {
        if (self.i >= self.tokens.len) return self.tokens[self.tokens.len - 1];
        return self.tokens[self.i];
    }

    fn advance(self: *Parser) lexer.Token {
        const t = self.peek();
        if (self.i < self.tokens.len) self.i += 1;
        return t;
    }
};
