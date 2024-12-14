const std = @import("std");

pub fn solve(args: struct { concatenate: bool }) (fn ([]const u8) anyerror!u64) {
    const CurriedSolver = struct {
        fn solve(input: []const u8) !u64 {
            return inner_solve(input, args.concatenate);
        }
    };
    return CurriedSolver.solve;
}

fn inner_solve(input: []const u8, concatenate: bool) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    var total: u64 = 0;
    for (data) |*thing| {
        while (thing.constituents.len > 0) {
            try thing.reduce(allocator, concatenate);
        }

        if (thing.partials.get(thing.total) != null) {
            total += thing.total;
        }
    }
    return total;
}

fn ingest_input(input: []const u8, allocator: std.mem.Allocator) ![]Equation {
    var input_iterator = std.mem.splitSequence(u8, input, "\n");

    const line_count = std.mem.count(u8, input, "\n") + 1;
    const output = try allocator.alloc(Equation, line_count);

    var i: usize = 0;
    while (input_iterator.next()) |line| {
        output[i] = try Equation.init(line, allocator);
        i += 1;
    }

    return output;
}

const Equation = struct {
    total: u64,
    constituents: []u16,
    partials: std.AutoHashMap(u64, void),

    pub fn init(input: []const u8, allocator: std.mem.Allocator) !Equation {
        var input_split = std.mem.split(u8, input, ": ");
        const total = try std.fmt.parseInt(u64, input_split.next() orelse unreachable, 10);
        const constituents_raw = input_split.next() orelse unreachable;
        const constituents_count = std.mem.count(u8, constituents_raw, " ") + 1;
        var constituents = try allocator.alloc(u16, constituents_count - 1);
        var constituents_iterator = std.mem.splitSequence(u8, constituents_raw, " ");
        const initial_partial = try std.fmt.parseInt(u16, constituents_iterator.next() orelse unreachable, 10);

        var partials = std.AutoHashMap(u64, void).init(allocator);
        try partials.put(initial_partial, {});

        var j: usize = 0;
        while (constituents_iterator.next()) |c| {
            constituents[j] = try std.fmt.parseInt(u16, c, 10);
            j += 1;
        }

        return Equation{
            .total = total,
            .constituents = constituents,
            .partials = partials,
        };
    }

    pub fn reduce(self: *Equation, allocator: std.mem.Allocator, with_concat: bool) !void {
        if (self.constituents.len == 0) return;

        const operand = self.constituents[0];
        self.constituents = self.constituents[1..];

        const total_power = count_digits_u64(self.total);
        const operand_power = count_digits_u16(operand);
        const constituent_power = sum_digit_counts(self.constituents);

        var new_partials = std.AutoHashMap(u64, void).init(allocator);

        var partial_iterator = self.partials.iterator();
        while (partial_iterator.next()) |p| {
            const p_value = p.key_ptr.*;
            const p_power = count_digits_u64(p_value);

            if (p_power + constituent_power + operand_power < total_power) {
                continue;
            }
            if (p_value > self.total) {
                continue;
            }

            try new_partials.put(p_value + operand, {});
            try new_partials.put(p_value * operand, {});
            if (with_concat) {
                try new_partials.put(concat(p_value, operand), {});
            }
        }

        self.partials = new_partials;
    }

    pub fn pretty_print(self: *Equation) void {
        std.debug.print("  Equation:\n", .{});
        std.debug.print("    Total: {d}\n", .{self.total});
        std.debug.print("    Constituents: {any}\n", .{self.constituents});
        var iter_after = self.partials.iterator();
        std.debug.print("    Partials:\n", .{});
        while (iter_after.next()) |x| {
            std.debug.print("      * {d}\n", .{x.key_ptr.*});
        }
    }
};

pub fn count_digits_u64(value: u64) u8 {
    var count: u8 = 0;
    var n = value;
    while (n > 0) {
        n /= 10;
        count += 1;
    }
    return count;
}

pub fn count_digits_u16(value: u16) u8 {
    var count: u8 = 0;
    var n = value;
    while (n > 0) {
        n /= 10;
        count += 1;
    }
    return count;
}

pub fn sum_digit_counts(slice: []u16) u8 {
    var total: u8 = 0;
    for (slice) |num| {
        total += count_digits_u16(num);
    }
    return total;
}

fn concat(a: u64, b: u16) u64 {
    var multiplier: u64 = 1;
    var temp: u16 = b;

    while (temp > 0) : (temp /= 10) {
        multiplier *= 10;
    }

    return a * multiplier + b;
}
