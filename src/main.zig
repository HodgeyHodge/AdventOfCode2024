const std = @import("std");

const day1 = @import("solutions/1.zig");
const day2 = @import("solutions/2.zig");
const day3 = @import("solutions/3.zig");
const day4 = @import("solutions/4.zig");
const day5 = @import("solutions/5.zig");
const day6 = @import("solutions/6.zig");
const day7 = @import("solutions/7.zig");
const day8 = @import("solutions/8.zig");
const day9 = @import("solutions/9.zig");
const day10 = @import("solutions/10.zig");
const day11 = @import("solutions/11.zig");
const day12 = @import("solutions/12.zig");

const Solver = fn (input: []const u8) anyerror!u64;

const Run = struct {
    day: u8,
    part: u8,
    solver: *const Solver,
    expected: ?u64,
    input: []const u8,
};

fn pretty_input_preview(input: []const u8) [25]u8 {
    var string = [_]u8{' '} ** 25;
    var i: usize = 0;
    for (input) |c| {
        if (c == '\n') continue;
        if (i == 25) {
            string[21] = ' ';
            string[22] = '.';
            string[23] = '.';
            string[24] = '.';
            return string;
        }
        string[i] = c;
        i += 1;
    } else {
        return string;
    }
}

fn solve(run: Run) !void {
    const pretty_input = pretty_input_preview(run.input);
    var t = try std.time.Timer.start();
    const output = try run.solver(run.input);
    const time_elapsed = t.read();

    if (run.expected == null) {
        std.debug.print("Day {d} part {d}: running for input {s}\n", .{ run.day, run.part, pretty_input });
        std.debug.print("Result:\n    {d}\n", .{output});
        std.debug.print("Time elapsed: {}\n\n", .{std.fmt.fmtDuration(time_elapsed)});
    } else {
        std.debug.print("Day {d}, part {d}: testing input {s}\nExpecting {d}...", .{ run.day, run.part, pretty_input, run.expected.? });
        try std.testing.expectEqual(run.expected, try run.solver(run.input));
        std.debug.print(" OK!\n", .{});
        std.debug.print("Time elapsed: {}\n\n", .{std.fmt.fmtDuration(time_elapsed)});
    }
}

