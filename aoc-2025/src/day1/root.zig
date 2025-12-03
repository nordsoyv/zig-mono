const std = @import("std");

const test1 =
    \\L68
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
;

const Dial = struct {
    pos: i32,
    numZeros : i32,

    pub fn turnDial(self: *Dial, dir : u8, number : i32) void {
        if(dir == 'L'){
            self.pos -= number;
            self.pos = @mod(self.pos, 100);
            if( self.pos == 0){
                self.numZeros += 1;
            }

        }else {
            self.pos += number;
            self.pos = @mod(self.pos, 100);

            if( self.pos == 0){
                self.numZeros += 1;
            }

        }
    }

    pub fn turnDial2(self: *Dial, dir: u8, number: i32) void{
        var arg : i32  = 1;


        if(dir == 'L'){
            arg = -1;
        }
        for (0..@intCast(number)) |_| {
            self.pos += arg;
            self.pos = @mod(self.pos, 100);
            if( self.pos == 0){
                self.numZeros += 1;
            }
        }


    }
};

pub fn task1(allocator: std.mem.Allocator) !void {
    const input = try std.fs.cwd().readFileAlloc(allocator, "src/day1/input1.txt", 1024 * 1024);
    defer allocator.free(input);
    var lines = std.mem.splitScalar(u8, input, '\n');
    var dial = Dial{ .pos = 50 , .numZeros = 0};

    while (lines.next()) |line| {
        // process each line
        std.debug.print("Line: {s} \n ", .{line});
        const dir = line[0];
        const number = try std.fmt.parseInt(i32, line[1..], 10);
        //const number =0;
        dial.turnDial(dir, number);


        //std.debug.print("{} {}\n", .{dial.pos , dial.numZeros});
    }
    std.debug.print("num zeros = {} \n", .{dial.numZeros });
}

pub fn task2(allocator: std.mem.Allocator) !void {
    const input = try std.fs.cwd().readFileAlloc(allocator, "src/day1/input1.txt", 1024 * 1024);
    //const input = test1;
    defer allocator.free(input);
    var lines = std.mem.splitScalar(u8, input, '\n');
    var dial = Dial{ .pos = 50 , .numZeros = 0};

    while (lines.next()) |line| {
        // process each line
        std.debug.print("Line: {s} \n ", .{line});
        const dir = line[0];
        const number = try std.fmt.parseInt(i32, line[1..], 10);
        //const number =0;
        dial.turnDial2(dir, number);


        //std.debug.print("{} {}\n", .{dial.pos , dial.numZeros});
    }
    std.debug.print("num zeros = {} \n", .{dial.numZeros });
}
