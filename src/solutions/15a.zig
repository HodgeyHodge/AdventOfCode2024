const std = @import("std");

pub fn solve(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Data.init(input, allocator);

    for (data.moves) |move| {
        _ = try data.move(data.robot, move);
    }

    return data.calculate_score();
}

const Direction = enum { North, East, South, West };
const Tile = enum { Box, Wall };

const Data = struct {
    field: std.AutoHashMap([2]usize, Tile),
    robot: [2]usize,
    moves: []const Direction,
    height: usize,
    width: usize,

    fn init(input: []const u8, allocator: std.mem.Allocator) !Data {
        var field = std.AutoHashMap([2]usize, Tile).init(allocator);
        var robot: [2]usize = undefined;
        var width: usize = undefined;
        var height: usize = undefined;

        var iter = std.mem.splitSequence(u8, input, "\n\n");

        const map_section = iter.next() orelse unreachable;
        const map_height = std.mem.count(u8, map_section, "\n") + 1;
        var map_iter = std.mem.splitScalar(u8, map_section, '\n');
        var i: usize = 0;
        var map_width: usize = undefined;
        while (map_iter.next()) |line| : (i += 1) {
            if (i == 0) {
                map_width = line.len;
                continue;
            }
            if (i == map_height - 1) continue;

            for (line, 0..) |c, j| {
                if (j == 0 or j == map_width - 1) continue;

                switch (c) {
                    '@' => {
                        robot = [2]usize{ i - 1, j - 1 };
                    },
                    '#' => {
                        try field.put([2]usize{ i - 1, j - 1 }, Tile.Wall);
                    },
                    'O' => {
                        try field.put([2]usize{ i - 1, j - 1 }, Tile.Box);
                    },
                    else => {},
                }

                width = j + 1;
            }
            height = i + 1;
        }

        const moves_section = iter.next() orelse unreachable;
        var moves_out = try allocator.alloc(Direction, moves_section.len);
        var write_index: usize = 0;
        for (moves_section) |c| {
            switch (c) {
                '^' => {
                    moves_out[write_index] = Direction.North;
                    write_index += 1;
                },
                '>' => {
                    moves_out[write_index] = Direction.East;
                    write_index += 1;
                },
                'v' => {
                    moves_out[write_index] = Direction.South;
                    write_index += 1;
                },
                '<' => {
                    moves_out[write_index] = Direction.West;
                    write_index += 1;
                },
                else => {},
            }
        }

        return Data{
            .field = field,
            .robot = robot,
            .width = map_width - 2,
            .height = map_height - 2,
            .moves = moves_out[0..write_index],
        };
    }

    fn move(self: *Data, position: [2]usize, direction: Direction) !bool {
        const current = self.field.get(position);
        if (current == null and !std.mem.eql(usize, &self.robot, &position)) return true;

        var successor: [2]usize = undefined;
        switch (direction) {
            Direction.North => {
                if (position[0] == 0) return false;
                successor = [2]usize{ position[0] - 1, position[1] };
            },
            Direction.East => {
                if (position[1] + 1 == self.width) return false;
                successor = [2]usize{ position[0], position[1] + 1 };
            },
            Direction.South => {
                if (position[0] + 1 == self.height) return false;
                successor = [2]usize{ position[0] + 1, position[1] };
            },
            Direction.West => {
                if (position[1] == 0) return false;
                successor = [2]usize{ position[0], position[1] - 1 };
            },
        }

        const successor_tile = self.field.get(successor);

        if (successor_tile == null) {
            if (current == null) {
                self.robot = successor;
            } else {
                try self.field.put(successor, current.?);
                _ = self.field.remove(position);
            }
            return true;
        } else if (successor_tile.? == Tile.Wall) {
            return false;
        } else if (successor_tile.? == Tile.Box) {
            const successor_moved = try self.move(successor, direction);
            if (successor_moved) {
                if (current == null) {
                    self.robot = successor;
                } else {
                    try self.field.put(successor, current.?);
                    _ = self.field.remove(position);
                }
                return true;
            } else {
                return false;
            }
        } else unreachable;
    }

    fn calculate_score(self: *const Data) u64 {
        var output: u64 = 0;
        var iter = self.field.iterator();
        while (iter.next()) |e| {
            const position = e.key_ptr.*;
            const tile = e.value_ptr.*;
            if (tile == Tile.Box) {
                output += 100 * (position[0] + 1) + position[1] + 1;
            }
        }

        return output;
    }

    fn pretty_print(self: *const Data) void {
        std.debug.print("here's your data lol:\n", .{});
        std.debug.print("  moves:\n    ", .{});
        for (self.moves) |m| {
            std.debug.print("{s}, ", .{std.enums.tagName(Direction, m) orelse unreachable});
        }
        std.debug.print("\n  robot: {any}\n", .{self.robot});
        std.debug.print("  width: {any}\n", .{self.width});
        std.debug.print("  height: {any}\n", .{self.height});
        var iter = self.field.iterator();
        std.debug.print("  field:\n", .{});
        while (iter.next()) |e| {
            const key = e.key_ptr.*;
            const value = e.value_ptr.*;
            std.debug.print("    {d}:{d} = {s}\n", .{ key[0], key[1], std.enums.tagName(Tile, value) orelse unreachable });
        }
    }

    fn draw(self: *const Data) void {
        for (0..self.height) |i| {
            for (0..self.width) |j| {
                const tile = self.field.get([2]usize{ i, j });
                var char: u8 = undefined;
                if (tile == Tile.Box) {
                    char = 'O';
                } else if (tile == Tile.Wall) {
                    char = '#';
                } else if (std.mem.eql(usize, &self.robot, &[2]usize{ i, j })) {
                    char = '@';
                } else {
                    char = '.';
                }
                std.debug.print("{c}", .{char});
            }
            std.debug.print("\n", .{});
        }
    }
};
