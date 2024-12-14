const std = @import("std");

pub fn solve(args: struct { discount: bool }) (fn ([]const u8) anyerror!u64) {
    const CurriedSolver = struct {
        fn solve(input: []const u8) !u64 {
            return inner_solve(input, args.discount);
        }
    };
    return CurriedSolver.solve;
}

fn inner_solve(input: []const u8, discount: bool) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Data.init(input, allocator);

    try data.traverse(allocator);

    if (discount) {
        return data.calculate_discounted_cost();
    } else {
        return data.calculate_cost();
    }
}

const Direction = enum { North, East, South, West };
const Position = struct {
    i: usize,
    j: usize,
    d: ?Direction,

    fn step(self: Position) Position {
        if (self.d == null) {
            return Position{ .i = self.i, .j = self.j, .d = null };
        } else {
            switch (self.d.?) {
                Direction.North => {
                    return Position{ .i = self.i - 1, .j = self.j, .d = null };
                },
                Direction.East => {
                    return Position{ .i = self.i, .j = self.j + 1, .d = null };
                },
                Direction.South => {
                    return Position{ .i = self.i + 1, .j = self.j, .d = null };
                },
                Direction.West => {
                    return Position{ .i = self.i, .j = self.j - 1, .d = null };
                },
            }
        }
    }
};
const PositionSet = std.AutoHashMap(Position, void);
const TileDict = std.AutoHashMap(Position, u8);
const Cluster = struct { positions: PositionSet, bounds: PositionSet };
const ClusterDict = std.AutoHashMap(Cluster, u8);

