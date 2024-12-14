const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    var output: u64 = 0;
    for (data.pages) |page| {
        for (data.rules) |rule| {
            if (!obey(page, rule)) {
                break;
            }
        } else output += page[page.len / 2];
    }

    return output;
}

fn obey(page: []u8, rule: [2]u8) bool {
    const a = find_in_slice(page, rule[0]);
    if (a == null) {
        return true;
    }
    const b = find_in_slice(page, rule[1]);
    if (b == null) {
        return true;
    }
    if (a.? < b.?) {
        return true;
    }
    return false;
}

fn find_in_slice(slice: []const u8, target: u8) ?usize {
    for (slice, 0..) |value, index| {
        if (value == target) {
            return index;
        }
    }
    return null;
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    var output: u64 = 0;
    for (data.pages) |page| {
        for (data.rules) |rule| {
            if (!obey(page, rule)) {
                output += find_middle(page, data.rules);
                break;
            }
        }
    }

    return output;
}

fn find_middle(page: []u8, rules: []const [2]u8) u8 {
    std.mem.sort(u8, page, rules, comptime custom_comparator);
    return page[page.len / 2];
}

fn custom_comparator(rules: []const [2]u8, a: u8, b: u8) bool {
    for (rules) |rule| {
        if (rule[0] == a and rule[1] == b) {
            return false;
        }
    }

    return true;
}

fn ingest_input(input: []const u8, allocator: std.mem.Allocator) !struct {
    rules: []const [2]u8,
    pages: []const []u8,
} {
    var inputIterator = std.mem.splitSequence(u8, input, "\n\n");
    const rules_section = inputIterator.next() orelse unreachable;
    const pages_section = inputIterator.next() orelse unreachable;

    const rules_count = std.mem.count(u8, rules_section, "\n") + 1;
    const rules_output = try allocator.alloc([2]u8, rules_count);
    var rules_iterator = std.mem.splitSequence(u8, rules_section, "\n");
    var i: usize = 0;
    while (rules_iterator.next()) |rule| {
        var rule_split = std.mem.split(u8, rule, "|");
        const rule_first = try std.fmt.parseInt(u8, rule_split.next() orelse unreachable, 10);
        const rule_second = try std.fmt.parseInt(u8, rule_split.next() orelse unreachable, 10);
        rules_output[i] = .{ rule_first, rule_second };
        i += 1;
    }

    const pages_count = std.mem.count(u8, pages_section, "\n") + 1;
    const pages_output = try allocator.alloc([]u8, pages_count);
    var pages_iterator = std.mem.splitSequence(u8, pages_section, "\n");
    i = 0;
    while (pages_iterator.next()) |page| {
        const page_count = std.mem.count(u8, page, ",") + 1;
        const page_output = try allocator.alloc(u8, page_count);
        var page_iterator = std.mem.splitSequence(u8, page, ",");
        var j: usize = 0;
        while (page_iterator.next()) |item| {
            const num = try std.fmt.parseInt(u8, item, 10);
            page_output[j] = num;
            j += 1;
        }

        pages_output[i] = page_output;
        i += 1;
    }

    return .{ .rules = rules_output, .pages = pages_output };
}
