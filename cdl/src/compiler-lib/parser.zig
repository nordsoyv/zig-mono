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

    pub fn parseScript(self: *Parser) anyerror!*ast.AstScript {
        if (self.tokens.len == 0) return error.UnexpectedEof;
        if (self.tokens[self.tokens.len - 1].kind != .eof) return error.ExpectedEof;

        const script = try self.allocator.create(ast.AstScript);
        script.* = ast.AstScript.init(self.tokens, &[_]*ast.AstEntity{});

        var entities: std.ArrayList(*ast.AstEntity) = .empty;
        errdefer entities.deinit(self.allocator);

        while (true) {
            self.skipSeparators();
            if (self.peek().kind == .eof) break;
            const ent = try self.parseEntity(.{ .script = script });
            try entities.append(self.allocator, ent);
        }

        script.* = ast.AstScript.init(self.tokens, try entities.toOwnedSlice(self.allocator));
        return script;
    }

    fn parseEntity(self: *Parser, parent: ast.AstEntity.Parent) anyerror!*ast.AstEntity {
        const header = try self.parseEntityHeader();
        const node = try self.allocator.create(ast.AstEntity);
        node.* = ast.AstEntity.init(parent, header.main_type, header.sub_type, header.name, header.ref, &[_]*ast.AstProperty{}, &[_]*ast.AstEntity{});

        const body = try self.parseBracedBodyItems(node);
        node.properties = body.properties;
        node.children = body.children;
        return node;
    }

    const EntityHeader = struct {
        main_type: []const u8,
        sub_type: ?[]const u8,
        name: ?[]const u8,
        ref: ?ast.AstReference,
    };

    fn parseEntityHeader(self: *Parser) !EntityHeader {
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
                name = try self.parseName();
                continue;
            }

            if (t.kind == .at and ref == null) {
                ref = try self.parseReference();
                continue;
            }

            _ = self.advance();
        }

        return .{ .main_type = main_type, .sub_type = sub_type, .name = name, .ref = ref };
    }

    fn parseName(self: *Parser) ![]const u8 {
        _ = try self.expect(.hash);
        const id = try self.expect(.identifier);
        return self.allocator.dupe(u8, id.lexeme);
    }

    const ParsedBody = struct {
        properties: []const *ast.AstProperty,
        children: []const *ast.AstEntity,
    };

    fn parseBracedBodyItems(self: *Parser, parent: *ast.AstEntity) anyerror!ParsedBody {
        _ = try self.expect(.l_brace);
        var depth: usize = 1;

        var properties: std.ArrayList(*ast.AstProperty) = .empty;
        errdefer properties.deinit(self.allocator);

        var children: std.ArrayList(*ast.AstEntity) = .empty;
        errdefer children.deinit(self.allocator);

        while (depth > 0) {
            const t = self.peek();
            if (t.kind == .eof) return error.UnexpectedEof;

            if (depth == 1) {
                if (self.isEntityStartInBody()) {
                    const child = try self.parseEntity(.{ .entity = parent });
                    try children.append(self.allocator, child);
                    continue;
                }

                if (self.isPropertyStartInBody()) {
                    const prop = try self.parsePropertyLine(parent);
                    try properties.append(self.allocator, prop);
                    continue;
                }
            }

            _ = self.advance();
            switch (t.kind) {
                .l_brace => depth += 1,
                .r_brace => depth -= 1,
                else => {},
            }
        }

        return .{
            .properties = try properties.toOwnedSlice(self.allocator),
            .children = try children.toOwnedSlice(self.allocator),
        };
    }

    fn isEntityStartInBody(self: *Parser) bool {
        // Heuristic: an entity header starts with an identifier and reaches '{' before ':'
        if (self.peek().kind != .identifier) return false;

        var j: usize = self.i;
        while (j < self.tokens.len) : (j += 1) {
            const k = self.tokens[j].kind;
            switch (k) {
                .l_brace => return true,
                .colon, .r_brace, .semicolon, .backslash, .eof => return false,
                else => {},
            }
        }
        return false;
    }

    fn isPropertyStartInBody(self: *Parser) bool {
        if (self.peek().kind != .identifier) return false;
        if (self.i + 1 >= self.tokens.len) return false;
        return self.tokens[self.i + 1].kind == .colon;
    }

    fn parsePropertyLine(self: *Parser, parent: *ast.AstEntity) anyerror!*ast.AstProperty {
        const name_tok = try self.expect(.identifier);
        const name = try self.allocator.dupe(u8, name_tok.lexeme);
        const colon_tok = try self.expect(.colon);

        const value_start = self.i;
        const line = colon_tok.line;
        var local_depth: usize = 0;
        while (true) {
            const t = self.peek();
            if (t.kind == .eof) break;

            // Stop at end-of-line, unless the property value contains its own braced block
            // that spans further tokens.
            if (local_depth == 0 and t.line != line) break;

            switch (t.kind) {
                .l_brace => {
                    local_depth += 1;
                    _ = self.advance();
                },
                .r_brace => {
                    // Don't consume the brace that closes the surrounding entity body.
                    if (local_depth == 0) break;
                    local_depth -= 1;
                    _ = self.advance();
                },
                else => _ = self.advance(),
            }
        }
        const value_end = self.i;
        const prop = try self.allocator.create(ast.AstProperty);
        prop.* = ast.AstProperty.init(parent, name, self.tokens[value_start..value_end]);
        return prop;
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
