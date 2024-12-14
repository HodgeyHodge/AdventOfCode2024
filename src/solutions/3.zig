const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var total: u64 = 0;
    var split = std.mem.split(u8, input, "\n");
    while (split.next()) |line| {
        for (0..line.len) |i| {
            if (line[i] != 'm' or line[i + 1] != 'u' or line[i + 2] != 'l' or line[i + 3] != '(') continue;

            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] == ',' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 5], 10) * try std.fmt.parseInt(u32, line[i + 6 .. i + 7], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] == ',' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 5], 10) * try std.fmt.parseInt(u32, line[i + 6 .. i + 8], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] == ',' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 5], 10) * try std.fmt.parseInt(u32, line[i + 6 .. i + 9], 10);

            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] == ',' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 6], 10) * try std.fmt.parseInt(u32, line[i + 7 .. i + 8], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] == ',' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 6], 10) * try std.fmt.parseInt(u32, line[i + 7 .. i + 9], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] == ',' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] >= '0' and line[i + 9] <= '9' and line[i + 10] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 6], 10) * try std.fmt.parseInt(u32, line[i + 7 .. i + 10], 10);

            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ',' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 7], 10) * try std.fmt.parseInt(u32, line[i + 8 .. i + 9], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ',' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] >= '0' and line[i + 9] <= '9' and line[i + 10] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 7], 10) * try std.fmt.parseInt(u32, line[i + 8 .. i + 10], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ',' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] >= '0' and line[i + 9] <= '9' and line[i + 10] >= '0' and line[i + 10] <= '9' and line[i + 11] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 7], 10) * try std.fmt.parseInt(u32, line[i + 8 .. i + 11], 10);
        }
    }

    return total;
}

pub fn solve_2(input: []const u8) !u64 {
    var total: u64 = 0;
    var on: bool = true;
    var split = std.mem.split(u8, input, "\n");
    while (split.next()) |line| {
        for (0..line.len) |i| {
            if (line[i] == 'd' and line[i + 1] == 'o' and line[i + 2] == '(' and line[i + 3] == ')') on = true;
            if (line[i] == 'd' and line[i + 1] == 'o' and line[i + 2] == 'n' and line[i + 3] == '\'' and line[i + 4] == 't' and line[i + 5] == '(' and line[i + 6] == ')') on = false;

            if (on == false) continue;

            if (line[i] != 'm' or line[i + 1] != 'u' or line[i + 2] != 'l' or line[i + 3] != '(') continue;

            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] == ',' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 5], 10) * try std.fmt.parseInt(u32, line[i + 6 .. i + 7], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] == ',' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 5], 10) * try std.fmt.parseInt(u32, line[i + 6 .. i + 8], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] == ',' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 5], 10) * try std.fmt.parseInt(u32, line[i + 6 .. i + 9], 10);

            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] == ',' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 6], 10) * try std.fmt.parseInt(u32, line[i + 7 .. i + 8], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] == ',' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 6], 10) * try std.fmt.parseInt(u32, line[i + 7 .. i + 9], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] == ',' and line[i + 7] >= '0' and line[i + 7] <= '9' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] >= '0' and line[i + 9] <= '9' and line[i + 10] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 6], 10) * try std.fmt.parseInt(u32, line[i + 7 .. i + 10], 10);

            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ',' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 7], 10) * try std.fmt.parseInt(u32, line[i + 8 .. i + 9], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ',' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] >= '0' and line[i + 9] <= '9' and line[i + 10] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 7], 10) * try std.fmt.parseInt(u32, line[i + 8 .. i + 10], 10);
            if (line[i + 4] >= '0' and line[i + 4] <= '9' and line[i + 5] >= '0' and line[i + 5] <= '9' and line[i + 6] >= '0' and line[i + 6] <= '9' and line[i + 7] == ',' and line[i + 8] >= '0' and line[i + 8] <= '9' and line[i + 9] >= '0' and line[i + 9] <= '9' and line[i + 10] >= '0' and line[i + 10] <= '9' and line[i + 11] == ')') total += try std.fmt.parseInt(u32, line[i + 4 .. i + 7], 10) * try std.fmt.parseInt(u32, line[i + 8 .. i + 11], 10);
        }
    }

    return total;
}
