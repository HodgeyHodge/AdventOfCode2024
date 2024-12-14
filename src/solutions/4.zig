const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    const H = data.len;
    const W = data[0].len;

    var hits: u64 = 0;

    //E
    for (0..H) |i| {
        for (0..W - 3) |j| {
            if (data[i][j] == 'X' and data[i][j + 1] == 'M' and data[i][j + 2] == 'A' and data[i][j + 3] == 'S') {
                hits += 1;
            } else if (data[i][j] == 'S' and data[i][j + 1] == 'A' and data[i][j + 2] == 'M' and data[i][j + 3] == 'X') {
                hits += 1;
            }
        }
    }

    //S
    for (0..H - 3) |i| {
        for (0..W) |j| {
            if (data[i][j] == 'X' and data[i + 1][j] == 'M' and data[i + 2][j] == 'A' and data[i + 3][j] == 'S') {
                hits += 1;
            } else if (data[i][j] == 'S' and data[i + 1][j] == 'A' and data[i + 2][j] == 'M' and data[i + 3][j] == 'X') {
                hits += 1;
            }
        }
    }

    //SE
    for (0..H - 3) |i| {
        for (0..W - 3) |j| {
            if (data[i][j] == 'X' and data[i + 1][j + 1] == 'M' and data[i + 2][j + 2] == 'A' and data[i + 3][j + 3] == 'S') {
                hits += 1;
            } else if (data[i][j] == 'S' and data[i + 1][j + 1] == 'A' and data[i + 2][j + 2] == 'M' and data[i + 3][j + 3] == 'X') {
                hits += 1;
            }
        }
    }

    //NE
    for (3..H) |i| {
        for (0..W - 3) |j| {
            if (data[i][j] == 'X' and data[i - 1][j + 1] == 'M' and data[i - 2][j + 2] == 'A' and data[i - 3][j + 3] == 'S') {
                hits += 1;
            } else if (data[i][j] == 'S' and data[i - 1][j + 1] == 'A' and data[i - 2][j + 2] == 'M' and data[i - 3][j + 3] == 'X') {
                hits += 1;
            }
        }
    }

    return hits;
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    const H = data.len;
    const W = data[0].len;

    var hits: u16 = 0;

    for (1..H - 1) |i| {
        for (1..W - 1) |j| {
            if (data[i][j] == 'A') {
                if ((data[i - 1][j - 1] == 'M' and data[i + 1][j + 1] == 'S') or (data[i - 1][j - 1] == 'S' and data[i + 1][j + 1] == 'M')) {
                    if ((data[i - 1][j + 1] == 'M' and data[i + 1][j - 1] == 'S') or (data[i - 1][j + 1] == 'S' and data[i + 1][j - 1] == 'M')) {
                        hits += 1;
                    }
                }
            }
        }
    }

    return hits;
}

fn ingest_input(input: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    const line_count = std.mem.count(u8, input, "\n") + 1;
    const output = try allocator.alloc([]const u8, line_count);

    var lines = std.mem.splitSequence(u8, input, "\n");
    var i: usize = 0;
    while (lines.next()) |line| {
        output[i] = line;
        i += 1;
    }

    return output;
}
