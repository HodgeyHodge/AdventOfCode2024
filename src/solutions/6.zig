const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Grid.init(input, allocator);
    const path = try data.enumerate_path(allocator);

    return count_coords(path, allocator);
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Grid.init(input, allocator);
    const path = try data.enumerate_path(allocator);

    var loopy_positions = std.AutoHashMap(Coord, void).init(allocator);
    var path_iter = path.iterator();
    while (path_iter.next()) |entry| {
        const p = entry.key_ptr.*;
        var new_obstacle: Coord = undefined;
        switch (p.d) {
            Direction.North => {
                if (p.x == 0) continue;
                new_obstacle = Coord{ .x = p.x - 1, .y = p.y };
            },
            Direction.East => {
                if (p.y == data.width - 1) continue;
                new_obstacle = Coord{ .x = p.x, .y = p.y + 1 };
            },
            Direction.South => {
                if (p.x == data.height - 1) continue;
                new_obstacle = Coord{ .x = p.x + 1, .y = p.y };
            },
            Direction.West => {
                if (p.y == 0) continue;
                new_obstacle = Coord{ .x = p.x, .y = p.y - 1 };
            },
        }
        if (data.start.x == new_obstacle.x and data.start.y == new_obstacle.y) continue;
        const result = try data.obstacles.getOrPut(new_obstacle);
        if (result.found_existing) continue;
        if (try data.detect_loop(allocator)) {
            try loopy_positions.put(new_obstacle, {});
        }
        _ = data.obstacles.remove(new_obstacle);
    }

    return loopy_positions.count();
}

const Direction = enum { North, East, South, West };
const Position = struct { x: usize, y: usize, d: Direction };
const Coord = struct { x: usize, y: usize };

const Grid = struct {
    obstacles: std.AutoHashMap(Coord, void),
    height: usize,
    width: usize,
    start: Position,

    pub fn init(input: []const u8, allocator: std.mem.Allocator) !Grid {
        var output = Grid{
            .obstacles = std.AutoHashMap(Coord, void).init(allocator),
            .height = 0,
            .width = 0,
            .start = Position{ .x = 0, .y = 0, .d = Direction.North },
        };

        var lines = std.mem.splitSequence(u8, input, "\n");
        var i: usize = 0;
        while (lines.next()) |line| {
            for (line, 0..) |c, j| {
                if (c == '#') {
                    try output.obstacles.put(Coord{ .x = i, .y = j }, {});
                }
                if (c == '^') {
                    output.start.x = i;
                    output.start.y = j;
                    output.start.d = Direction.North;
                }
            } else {
                output.width = line.len;
            }
            i += 1;
        } else {
            output.height = i;
        }

        return output;
    }

    pub fn detect_loop(self: *Grid, allocator: std.mem.Allocator) !bool {
        var visited = std.AutoHashMap(Position, void).init(allocator);

        var position = self.start;

        while (true) {
            switch (position.d) {
                Direction.North => {
                    if (position.x == 0) return false;

                    if (self.obstacles.contains(Coord{ .x = position.x - 1, .y = position.y })) {
                        position.d = Direction.East;
                        if (visited.contains(position)) return true;
                        try visited.put(position, {});
                    } else {
                        position.x -= 1;
                    }
                },
                Direction.East => {
                    if (position.y == self.width - 1) return false;

                    if (self.obstacles.contains(Coord{ .x = position.x, .y = position.y + 1 })) {
                        position.d = Direction.South;
                        if (visited.contains(position)) return true;
                        try visited.put(position, {});
                    } else {
                        position.y += 1;
                    }
                },
                Direction.South => {
                    if (position.x == self.height - 1) return false;

                    if (self.obstacles.contains(Coord{ .x = position.x + 1, .y = position.y })) {
                        position.d = Direction.West;
                        if (visited.contains(position)) return true;
                        try visited.put(position, {});
                    } else {
                        position.x += 1;
                    }
                },
                Direction.West => {
                    if (position.y == 0) return false;

                    if (self.obstacles.contains(Coord{ .x = position.x, .y = position.y - 1 })) {
                        position.d = Direction.North;
                        if (visited.contains(position)) return true;
                        try visited.put(position, {});
                    } else {
                        position.y -= 1;
                    }
                },
            }
        }
    }

    pub fn enumerate_path(self: *Grid, allocator: std.mem.Allocator) !std.AutoHashMap(Position, void) {
        var visited = std.AutoHashMap(Position, void).init(allocator);

        var position = self.start;

        while (true) {
            try visited.put(position, {});
            switch (position.d) {
                Direction.North => {
                    if (position.x == 0) break;

                    if (self.obstacles.contains(Coord{ .x = position.x - 1, .y = position.y })) {
                        position.d = Direction.East;
                    } else {
                        position.x -= 1;
                    }
                },
                Direction.East => {
                    if (position.y == self.width - 1) break;

                    if (self.obstacles.contains(Coord{ .x = position.x, .y = position.y + 1 })) {
                        position.d = Direction.South;
                    } else {
                        position.y += 1;
                    }
                },
                Direction.South => {
                    if (position.x == self.height - 1) break;

                    if (self.obstacles.contains(Coord{ .x = position.x + 1, .y = position.y })) {
                        position.d = Direction.West;
                    } else {
                        position.x += 1;
                    }
                },
                Direction.West => {
                    if (position.y == 0) break;

                    if (self.obstacles.contains(Coord{ .x = position.x, .y = position.y - 1 })) {
                        position.d = Direction.North;
                    } else {
                        position.y -= 1;
                    }
                },
            }
        }

        return visited;
    }
};

fn count_coords(input: std.AutoHashMap(Position, void), allocator: std.mem.Allocator) !u64 {
    var coords = std.AutoHashMap(Coord, void).init(allocator);

    var iter = input.iterator();
    while (iter.next()) |entry| {
        try coords.put(Coord{ .x = entry.key_ptr.*.x, .y = entry.key_ptr.*.y }, {});
    }
    return coords.count();
}
