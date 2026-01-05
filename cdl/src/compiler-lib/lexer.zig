const std = @import("std");

pub const Kind = enum {
    eof,
    invalid,

    identifier,
    number,
    string,

    l_brace,
    r_brace,
    l_paren,
    r_paren,
    l_bracket,
    r_bracket,

    comma,
    dot,
    colon,
    semicolon,
    slash,
    backslash,
    caret,
    hash,
    at,

    plus,
    minus,
    star,
    percent,

    eq,
    eq_eq,
    bang,
    bang_eq,
    lt,
    lt_eq,
    gt,
    gt_eq,

    pipe,
};

pub const Token = struct {
    kind: Kind,
    lexeme: []const u8,
    start: usize,
    end: usize,
    line: u32,
    column: u32,
};

pub const Lexer = struct {
    input: []const u8,
    i: usize = 0,
    line: u32 = 1,
    column: u32 = 1,

    pub fn init(input: []const u8) Lexer {
        return .{ .input = input };
    }

    pub fn next(self: *Lexer) Token {
        self.skipTrivia();

        const start_i = self.i;
        const start_line = self.line;
        const start_col = self.column;

        if (self.eof()) {
            return .{ .kind = .eof, .lexeme = self.input[self.i..self.i], .start = self.i, .end = self.i, .line = start_line, .column = start_col };
        }

        const c = self.peek().?;

        switch (c) {
            '{' => return self.single(.l_brace, start_i, start_line, start_col),
            '}' => return self.single(.r_brace, start_i, start_line, start_col),
            '(' => return self.single(.l_paren, start_i, start_line, start_col),
            ')' => return self.single(.r_paren, start_i, start_line, start_col),
            '[' => return self.single(.l_bracket, start_i, start_line, start_col),
            ']' => return self.single(.r_bracket, start_i, start_line, start_col),
            ',' => return self.single(.comma, start_i, start_line, start_col),
            '.' => {
                if (self.peek2IsDigit()) return self.number(start_i, start_line, start_col);
                return self.single(.dot, start_i, start_line, start_col);
            },
            ':' => return self.single(.colon, start_i, start_line, start_col),
            ';' => return self.single(.semicolon, start_i, start_line, start_col),
            '/' => return self.single(.slash, start_i, start_line, start_col),
            '\\' => return self.single(.backslash, start_i, start_line, start_col),
            '^' => return self.single(.caret, start_i, start_line, start_col),
            '#' => return self.single(.hash, start_i, start_line, start_col),
            '@' => return self.single(.at, start_i, start_line, start_col),
            '+' => return self.single(.plus, start_i, start_line, start_col),
            '-' => return self.single(.minus, start_i, start_line, start_col),
            '*' => return self.single(.star, start_i, start_line, start_col),
            '%' => return self.single(.percent, start_i, start_line, start_col),
            '|' => return self.single(.pipe, start_i, start_line, start_col),
            '=' => {
                _ = self.advance();
                if (self.match('=')) {
                    return self.make(.eq_eq, start_i, start_line, start_col);
                }
                return self.make(.eq, start_i, start_line, start_col);
            },
            '!' => {
                _ = self.advance();
                if (self.match('=')) {
                    return self.make(.bang_eq, start_i, start_line, start_col);
                }
                return self.make(.bang, start_i, start_line, start_col);
            },
            '<' => {
                _ = self.advance();
                if (self.match('=')) {
                    return self.make(.lt_eq, start_i, start_line, start_col);
                }
                return self.make(.lt, start_i, start_line, start_col);
            },
            '>' => {
                _ = self.advance();
                if (self.match('=')) {
                    return self.make(.gt_eq, start_i, start_line, start_col);
                }
                return self.make(.gt, start_i, start_line, start_col);
            },
            '"', '\'' => return self.string(c, start_i, start_line, start_col),
            else => {},
        }

        if (isDigit(c)) {
            return self.number(start_i, start_line, start_col);
        }

        if (isIdentStart(c)) {
            return self.identOrKeyword(start_i, start_line, start_col);
        }

        _ = self.advance();
        return self.make(.invalid, start_i, start_line, start_col);
    }

    fn skipTrivia(self: *Lexer) void {
        while (true) {
            var progressed = false;
            while (self.peek()) |c| {
                if (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
                    _ = self.advance();
                    progressed = true;
                } else break;
            }

            if (self.peek()) |c| {
                if (c == '/' and self.peekOffset(1) == '/') {
                    _ = self.advance();
                    _ = self.advance();
                    while (self.peek()) |d| {
                        if (d == '\n') break;
                        _ = self.advance();
                    }
                    progressed = true;
                    continue;
                }
            }

            if (!progressed) break;
        }
    }

    fn identOrKeyword(self: *Lexer, start_i: usize, start_line: u32, start_col: u32) Token {
        _ = self.advance();
        while (self.peek()) |c| {
            if (!isIdentContinue(c)) break;
            _ = self.advance();
        }

        const lex = self.input[start_i..self.i];
        return .{ .kind = .identifier, .lexeme = lex, .start = start_i, .end = self.i, .line = start_line, .column = start_col };
    }

    fn number(self: *Lexer, start_i: usize, start_line: u32, start_col: u32) Token {
        if (self.peek() == '.' and self.peek2IsDigit()) {
            _ = self.advance();
        }

        while (self.peek()) |c| {
            if (!isDigit(c)) break;
            _ = self.advance();
        }

        if (self.peek() == '.' and self.peekOffset(1) != '.' and self.peekOffset(1) != null) {
            if (self.peekOffset(1)) |n| {
                if (isDigit(n)) {
                    _ = self.advance();
                    while (self.peek()) |c| {
                        if (!isDigit(c)) break;
                        _ = self.advance();
                    }
                }
            }
        }

        return self.make(.number, start_i, start_line, start_col);
    }

    fn string(self: *Lexer, quote: u8, start_i: usize, start_line: u32, start_col: u32) Token {
        _ = self.advance();
        while (self.peek()) |c| {
            if (c == quote) {
                _ = self.advance();
                return self.make(.string, start_i, start_line, start_col);
            }
            if (c == '\\') {
                _ = self.advance();
                if (!self.eof()) _ = self.advance();
                continue;
            }
            _ = self.advance();
        }

        return self.make(.invalid, start_i, start_line, start_col);
    }

    fn single(self: *Lexer, kind: Kind, start_i: usize, start_line: u32, start_col: u32) Token {
        _ = self.advance();
        return self.make(kind, start_i, start_line, start_col);
    }

    fn make(self: *Lexer, kind: Kind, start_i: usize, start_line: u32, start_col: u32) Token {
        return .{ .kind = kind, .lexeme = self.input[start_i..self.i], .start = start_i, .end = self.i, .line = start_line, .column = start_col };
    }

    fn eof(self: *Lexer) bool {
        return self.i >= self.input.len;
    }

    fn peek(self: *Lexer) ?u8 {
        if (self.i >= self.input.len) return null;
        return self.input[self.i];
    }

    fn peekOffset(self: *Lexer, off: usize) ?u8 {
        const idx = self.i + off;
        if (idx >= self.input.len) return null;
        return self.input[idx];
    }

    fn peek2IsDigit(self: *Lexer) bool {
        if (self.peekOffset(1)) |c| return isDigit(c);
        return false;
    }

    fn match(self: *Lexer, expected: u8) bool {
        if (self.peek() == expected) {
            _ = self.advance();
            return true;
        }
        return false;
    }

    fn advance(self: *Lexer) ?u8 {
        if (self.i >= self.input.len) return null;
        const c = self.input[self.i];
        self.i += 1;

        if (c == '\n') {
            self.line += 1;
            self.column = 1;
        } else {
            self.column += 1;
        }

        return c;
    }
};

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn isIdentStart(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_';
}

fn isIdentContinue(c: u8) bool {
    return isIdentStart(c) or isDigit(c);
}
