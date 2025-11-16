const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn main() void {
    rl.InitWindow(800, 600, "Hello Zig + Raylib");
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("Hello from Zig on Windows!", 190, 200, 20, rl.LIGHTGRAY);
        rl.EndDrawing();
    }
    rl.CloseWindow();
}
