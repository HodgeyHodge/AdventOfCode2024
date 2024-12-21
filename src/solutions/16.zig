const std = @import("std");

pub fn solve(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var maze = try Maze.init(input, allocator);

    try maze.connect();

    while (true) {
        const progress = try maze.reduce();
        if (!progress) break;
    }

    return maze.traverse(allocator);
}

const Position = [2]usize;
const Comparison = enum { Identical, Adjacent, Opposite };
const Direction = enum {
    North,
    East,
    South,
    West,

    fn compare(self: Direction, other: Direction) Comparison {
        switch (self) {
            Direction.North => {
                if (other == Direction.North) return Comparison.Identical;
                if (other == Direction.South) return Comparison.Opposite;
                return Comparison.Adjacent;
            },
            Direction.East => {
                if (other == Direction.East) return Comparison.Identical;
                if (other == Direction.West) return Comparison.Opposite;
                return Comparison.Adjacent;
            },
            Direction.South => {
                if (other == Direction.South) return Comparison.Identical;
                if (other == Direction.North) return Comparison.Opposite;
                return Comparison.Adjacent;
            },
            Direction.West => {
                if (other == Direction.West) return Comparison.Identical;
                if (other == Direction.East) return Comparison.Opposite;
                return Comparison.Adjacent;
            },
        }
    }

    fn turn(self: Direction) Direction {
        switch (self) {
            Direction.North => return Direction.East,
            Direction.East => return Direction.South,
            Direction.South => return Direction.West,
            Direction.West => return Direction.North,
        }
    }
};
const MoveDetails = struct { destination: Position, arrival_direction: Direction, cost: u64 };
const Moves = std.AutoHashMap(Direction, MoveDetails);
const Positions = std.AutoHashMap(Position, Moves);
const Vertex = struct { position: Position, direction: Direction };
const VertexDetails = struct { visited: bool, total_cost: u64 };