pub fn main() !void {
    const runs = &[_]Run{
        Run{ .day = 1, .part = 1, .solver = day1.solve_1, .expected = 11, .input = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3" },
        Run{ .day = 1, .part = 1, .solver = day1.solve_1, .expected = 1646452, .input = @embedFile("inputs/1.txt") },
        Run{ .day = 1, .part = 2, .solver = day1.solve_2, .expected = 31, .input = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3" },
        Run{ .day = 1, .part = 2, .solver = day1.solve_2, .expected = 23609874, .input = @embedFile("inputs/1.txt") },

        Run{ .day = 2, .part = 1, .solver = day2.solve_1, .expected = 2, .input = "7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9" },
        Run{ .day = 2, .part = 1, .solver = day2.solve_1, .expected = 402, .input = @embedFile("inputs/2.txt") },
        Run{ .day = 2, .part = 2, .solver = day2.solve_2, .expected = 4, .input = "7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9" },
        Run{ .day = 2, .part = 2, .solver = day2.solve_2, .expected = 455, .input = @embedFile("inputs/2.txt") },

        Run{ .day = 3, .part = 1, .solver = day3.solve_1, .expected = 161, .input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))" },
        Run{ .day = 3, .part = 1, .solver = day3.solve_1, .expected = 184511516, .input = @embedFile("inputs/3.txt") },
        Run{ .day = 3, .part = 2, .solver = day3.solve_2, .expected = 48, .input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))" },
        Run{ .day = 3, .part = 2, .solver = day3.solve_2, .expected = 90044227, .input = @embedFile("inputs/3.txt") },

        Run{ .day = 4, .part = 1, .solver = day4.solve_1, .expected = 18, .input = "MMMSXXMASM\nMSAMXMSMSA\nAMXSXMAAMM\nMSAMASMSMX\nXMASAMXAMM\nXXAMMXXAMA\nSMSMSASXSS\nSAXAMASAAA\nMAMMMXMMMM\nMXMXAXMASX" },
        Run{ .day = 4, .part = 1, .solver = day4.solve_1, .expected = 2560, .input = @embedFile("inputs/4.txt") },
        Run{ .day = 4, .part = 2, .solver = day4.solve_2, .expected = 9, .input = "MMMSXXMASM\nMSAMXMSMSA\nAMXSXMAAMM\nMSAMASMSMX\nXMASAMXAMM\nXXAMMXXAMA\nSMSMSASXSS\nSAXAMASAAA\nMAMMMXMMMM\nMXMXAXMASX" },
        Run{ .day = 4, .part = 2, .solver = day4.solve_2, .expected = 1910, .input = @embedFile("inputs/4.txt") },

        Run{ .day = 5, .part = 1, .solver = day5.solve_1, .expected = 143, .input = "47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53\n61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13\n\n75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47" },
        Run{ .day = 5, .part = 1, .solver = day5.solve_1, .expected = 5275, .input = @embedFile("inputs/5.txt") },
        Run{ .day = 5, .part = 2, .solver = day5.solve_2, .expected = 123, .input = "47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53\n61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13\n\n75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47" },
        Run{ .day = 5, .part = 2, .solver = day5.solve_2, .expected = 6191, .input = @embedFile("inputs/5.txt") },

        Run{ .day = 6, .part = 1, .solver = day6.solve_1, .expected = 41, .input = "....#.....\n.........#\n..........\n..#.......\n.......#..\n..........\n.#..^.....\n........#.\n#.........\n......#..." },
        Run{ .day = 6, .part = 1, .solver = day6.solve_1, .expected = 4752, .input = @embedFile("inputs/6.txt") },
        Run{ .day = 6, .part = 2, .solver = day6.solve_2, .expected = 6, .input = "....#.....\n.........#\n..........\n..#.......\n.......#..\n..........\n.#..^.....\n........#.\n#.........\n......#..." },
        //Run{ .day = 6, .part = 2, .solver = day6.solve_2, .expected = 1719, .input = @embedFile("inputs/6.txt") },

        Run{ .day = 7, .part = 1, .solver = day7.solve(.{ .concatenate = false }), .expected = 3749, .input = "190: 10 19\n3267: 81 40 27\n83: 17 5\n156: 15 6\n7290: 6 8 6 15\n161011: 16 10 13\n192: 17 8 14\n21037: 9 7 18 13\n292: 11 6 16 20" },
        Run{ .day = 7, .part = 1, .solver = day7.solve(.{ .concatenate = false }), .expected = 1985268524462, .input = @embedFile("inputs/7.txt") },
        Run{ .day = 7, .part = 2, .solver = day7.solve(.{ .concatenate = true }), .expected = 11387, .input = "190: 10 19\n3267: 81 40 27\n83: 17 5\n156: 15 6\n7290: 6 8 6 15\n161011: 16 10 13\n192: 17 8 14\n21037: 9 7 18 13\n292: 11 6 16 20" },
        //Run{ .day = 7, .part = 2, .solver = day7.solve(.{ .concatenate = true }), .expected = 150077710195188, .input = @embedFile("inputs/7.txt") },

        Run{ .day = 8, .part = 1, .solver = day8.solve_1, .expected = 14, .input = "............\n........0...\n.....0......\n.......0....\n....0.......\n......A.....\n............\n............\n........A...\n.........A..\n............\n............" },
        Run{ .day = 8, .part = 1, .solver = day8.solve_1, .expected = 254, .input = @embedFile("inputs/8.txt") },
        Run{ .day = 8, .part = 2, .solver = day8.solve_2, .expected = 34, .input = "............\n........0...\n.....0......\n.......0....\n....0.......\n......A.....\n............\n............\n........A...\n.........A..\n............\n............" },
        Run{ .day = 8, .part = 2, .solver = day8.solve_2, .expected = 951, .input = @embedFile("inputs/8.txt") },

        Run{ .day = 9, .part = 1, .solver = day9.solve_1, .expected = 1928, .input = "2333133121414131402" },
        Run{ .day = 9, .part = 1, .solver = day9.solve_1, .expected = 6398252054886, .input = @embedFile("inputs/9.txt") },
        Run{ .day = 9, .part = 2, .solver = day9.solve_2, .expected = 2858, .input = "2333133121414131402" },
        Run{ .day = 9, .part = 2, .solver = day9.solve_2, .expected = 6415666220005, .input = @embedFile("inputs/9.txt") },

        Run{ .day = 10, .part = 1, .solver = day10.solve_1, .expected = 36, .input = "89010123\n78121874\n87430965\n96549874\n45678903\n32019012\n01329801\n10456732" },
        Run{ .day = 10, .part = 1, .solver = day10.solve_1, .expected = 489, .input = @embedFile("inputs/10.txt") },
        Run{ .day = 10, .part = 2, .solver = day10.solve_2, .expected = 81, .input = "89010123\n78121874\n87430965\n96549874\n45678903\n32019012\n01329801\n10456732" },
        Run{ .day = 10, .part = 2, .solver = day10.solve_2, .expected = 1086, .input = @embedFile("inputs/10.txt") },

        Run{ .day = 11, .part = 1, .solver = day11.solve(.{ .iterations = 6 }), .expected = 22, .input = "125 17" },
        Run{ .day = 11, .part = 1, .solver = day11.solve(.{ .iterations = 25 }), .expected = 55312, .input = "125 17" },
        Run{ .day = 11, .part = 2, .solver = day11.solve(.{ .iterations = 25 }), .expected = 194557, .input = "8793800 1629 65 5 960 0 138983 85629" },
        Run{ .day = 11, .part = 2, .solver = day11.solve(.{ .iterations = 75 }), .expected = 231532558973909, .input = "8793800 1629 65 5 960 0 138983 85629" },

        Run{ .day = 12, .part = 1, .solver = day12.solve(.{ .discount = false }), .expected = 140, .input = "AAAA\nBBCD\nBBCC\nEEEC" },
        Run{ .day = 12, .part = 1, .solver = day12.solve(.{ .discount = false }), .expected = 772, .input = "OOOOO\nOXOXO\nOOOOO\nOXOXO\nOOOOO" },
        Run{ .day = 12, .part = 1, .solver = day12.solve(.{ .discount = false }), .expected = 1930, .input = "RRRRIICCFF\nRRRRIICCCF\nVVRRRCCFFF\nVVRCCCJFFF\nVVVVCJJCFE\nVVIVCCJJEE\nVVIIICJJEE\nMIIIIIJJEE\nMIIISIJEEE\nMMMISSJEEE" },
        Run{ .day = 12, .part = 1, .solver = day12.solve(.{ .discount = false }), .expected = 1457298, .input = @embedFile("inputs/12.txt") },
        Run{ .day = 12, .part = 2, .solver = day12.solve(.{ .discount = true }), .expected = 80, .input = "AAAA\nBBCD\nBBCC\nEEEC" },
        Run{ .day = 12, .part = 2, .solver = day12.solve(.{ .discount = true }), .expected = 436, .input = "OOOOO\nOXOXO\nOOOOO\nOXOXO\nOOOOO" },
        Run{ .day = 12, .part = 2, .solver = day12.solve(.{ .discount = true }), .expected = 236, .input = "EEEEE\nEXXXX\nEEEEE\nEXXXX\nEEEEE" },
        Run{ .day = 12, .part = 2, .solver = day12.solve(.{ .discount = true }), .expected = 368, .input = "AAAAAA\nAAABBA\nAAABBA\nABBAAA\nABBAAA\nAAAAAA" },
        Run{ .day = 12, .part = 2, .solver = day12.solve(.{ .discount = true }), .expected = 1206, .input = "RRRRIICCFF\nRRRRIICCCF\nVVRRRCCFFF\nVVRCCCJFFF\nVVVVCJJCFE\nVVIVCCJJEE\nVVIIICJJEE\nMIIIIIJJEE\nMIIISIJEEE\nMMMISSJEEE" },
        Run{ .day = 12, .part = 2, .solver = day12.solve(.{ .discount = true }), .expected = 921636, .input = @embedFile("inputs/12.txt") },
    };

    if (std.os.argv.len == 2) {
        const arg: ?u8 = std.fmt.parseInt(u8, std.mem.span(std.os.argv[1]), 10) catch null;
        for (runs) |run| {
            if ((arg != null and run.day == arg.?) or arg == null) {
                try solve(run);
            }
        }
    } else {
        for (runs) |run| {
            try solve(run);
        }
    }
}
