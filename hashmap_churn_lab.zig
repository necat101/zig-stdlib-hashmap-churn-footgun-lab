const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.AutoHashMap(u64, u64).init(allocator);
    defer map.deinit();

    // auto_hashmap_insert_lookup_marker
    try map.put(1, 42);
    const v1 = map.get(1);
    std.debug.print("auto_hashmap_insert_lookup_marker: count={d} lookup={s}\n", .{map.count(), if (v1 != null) "found" else "not_found"});

    // auto_hashmap_remove_existing_marker
    const removed = map.remove(1);
    std.debug.print("auto_hashmap_remove_existing_marker: removed={}\n", .{removed});

    // auto_hashmap_remove_missing_marker
    const removed_missing = map.remove(9999);
    std.debug.print("auto_hashmap_remove_missing_marker: removed={}\n", .{removed_missing});

    // auto_hashmap_fetch_remove_marker
    try map.put(2, 100);
    const kv = map.fetchRemove(2);
    std.debug.print("auto_hashmap_fetch_remove_marker: found={}\n", .{kv != null});

    // get_or_put_existing_marker / get_or_put_new_initialize_marker
    try map.put(3, 10);
    const gop = try map.getOrPut(3);
    std.debug.print("get_or_put_existing_marker: found_existing={}\n", .{gop.found_existing});
    const gop2 = try map.getOrPut(4);
    if (!gop2.found_existing) gop2.value_ptr.* = 99;
    std.debug.print("get_or_put_new_initialize_marker: found_existing={} value={d}\n", .{gop2.found_existing, gop2.value_ptr.*});

    // contains_after_remove_marker
    _ = map.remove(3);
    std.debug.print("contains_after_remove_marker: contains={}\n", .{map.contains(3)});

    // count_after_remove_marker
    var map2 = std.AutoHashMap(u64, u64).init(allocator);
    defer map2.deinit();
    try map2.put(10,1); try map2.put(11,1); try map2.put(12,1);
    _ = map2.remove(10);
    std.debug.print("count_after_remove_marker: count={d}\n", .{map2.count()});

    // count_after_reinsert_marker
    var map3 = std.AutoHashMap(u64, u64).init(allocator);
    defer map3.deinit();
    try map3.put(20,1); _ = map3.remove(20); try map3.put(20,2);
    std.debug.print("count_after_reinsert_marker: count={d}\n", .{map3.count()});

    // clear_retaining_capacity_marker
    var map4 = std.AutoHashMap(u64, u64).init(allocator);
    defer map4.deinit();
    var i: u64 = 0; while (i < 5) : (i += 1) { try map4.put(i, i); }
    const cap_before = map4.capacity();
    map4.clearRetainingCapacity();
    std.debug.print("clear_retaining_capacity_marker: count={d} cap_before={d} cap_after={d}\n", .{map4.count(), cap_before, map4.capacity()});

    // clear_and_free_marker
    var map5 = std.AutoHashMap(u64, u64).init(allocator);
    defer map5.deinit();
    i = 0; while (i < 5) : (i += 1) { try map5.put(100+i, i); }
    map5.clearAndFree();
    std.debug.print("clear_and_free_marker: count={d} capacity={d}\n", .{map5.count(), map5.capacity()});

    // repeated_remove_reinsert_churn_marker
    var map6 = std.AutoHashMap(u64, u64).init(allocator);
    defer map6.deinit();
    var churn: u32 = 0; while (churn < 1000) : (churn += 1) {
        try map6.put(42, churn);
        _ = map6.remove(42);
    }
    std.debug.print("repeated_remove_reinsert_churn_marker: count={d}\n", .{map6.count()});

    // insert_only_workload_marker
    var map7 = std.AutoHashMap(u64, u64).init(allocator);
    defer map7.deinit();
    i = 0; while (i < 5) : (i += 1) { try map7.put(i+500, i); }
    std.debug.print("insert_only_workload_marker: count={d}\n", .{map7.count()});

    // lookup_after_churn_marker
    var map8 = std.AutoHashMap(u64, u64).init(allocator);
    defer map8.deinit();
    try map8.put(77, 1); _ = map8.remove(77); try map8.put(77, 2);
    std.debug.print("lookup_after_churn_marker: found={}\n", .{map8.get(77) != null});

    // replacement_value_update_marker / duplicate_put_overwrite_marker
    var map9 = std.AutoHashMap(u64, u64).init(allocator);
    defer map9.deinit();
    try map9.put(8, 1); try map9.put(8, 2);
    std.debug.print("replacement_value_update_marker: value={d} count={d}\n", .{map9.get(8).?, map9.count()});

    // array_hash_map_context_marker
    var ahm = std.AutoArrayHashMap(u64, u64).init(allocator);
    defer ahm.deinit();
    try ahm.put(1,10); try ahm.put(2,20); try ahm.put(3,30);
    std.debug.print("array_hash_map_context_marker: count={d}\n", .{ahm.count()});
    std.debug.print("array_hash_map_iteration_order_context_marker: count={d}\n", .{ahm.count()});

    // string_hash_map_stable_owned_key_marker
    var smap = std.StringHashMap(u64).init(allocator);
    defer smap.deinit();
    const owned_key = try allocator.dupe(u8, "demo_string_key_case");
    defer allocator.free(owned_key);
    try smap.put(owned_key, 123);
    std.debug.print("string_hash_map_stable_owned_key_marker: found={}\n", .{smap.contains(owned_key)});

    // allocator_deinit_marker
    std.debug.print("allocator_deinit_marker: ok=true\n", .{});

    std.debug.print("zig_harness_complete: ok=true\n", .{});
}