const Data = struct {
    tiles: TileDict,
    burned: PositionSet,
    height: usize,
    width: usize,
    clusters: ClusterDict,

    fn init(input: []const u8, allocator: std.mem.Allocator) !Data {
        const line_count = std.mem.count(u8, input, "\n") + 1;
        var tiles = TileDict.init(allocator);
        var lines = std.mem.splitSequence(u8, input, "\n");
        var width: usize = undefined;
        var i: usize = 0;
        while (lines.next()) |line| {
            for (line, 0..) |c, j| {
                try tiles.put(Position{ .i = i, .j = j, .d = null }, c);
            }
            i += 1;
            width = line.len;
        }

        return Data{
            .tiles = tiles,
            .burned = PositionSet.init(allocator),
            .height = line_count,
            .width = width,
            .clusters = ClusterDict.init(allocator),
        };
    }

    fn iterate(self: *Data, cluster: *Cluster, p: Position, value: u8, allocator: std.mem.Allocator) !void {
        if ((p.i == 0 and p.d != null and p.d == Direction.North) or
            (p.j + 1 == self.width and p.d != null and p.d == Direction.East) or
            (p.i + 1 == self.height and p.d != null and p.d == Direction.South) or
            (p.j == 0 and p.d != null and p.d == Direction.West))
        {
            try cluster.bounds.put(p, {});
        } else {
            const new_position = p.step();

            if (self.tiles.get(new_position).? == value) {
                if (self.burned.contains(new_position)) {} else {
                    try cluster.positions.put(new_position, {});

                    try self.burned.put(new_position, {});

                    const neighbours = try get_neighbours(new_position, allocator);
                    var iter = neighbours.iterator();
                    while (iter.next()) |e| {
                        const n = e.key_ptr.*;
                        try self.iterate(cluster, n, value, allocator);
                    }
                }
            } else if (self.tiles.get(new_position).? != value) {
                try cluster.bounds.put(p, {});
            }
        }
    }

    fn traverse(self: *Data, allocator: std.mem.Allocator) !void {
        var tile_iter = self.tiles.iterator();

        while (tile_iter.next()) |e| {
            const tile_position = e.key_ptr.*;
            const tile_value = e.value_ptr.*;

            if (self.burned.contains(tile_position)) {
                continue;
            }

            var cluster = Cluster{
                .positions = PositionSet.init(allocator),
                .bounds = PositionSet.init(allocator),
            };

            try self.iterate(&cluster, tile_position, tile_value, allocator);

            try self.clusters.put(cluster, tile_value);
        }
    }

    fn calculate_cost(self: *Data) u64 {
        var output: u64 = 0;
        var iter = self.clusters.iterator();
        while (iter.next()) |e| {
            var cluster = e.key_ptr.*;
            const c = cluster.positions.count();
            const b = cluster.bounds.count();
            output += c * b;
        }

        return output;
    }

    fn calculate_discounted_cost(self: *Data) u64 {
        var output: u64 = 0;
        var iter = self.clusters.iterator();
        while (iter.next()) |e| {
            var cluster = e.key_ptr.*;
            const c = cluster.positions.count();
            const b = try self.calculate_discounted_bounds(&cluster.bounds);

            output += c * b;
        }

        return output;
    }

    fn calculate_discounted_bounds(_: *Data, bounds: *PositionSet) !u64 {
        var savings: u64 = 0;
        var bounds_iter = bounds.iterator();
        while (bounds_iter.next()) |e| {
            const p = e.key_ptr.*;
            var inner_iter = bounds.iterator();
            while (inner_iter.next()) |f| {
                const q = f.key_ptr.*;
                if (p.d == q.d) {
                    if (p.i == q.i and (p.d == Direction.North or p.d == Direction.South) and (p.j == q.j + 1)) {
                        savings += 1;
                    } else if (p.j == q.j and (p.d == Direction.East or p.d == Direction.West) and (p.i == q.i + 1)) {
                        savings += 1;
                    }
                }
            }
        }

        return bounds.count() - savings;
    }

    fn pretty_print(self: *Data) void {
        std.debug.print("Printing Data:\n", .{});
        std.debug.print("  Height: {any}\n", .{self.height});
        std.debug.print("  Width: {any}\n", .{self.width});
        std.debug.print("  Tiles: ", .{});
        var tile_iterator = self.tiles.iterator();
        while (tile_iterator.next()) |e| {
            const coord = e.key_ptr.*;
            const value = e.value_ptr.*;
            std.debug.print("{d}:{d}:{c} ", .{ coord.i, coord.j, value });
        }
        std.debug.print("\n  Burned: ", .{});
        var burned_iterator = self.burned.iterator();
        while (burned_iterator.next()) |e| {
            const coord = e.key_ptr.*;
            std.debug.print("{d}:{d} ", .{ coord.i, coord.j });
        }
        std.debug.print("\n  Clusters:\n", .{});
        var iterator = self.clusters.iterator();
        while (iterator.next()) |e| {
            const cluster = e.key_ptr.*;
            const value = e.value_ptr.*;
            std.debug.print("    Region of {c}:\n", .{value});
            std.debug.print("      Positions:\n", .{});
            var positions_iter = cluster.positions.iterator();
            while (positions_iter.next()) |cluster_entry| {
                const position = cluster_entry.key_ptr.*;
                std.debug.print("        {d}:{d}\n", .{ position.i, position.j });
            }
            std.debug.print("      Bounds:\n", .{});
            var bounds_iter = cluster.bounds.iterator();
            while (bounds_iter.next()) |cluster_entry| {
                const bound = cluster_entry.key_ptr.*;
                std.debug.print("        {d}:{d}:{s}\n", .{ bound.i, bound.j, std.enums.tagName(Direction, bound.d.?) orelse unreachable });
            }
        }
        std.debug.print("\n", .{});
    }
};

fn get_neighbours(position: Position, allocator: std.mem.Allocator) !PositionSet {
    var output = PositionSet.init(allocator);

    try output.put(Position{ .i = position.i, .j = position.j, .d = Direction.North }, {});
    try output.put(Position{ .i = position.i, .j = position.j, .d = Direction.East }, {});
    try output.put(Position{ .i = position.i, .j = position.j, .d = Direction.South }, {});
    try output.put(Position{ .i = position.i, .j = position.j, .d = Direction.West }, {});

    return output;
}
