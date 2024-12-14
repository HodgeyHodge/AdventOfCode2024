const std = @import("std");

const File = struct { id: u32, run: u32, headroom: u32 };
const Disk = std.DoublyLinkedList(File);

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try ingest_input(input, allocator);

    try compress(&data, allocator);

    return checksum(&data);
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try ingest_input(input, allocator);

    try respectful_compress(&data);

    return checksum(&data);
}

fn ingest_input(input: []const u8, allocator: std.mem.Allocator) !Disk {
    var list = Disk{};

    for (0..input.len / 2) |i| {
        const file = File{
            .id = @as(u32, @intCast(i)),
            .run = @as(u32, input[2 * i] - '0'),
            .headroom = @as(u32, input[2 * i + 1] - '0'),
        };
        var node = try allocator.create(Disk.Node);
        node.data = file;
        list.append(node);
    } else {
        const file = File{
            .id = @as(u32, @intCast(input.len / 2)),
            .run = @as(u32, input[input.len - 1] - '0'),
            .headroom = 0,
        };
        var node = try allocator.create(Disk.Node);
        node.data = file;
        list.append(node);
    }

    return list;
}

fn pretty_print(list: Disk) !void {
    std.debug.print("printing the whole list:\n", .{});
    var iterand = list.first;
    while (iterand) |node| : (iterand = node.next) {
        std.debug.print("{}\n", .{node.data});
    }
}

fn respectful_compress(list: *Disk) !void {
    var moving_iterand = list.last;
    while (moving_iterand) |moving_node| {
        var roomy_iterand = list.first;
        while (roomy_iterand) |roomy_node| : (roomy_iterand = roomy_node.next) {
            if (roomy_node == moving_node) {
                moving_iterand = moving_node.prev;
                break;
            }
            if (roomy_node.data.headroom >= moving_node.data.run) {
                const previous_node = moving_node.prev orelse unreachable;

                if (previous_node == roomy_node) {
                    moving_node.data.headroom += roomy_node.data.headroom;
                    roomy_node.data.headroom = 0;
                } else {
                    list.remove(moving_node);
                    previous_node.data.headroom += moving_node.data.run + moving_node.data.headroom;
                    moving_node.data.headroom = roomy_node.data.headroom - moving_node.data.run;
                    roomy_node.data.headroom = 0;
                    list.insertAfter(roomy_node, moving_node);
                }

                moving_iterand = previous_node;
                break;
            }
        }
    }
}

fn compress(list: *Disk, allocator: std.mem.Allocator) !void {
    var roomy_iterand = list.first;
    while (roomy_iterand) |roomy_node| : (roomy_iterand = roomy_node.next) {
        if (roomy_node.data.headroom == 0) continue;

        var last_file = list.last orelse unreachable;
        if (last_file == roomy_node) break;

        var node = try allocator.create(Disk.Node);
        if (roomy_node.data.headroom < last_file.data.run) {
            last_file.data.run -= roomy_node.data.headroom;
            node.data = File{ .id = last_file.data.id, .run = roomy_node.data.headroom, .headroom = 0 };
        } else {
            node.data = File{ .id = last_file.data.id, .run = last_file.data.run, .headroom = roomy_node.data.headroom - last_file.data.run };
            _ = list.pop() orelse unreachable;
        }
        list.insertAfter(roomy_node, node);
        roomy_node.data.headroom = 0;
    }
}

fn checksum(list: *Disk) !u64 {
    var iterand = list.first;
    var total: u64 = 0;
    var index: u64 = 0;
    while (iterand) |node| : (iterand = node.next) {
        const f = iterand.?.data;
        total += (index * f.run + (f.run - 1) * f.run / 2) * f.id;
        index += f.run + f.headroom;
    }

    return total;
}
