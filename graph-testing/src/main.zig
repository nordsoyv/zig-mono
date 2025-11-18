const rl = @cImport({
    @cInclude("raylib.h");
});

const EntityType = enum { Miner };

const UiData = struct { rectangle: rl.Rectangle };

const Entity = struct {
    id: u32,
    type: EntityType,
    uiData: ?UiData,
    pub fn draw(self: Entity) void {
        switch (self.type) {
            EntityType.Miner => {
                DrawMiner(self);
            },
        }
    }
};

pub fn DrawMiner(e: Entity) void {
    if (e.uiData) |data| {
        rl.DrawRectangleRounded(data.rectangle, 0.2, 10, rl.BLUE);
    }
}

pub fn main() void {
    rl.InitWindow(800, 600, "Hello Zig + Raylib");
    const miner = Entity{ .id = 1, .type = EntityType.Miner, .uiData = .{
        .rectangle = .{ .x = 20, .y = 20, .width = 100, .height = 100 },
    } };
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("Hello from Zig on Windows!", 190, 200, 20, rl.LIGHTGRAY);
        miner.draw();
        rl.EndDrawing();
    }
    rl.CloseWindow();
}