const Maze = struct {
    field: Positions,
    start: Position,
    end: Position,
    height: usize,
    width: usize,

    fn init(input: []const u8, allocator: std.mem.Allocator) !Maze {
        var field = Positions.init(allocator);
        var start: Position = undefined;
        var end: Position = undefined;
        var height: usize = undefined;
        var width: usize = undefined;

        var split_input = std.mem.splitScalar(u8, input, '\n');
        var i: usize = 0;
        while (split_input.next()) |line| : (i += 1) {
            for (line, 0..) |c, j| {
                if (c == '.' or c == 'E' or c == 'S') {
                    try field.put(Position{ i, j }, Moves.init(allocator));

                    if (c == 'E') {
                        end = Position{ i, j };
                    } else if (c == 'S') {
                        start = Position{ i, j };
                    }
                }

                width = line.len;
            }
        }
        height = i;

        return Maze{
            .field = field,
            .start = start,
            .end = end,
            .height = height,
            .width = width,
        };
    }

    fn connect(self: *Maze) !void {
        var iter = self.field.iterator();
        while (iter.next()) |e| {
            const k: *Position = e.key_ptr;
            var v: *Moves = e.value_ptr;
            if (self.field.contains(Position{ k[0] - 1, k[1] })) try v.put(Direction.North, MoveDetails{ .destination = Position{ k[0] - 1, k[1] }, .arrival_direction = Direction.North, .cost = 1 });
            if (self.field.contains(Position{ k[0], k[1] + 1 })) try v.put(Direction.East, MoveDetails{ .destination = Position{ k[0], k[1] + 1 }, .arrival_direction = Direction.East, .cost = 1 });
            if (self.field.contains(Position{ k[0] + 1, k[1] })) try v.put(Direction.South, MoveDetails{ .destination = Position{ k[0] + 1, k[1] }, .arrival_direction = Direction.South, .cost = 1 });
            if (self.field.contains(Position{ k[0], k[1] - 1 })) try v.put(Direction.West, MoveDetails{ .destination = Position{ k[0], k[1] - 1 }, .arrival_direction = Direction.West, .cost = 1 });
        }
    }

    fn reduce(self: *Maze) !bool {
        var field_iter = self.field.iterator();
        while (field_iter.next()) |e| {
            const position: Position = e.key_ptr.*;
            var moves: *Moves = e.value_ptr;

            if (std.mem.eql(usize, &position, &self.start) or std.mem.eql(usize, &position, &self.end)) continue;

            if (moves.count() == 1) {
                var moves_iter = moves.valueIterator();
                const parent_position = (moves_iter.next() orelse unreachable).*.destination;
                const parent_moves: *Moves = self.field.getPtr(parent_position) orelse unreachable;
                var parent_iter = parent_moves.iterator();
                while (parent_iter.next()) |entry| {
                    if (std.mem.eql(usize, &entry.value_ptr.destination, &position)) {
                        _ = parent_moves.remove(entry.key_ptr.*);
                        break;
                    }
                } else {
                    unreachable;
                }
                _ = self.field.remove(position);
                return true;
            }

            if (moves.count() == 2) {
                var moves_iter = moves.iterator();

                const move_to_parent_1 = moves_iter.next() orelse unreachable;
                const direction_to_parent_1 = move_to_parent_1.key_ptr;
                const move_to_parent_1_details = move_to_parent_1.value_ptr;
                const parent_1_position = move_to_parent_1_details.destination;
                const parent_1_moves: *Moves = self.field.getPtr(parent_1_position) orelse unreachable;
                const direction_from_parent_1: Direction = blk: {
                    var parent_1_moves_iter = parent_1_moves.iterator();
                    while (parent_1_moves_iter.next()) |entry| {
                        if (std.mem.eql(usize, &entry.value_ptr.destination, &position)) {
                            break :blk entry.key_ptr.*;
                        }
                    } else {
                        unreachable;
                    }
                };
                var parent_1_move_details = parent_1_moves.getPtr(direction_from_parent_1).?;

                const move_to_parent_2 = moves_iter.next() orelse unreachable;
                //const direction_to_parent_2 = move_to_parent_2.key_ptr;
                const move_to_parent_2_details = move_to_parent_2.value_ptr;
                const parent_2_position = move_to_parent_2_details.destination;
                const parent_2_moves: *Moves = self.field.getPtr(parent_2_position) orelse unreachable;
                const direction_from_parent_2: Direction = blk: {
                    var parent_2_moves_iter = parent_2_moves.iterator();
                    while (parent_2_moves_iter.next()) |entry| {
                        if (std.mem.eql(usize, &entry.value_ptr.destination, &position)) {
                            break :blk entry.key_ptr.*;
                        }
                    } else {
                        unreachable;
                    }
                };
                var parent_2_move_details = parent_2_moves.getPtr(direction_from_parent_2).?;

                //if the parents are the same, we have a loop, so just remove it

                if (std.mem.eql(usize, &parent_1_position, &parent_2_position)) {
                    const parent_moves: *Moves = self.field.getPtr(parent_1_position) orelse unreachable;
                    var parent_iter = parent_moves.iterator();
                    while (parent_iter.next()) |entry| {
                        if (std.mem.eql(usize, &entry.value_ptr.destination, &position)) {
                            _ = parent_moves.remove(entry.key_ptr.*);
                        }
                    }
                    _ = self.field.remove(position);
                    return true;
                }

                var turning_cost: u64 = 0;
                switch (direction_to_parent_1.compare(parent_2_move_details.arrival_direction)) {
                    Comparison.Adjacent => {
                        turning_cost = 1000;
                    },
                    Comparison.Identical => {},
                    Comparison.Opposite => {
                        unreachable;
                    },
                }

                parent_1_move_details.destination = parent_2_position;
                parent_1_move_details.cost += move_to_parent_2_details.cost + turning_cost;
                parent_1_move_details.arrival_direction = move_to_parent_2_details.arrival_direction;

                parent_2_move_details.destination = parent_1_position;
                parent_2_move_details.cost += move_to_parent_1_details.cost + turning_cost;
                parent_2_move_details.arrival_direction = move_to_parent_1_details.arrival_direction;

                _ = self.field.remove(position);

                return true;
            }
        }

        return false;
    }

    fn traverse(self: *const Maze, allocator: std.mem.Allocator) !u64 {
        var graph = std.AutoHashMap(Vertex, VertexDetails).init(allocator);

        var iter = self.field.keyIterator();
        while (iter.next()) |p| {
            const position = p.*;
            try graph.put(Vertex{ .position = position, .direction = Direction.North }, VertexDetails{ .visited = false, .total_cost = std.math.maxInt(u64) });
            try graph.put(Vertex{ .position = position, .direction = Direction.East }, VertexDetails{ .visited = false, .total_cost = std.math.maxInt(u64) });
            try graph.put(Vertex{ .position = position, .direction = Direction.South }, VertexDetails{ .visited = false, .total_cost = std.math.maxInt(u64) });
            try graph.put(Vertex{ .position = position, .direction = Direction.West }, VertexDetails{ .visited = false, .total_cost = std.math.maxInt(u64) });
        }

        //DIJKSTRA'S ALGORITHM: one vertex per maze tile per direction faced

        var current_vertex = Vertex{ .position = self.start, .direction = Direction.East };
        var current_details: *VertexDetails = graph.getPtr(current_vertex).?;
        current_details.total_cost = 0;

        while (true) {
            current_details.visited = true;

            const t_1_vertex = Vertex{ .position = current_vertex.position, .direction = current_vertex.direction.turn() };
            const v_1: *VertexDetails = graph.getPtr(t_1_vertex) orelse unreachable;
            if (!v_1.visited) {
                v_1.total_cost = @min(v_1.total_cost, current_details.total_cost + 1000);
            }

            const t_2_vertex = Vertex{ .position = current_vertex.position, .direction = current_vertex.direction.turn().turn().turn() };
            const v_2: *VertexDetails = graph.getPtr(t_2_vertex) orelse unreachable;
            if (!v_2.visited) {
                v_2.total_cost = @min(v_2.total_cost, current_details.total_cost + 1000);
            }

            const third_vertex_move: ?MoveDetails = blk: {
                const current_moves: ?Moves = self.field.get(current_vertex.position);
                if (current_moves == null) break :blk null;
                const current_move_details = current_moves.?.get(current_vertex.direction);
                break :blk current_move_details;
            };
            if (third_vertex_move != null) {
                const v_3: ?*VertexDetails = graph.getPtr(Vertex{ .position = third_vertex_move.?.destination, .direction = third_vertex_move.?.arrival_direction });
                if (v_3 == null) {
                    unreachable;
                }
                if (!v_3.?.visited) {
                    v_3.?.total_cost = @min(v_3.?.total_cost, current_details.total_cost + third_vertex_move.?.cost);
                }
            }

            //move to unvisited node with smallest total_cost, or break if none found
            var new_iter = graph.iterator();
            var new_vertex: ?Vertex = null;
            var new_details: ?VertexDetails = null;
            while (new_iter.next()) |e| {
                const vertex: Vertex = e.key_ptr.*;
                const details: VertexDetails = e.value_ptr.*;

                if (!details.visited and (new_details == null or details.total_cost < new_details.?.total_cost)) {
                    new_vertex = vertex;
                    new_details = details;
                }
            }

            if (new_vertex == null) break;

            current_vertex = new_vertex.?;
            current_details = graph.getPtr(current_vertex).?;
        }

        //finally grab all vertices at end (in any direction) and present cheapest total_cost as final answer
        var final_iter = graph.iterator();
        var output: u64 = std.math.maxInt(u64);
        while (final_iter.next()) |e| {
            const vertex: Vertex = e.key_ptr.*;
            const details: VertexDetails = e.value_ptr.*;
            if (std.mem.eql(usize, &vertex.position, &self.end) and details.total_cost < output) {
                output = details.total_cost;
            }
        }

        return output;
    }

    fn draw(self: *const Maze) void {
        std.debug.print("\n", .{});
        for (0..self.height) |i| {
            for (0..self.width) |j| {
                if (self.field.contains([2]usize{ i, j })) {
                    std.debug.print("X", .{});
                } else {
                    std.debug.print(" ", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }

    fn pretty_print(self: *const Maze) void {
        var iter = self.field.iterator();
        std.debug.print("Start: {d}\n", .{self.start});
        std.debug.print("End: {d}\n", .{self.end});
        std.debug.print("Width: {d}\n", .{self.width});
        std.debug.print("Height: {d}\n", .{self.height});
        while (iter.next()) |e| {
            const k: [2]usize = e.key_ptr.*;
            const v: Moves = e.value_ptr.*;
            std.debug.print("Position: {d}:{d}\n", .{ k[0], k[1] });
            var inner_iter = v.iterator();
            while (inner_iter.next()) |f| {
                std.debug.print("  Move: {s} --> {any}\n", .{ std.enums.tagName(Direction, f.key_ptr.*) orelse unreachable, f.value_ptr.* });
            }
        }
    }
};
