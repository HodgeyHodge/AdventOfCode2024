const std = @import("std");

pub fn solve(args: struct { iterations: u8 }) (fn ([]const u8) anyerror!u64) {
    const CurriedSolver = struct {
        fn solve(input: []const u8) !u64 {
            return inner_solve(input, args.iterations);
        }
    };
    return CurriedSolver.solve;
}

fn inner_solve(input: []const u8, iterations: u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var stones = try ingest_input(input, allocator);

    for (0..iterations) |_| {
        try blink(&stones, allocator);
    }

    return count_stones(&stones);
}

const Stones = std.StringHashMap(u64);

fn blink(stones: *Stones, allocator: std.mem.Allocator) !void {
    var new_stones = Stones.init(allocator);

    var iterator = stones.iterator();
    while (iterator.next()) |e| {
        const inscription = e.key_ptr.*;
        const multiplicity = e.value_ptr.*;

        if (std.mem.eql(u8, inscription, &[_]u8{'0'})) {
            const result = try new_stones.getOrPut(&[_]u8{'1'});
            if (result.found_existing) {
                result.value_ptr.* += multiplicity;
            } else {
                result.value_ptr.* = multiplicity;
            }
        } else if (inscription.len % 2 == 0) {
            const first_half = inscription[0 .. inscription.len / 2];
            const first_result = try new_stones.getOrPut(first_half);
            if (first_result.found_existing) {
                first_result.value_ptr.* += multiplicity;
            } else {
                first_result.value_ptr.* = multiplicity;
            }
            var second_half = inscription[inscription.len / 2 ..];
            while (second_half.len > 1 and second_half[0] == '0') {
                second_half = second_half[1..];
            }
            const second_result = try new_stones.getOrPut(second_half);
            if (second_result.found_existing) {
                second_result.value_ptr.* += multiplicity;
            } else {
                second_result.value_ptr.* = multiplicity;
            }
        } else {
            const bigger_inscription_num = try std.fmt.parseInt(u64, inscription, 10) * 2024;
            const bigger_inscription = try std.fmt.allocPrint(
                allocator,
                "{d}",
                .{bigger_inscription_num},
            );
            const result = try new_stones.getOrPut(bigger_inscription);
            if (result.found_existing) {
                result.value_ptr.* += multiplicity;
            } else {
                result.value_ptr.* = multiplicity;
            }
        }
    }

    stones.* = new_stones;
}

fn count_stones(stones: *Stones) u64 {
    var sum: u64 = 0;

    var iter = stones.iterator();
    while (iter.next()) |e| {
        sum += e.value_ptr.*;
    }

    return sum;
}

fn ingest_input(input: []const u8, allocator: std.mem.Allocator) !Stones {
    var stones_sequence = std.mem.splitSequence(u8, input, " ");
    var stones = Stones.init(allocator);
    while (stones_sequence.next()) |s| {
        const result = try stones.getOrPut(s);
        if (result.found_existing) {
            result.value_ptr.* += 1;
        } else {
            result.value_ptr.* = 1;
        }
    }

    return stones;
}

fn pretty_print(stones: *Stones) !void {
    var iterator = stones.iterator();
    while (iterator.next()) |e| {
        std.debug.print("{s}: {d}\n", .{ e.key_ptr.*, e.value_ptr.* });
    }
}
