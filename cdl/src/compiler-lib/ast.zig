const std = @import("std");
const lexer = @import("lexer.zig");

pub const NodeId = u32;

pub const AstReference = struct {
    path: []const u8,

    pub fn init(path: []const u8) AstReference {
        return .{ .path = path };
    }
};

pub const AstProperty = struct {
    parent: NodeId,
    name: []const u8,
    value_tokens: []const lexer.Token,

    pub fn init(parent: NodeId, name: []const u8, value_tokens: []const lexer.Token) AstProperty {
        return .{ .parent = parent, .name = name, .value_tokens = value_tokens };
    }
};

pub const AstScript = struct {
    parent: ?NodeId,
    tokens: []const lexer.Token,
    entities: []const NodeId,

    pub fn init(tokens: []const lexer.Token, entities: []const NodeId) AstScript {
        return .{ .parent = null, .tokens = tokens, .entities = entities };
    }
};

pub const AstEntity = struct {
    parent: NodeId,
    main_type: []const u8,
    sub_type: ?[]const u8,
    name: ?[]const u8,
    ref: ?AstReference,
    properties: []const NodeId,
    children: []const NodeId,

    pub fn init(
        parent: NodeId,
        main_type: []const u8,
        sub_type: ?[]const u8,
        name: ?[]const u8,
        ref: ?AstReference,
        properties: []const NodeId,
        children: []const NodeId,
    ) AstEntity {
        return .{ .parent = parent, .main_type = main_type, .sub_type = sub_type, .name = name, .ref = ref, .properties = properties, .children = children };
    }
};

pub const NodeTag = enum {
    script,
    entity,
    property,
};

pub const Node = union(NodeTag) {
    script: AstScript,
    entity: AstEntity,
    property: AstProperty,
};

pub const NodeStore = struct {
    allocator: std.mem.Allocator,
    nodes: std.ArrayList(Node) = .empty,

    pub fn init(allocator: std.mem.Allocator) NodeStore {
        return .{ .allocator = allocator };
    }

    pub fn add(self: *NodeStore, n: Node) !NodeId {
        try self.nodes.append(self.allocator, n);
        return @intCast(self.nodes.items.len - 1);
    }

    pub fn node(self: *NodeStore, id: NodeId) *Node {
        return &self.nodes.items[@intCast(id)];
    }

    pub fn script(self: *NodeStore, id: NodeId) *AstScript {
        const n = self.node(id);
        return switch (n.*) {
            .script => |*s| s,
            else => unreachable,
        };
    }

    pub fn entity(self: *NodeStore, id: NodeId) *AstEntity {
        const n = self.node(id);
        return switch (n.*) {
            .entity => |*e| e,
            else => unreachable,
        };
    }

    pub fn property(self: *NodeStore, id: NodeId) *AstProperty {
        const n = self.node(id);
        return switch (n.*) {
            .property => |*p| p,
            else => unreachable,
        };
    }
};

pub const Ast = struct {
    store: NodeStore,
    root: NodeId,
};
