const std = @import("std");

const rl = @import("raylib");

pub fn drawBox(rect: rl.Rectangle, heading: [:0]const u8) void {
    const xStartPos: c_int = @intFromFloat(rect.x);
    const yStartPos: c_int = @intFromFloat(rect.y);
    rl.drawRectangleRounded(rect, 0.2, 10, rl.Color.white);
    const pos = rl.getMousePosition();
    if (rl.checkCollisionPointRec(pos, rect)) {
        rl.drawRectangleRoundedLines(rect, 0.2, 10, rl.Color.black);
    } else {
        rl.drawRectangleRoundedLines(rect, 0.2, 10, rl.Color.purple);
    }
    // std.log.debug("{} {}", .{ pos.x, pos.y });
    // rl.DrawRectangleRounded(rect, 0.2, 10, rl.WHITE);
    rl.drawRectangleRounded(.{ .width = rect.width, .x = rect.x, .y = rect.y, .height = 20 }, 1, 10, rl.Color.sky_blue);
    rl.drawText(heading, xStartPos + 20, yStartPos + 5, 10, rl.Color.white);
}

pub fn drawProgressBar(xPos: c_int, yPos: c_int, width: f32, progress: f32) void {
    rl.drawRectangle(xPos, yPos, @intFromFloat(width), 5, rl.Color.purple);
    rl.drawRectangle(xPos + 1, yPos + 1, @intFromFloat((width * progress) - 1), 5 - 2, rl.Color.black);
}
