const std = @import("std");
const lexer = @import("lexer.zig");

pub const AstReference = struct {
    path: []const u8,

    pub fn init(path: []const u8) AstReference {
        return .{ .path = path };
    }
};

pub const AstEntity = struct {
    main_type: []const u8,
    sub_type: ?[]const u8,
    name: ?[]const u8,
    ref: ?AstReference,
    body_tokens: []const lexer.Token,

    pub fn init(main_type: []const u8, sub_type: ?[]const u8, name: ?[]const u8, ref: ?AstReference, body_tokens: []const lexer.Token) AstEntity {
        return .{ .main_type = main_type, .sub_type = sub_type, .name = name, .ref = ref, .body_tokens = body_tokens };
    }
};

pub const AstScript = struct {
    tokens: []const lexer.Token,
    entities: []const AstEntity,

    pub fn init(tokens: []const lexer.Token, entities: []const AstEntity) AstScript {
        return .{ .tokens = tokens, .entities = entities };
    }
};
