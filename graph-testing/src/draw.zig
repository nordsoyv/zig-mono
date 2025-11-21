const std = @import("std");

const rl = @import("raylib.zig").rl;

pub fn DrawBox(rect: rl.Rectangle, heading: [*:0]const u8) void {
    const xStartPos: c_int = @intFromFloat(rect.x);
    const yStartPos: c_int = @intFromFloat(rect.y);
    rl.DrawRectangleRounded(rect, 0.2, 10, rl.WHITE);
    const pos = rl.GetMousePosition();
    if (rl.CheckCollisionPointRec(pos, rect)) {
        rl.DrawRectangleRoundedLines(rect, 0.2, 10, rl.BLACK);
    } else {
        rl.DrawRectangleRoundedLines(rect, 0.2, 10, rl.PURPLE);
    }
    // std.log.debug("{} {}", .{ pos.x, pos.y });
    // rl.DrawRectangleRounded(rect, 0.2, 10, rl.WHITE);
    rl.DrawRectangleRounded(.{ .width = rect.width, .x = rect.x, .y = rect.y, .height = 20 }, 1, 10, rl.SKYBLUE);
    rl.DrawText(heading, xStartPos + 20, yStartPos + 5, 10, rl.WHITE);
}

pub fn DrawProgressBar(xPos: c_int, yPos: c_int, width: f32, progress: f32) void {
    rl.DrawRectangle(xPos, yPos, @intFromFloat(width), 5, rl.PURPLE);
    rl.DrawRectangle(xPos + 1, yPos + 1, @intFromFloat((width * progress) - 1), 5 - 2, rl.BLACK);
}
