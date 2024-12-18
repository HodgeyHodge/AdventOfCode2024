const std = @import("std");

pub fn solve(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Data.init(input, allocator);

    for (data.instructions) |instruction| {
        var moves = Moves.init(allocator);
        const can_move = try data.build_moves(Move{ .position = [2]usize{ data.robot[0], data.robot[1] }, .direction = instruction }, &moves);
        if (can_move) {
            try data.make_moves(&moves);
        }
    }

    return data.calculate_score();
}

const Direction = enum { North, East, South, West };
const Tile = enum { BoxLeft, BoxRight, Wall };
const Move = struct { position: [2]usize, direction: Direction };

const Moves = std.AutoArrayHashMap(Move, void);

const Data = struct {
    field: std.AutoHashMap([2]usize, Tile),
    robot: [2]usize,
    instructions: []const Direction,
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
                        robot = [2]usize{ i - 1, 2 * j - 2 };
                    },
                    '#' => {
                        try field.put([2]usize{ i - 1, 2 * j - 2 }, Tile.Wall);
                        try field.put([2]usize{ i - 1, 2 * j - 1 }, Tile.Wall);
                    },
                    'O' => {
                        try field.put([2]usize{ i - 1, 2 * j - 2 }, Tile.BoxLeft);
                        try field.put([2]usize{ i - 1, 2 * j - 1 }, Tile.BoxRight);
                    },
                    else => {},
                }

                width = j + 1;
            }
            height = i + 1;
        }

        const instructions_section = iter.next() orelse unreachable;
        var instructions_out = try allocator.alloc(Direction, instructions_section.len);
        var write_index: usize = 0;
        for (instructions_section) |c| {
            switch (c) {
                '^' => {
                    instructions_out[write_index] = Direction.North;
                    write_index += 1;
                },
                '>' => {
                    instructions_out[write_index] = Direction.East;
                    write_index += 1;
                },
                'v' => {
                    instructions_out[write_index] = Direction.South;
                    write_index += 1;
                },
                '<' => {
                    instructions_out[write_index] = Direction.West;
                    write_index += 1;
                },
                else => {},
            }
        }

        return Data{
            .field = field,
            .robot = robot,
            .width = 2 * map_width - 4,
            .height = map_height - 2,
            .instructions = instructions_out[0..write_index],
        };
    }

    fn build_moves(self: *Data, move: Move, moves: *Moves) !bool {
        const current_tile = self.field.get(move.position);
        if (current_tile == null and !std.mem.eql(usize, &self.robot, &move.position)) return true;
        if (current_tile != null and current_tile.? == Tile.Wall) return false;

        const possible_next_move = self.successor(&move);
        if (possible_next_move == null) return false;
        const next_move = possible_next_move.?;
        const next_tile = self.field.get(next_move.position);

        if ((next_move.direction == Direction.North or next_move.direction == Direction.South) and next_tile != null and next_tile.? == Tile.BoxLeft) {
            const this_half = try self.build_moves(next_move, moves);
            const other_half = try self.build_moves(
                Move{
                    .position = [2]usize{ next_move.position[0], next_move.position[1] + 1 },
                    .direction = next_move.direction,
                },
                moves,
            );
            _ = try moves.put(move, {});
            return this_half and other_half;
        } else if ((next_move.direction == Direction.North or next_move.direction == Direction.South) and next_tile != null and next_tile.? == Tile.BoxRight) {
            const this_half = try self.build_moves(next_move, moves);
            const other_half = try self.build_moves(
                Move{
                    .position = [2]usize{ next_move.position[0], next_move.position[1] - 1 },
                    .direction = next_move.direction,
                },
                moves,
            );
            _ = try moves.put(move, {});
            return this_half and other_half;
        } else {
            const can_move = try self.build_moves(next_move, moves);
            _ = try moves.put(move, {});
            return can_move;
        }
    }

    fn make_moves(self: *Data, moves: *Moves) !void {
        var iter = moves.iterator();
        while (iter.next()) |entry| {
            const move = entry.key_ptr.*;
            const next = self.successor(&move).?;
            const current = self.field.get(move.position);
            if (current == null) {
                self.robot = next.position;
            } else {
                try self.field.put(next.position, current.?);
                _ = self.field.remove(move.position);
            }
        }
    }

    fn successor(self: *const Data, move: *const Move) ?Move {
        switch (move.direction) {
            Direction.North => {
                if (move.position[0] == 0) return null;
                return Move{ .position = [2]usize{ move.position[0] - 1, move.position[1] }, .direction = move.direction };
            },
            Direction.East => {
                if (move.position[1] + 1 == self.width) return null;
                return Move{ .position = [2]usize{ move.position[0], move.position[1] + 1 }, .direction = move.direction };
            },
            Direction.South => {
                if (move.position[0] + 1 == self.height) return null;
                return Move{ .position = [2]usize{ move.position[0] + 1, move.position[1] }, .direction = move.direction };
            },
            Direction.West => {
                if (move.position[1] == 0) return null;
                return Move{ .position = [2]usize{ move.position[0], move.position[1] - 1 }, .direction = move.direction };
            },
        }
    }

    fn calculate_score(self: *const Data) u64 {
        var output: u64 = 0;
        var iter = self.field.iterator();
        while (iter.next()) |e| {
            const position = e.key_ptr.*;
            const tile = e.value_ptr.*;
            if (tile == Tile.BoxLeft) {
                output += 100 * (position[0] + 1) + position[1] + 2;
            }
        }

        return output;
    }

    fn pretty_print(self: *const Data) void {
        std.debug.print("here's your data lol:\n", .{});
        std.debug.print("  instructions:\n    ", .{});
        for (self.instructions) |i| {
            std.debug.print("{s}, ", .{std.enums.tagName(Direction, i) orelse unreachable});
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
                if (tile == Tile.BoxLeft) {
                    char = '[';
                } else if (tile == Tile.BoxRight) {
                    char = ']';
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
