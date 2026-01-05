const std = @import("std");
const lexer = @import("lexer.zig");

pub const AstReference = struct {
    path: []const u8,

    pub fn init(path: []const u8) AstReference {
        return .{ .path = path };
    }
};

pub const AstProperty = struct {
    parent: *AstEntity,
    name: []const u8,
    value_tokens: []const lexer.Token,

    pub fn init(parent: *AstEntity, name: []const u8, value_tokens: []const lexer.Token) AstProperty {
        return .{ .parent = parent, .name = name, .value_tokens = value_tokens };
    }
};

pub const AstScript = struct {
    parent: ?*AstEntity,
    tokens: []const lexer.Token,
    entities: []const *AstEntity,

    pub fn init(tokens: []const lexer.Token, entities: []const *AstEntity) AstScript {
        return .{ .parent = null, .tokens = tokens, .entities = entities };
    }
};

pub const AstEntity = struct {
    pub const Parent = union(enum) {
        script: *AstScript,
        entity: *AstEntity,
    };

    parent: Parent,
    main_type: []const u8,
    sub_type: ?[]const u8,
    name: ?[]const u8,
    ref: ?AstReference,
    properties: []const *AstProperty,
    children: []const *AstEntity,

    pub fn init(
        parent: Parent,
        main_type: []const u8,
        sub_type: ?[]const u8,
        name: ?[]const u8,
        ref: ?AstReference,
        properties: []const *AstProperty,
        children: []const *AstEntity,
    ) AstEntity {
        return .{ .parent = parent, .main_type = main_type, .sub_type = sub_type, .name = name, .ref = ref, .properties = properties, .children = children };
    }
};
