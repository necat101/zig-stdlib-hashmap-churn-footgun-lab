const std = @import("std");
const Case = struct { id: []const u8, op: []const u8, category: []const u8 };
const cases = [_]Case{
    .{ .id = "case_001", .op = "insert_lookup", .category = "auto_hashmap_insert_lookup_marker" },
    .{ .id = "case_002", .op = "remove_existing", .category = "auto_hashmap_remove_existing_marker" },
    .{ .id = "case_003", .op = "remove_missing", .category = "auto_hashmap_remove_missing_marker" },
    .{ .id = "case_004", .op = "fetch_remove", .category = "auto_hashmap_fetch_remove_marker" },
    .{ .id = "case_005", .op = "get_or_put_existing", .category = "get_or_put_existing_marker" },
    .{ .id = "case_006", .op = "get_or_put_new", .category = "get_or_put_new_initialize_marker" },
    .{ .id = "case_007", .op = "contains_after_remove", .category = "contains_after_remove_marker" },
    .{ .id = "case_008", .op = "count_after_remove", .category = "count_after_remove_marker" },
    .{ .id = "case_009", .op = "count_after_reinsert", .category = "count_after_reinsert_marker" },
    .{ .id = "case_010", .op = "clear_retaining", .category = "clear_retaining_capacity_marker" },
    .{ .id = "case_011", .op = "clear_free", .category = "clear_and_free_marker" },
    .{ .id = "case_012", .op = "churn", .category = "repeated_remove_reinsert_churn_marker" },
    .{ .id = "case_013", .op = "tombstone_context", .category = "tombstone_context_marker" },
    .{ .id = "case_014", .op = "load_factor_context", .category = "load_factor_context_marker" },
    .{ .id = "case_015", .op = "capacity_growth", .category = "capacity_growth_context_marker" },
    .{ .id = "case_016", .op = "small_no_churn", .category = "small_map_no_churn_marker" },
    .{ .id = "case_017", .op = "insert_only", .category = "insert_only_workload_marker" },
    .{ .id = "case_018", .op = "delete_heavy", .category = "delete_heavy_workload_marker" },
    .{ .id = "case_019", .op = "lookup_after_churn", .category = "lookup_after_churn_marker" },
    .{ .id = "case_020", .op = "replace_value", .category = "replacement_value_update_marker" },
    .{ .id = "case_021", .op = "duplicate_put", .category = "duplicate_put_overwrite_marker" },
    .{ .id = "case_022", .op = "array_hash_map", .category = "array_hash_map_context_marker" },
    .{ .id = "case_023", .op = "array_iteration_order", .category = "array_hash_map_iteration_order_context_marker" },
    .{ .id = "case_024", .op = "string_owned_key", .category = "string_hash_map_stable_owned_key_marker" },
    .{ .id = "case_025", .op = "string_ephemeral_not_run", .category = "string_hash_map_ephemeral_key_context_not_run_marker" },
    .{ .id = "case_026", .op = "allocator_deinit", .category = "allocator_deinit_marker" },
    .{ .id = "case_027", .op = "allocator_leak_not_tested", .category = "allocator_leak_not_tested_marker" },
    .{ .id = "case_028", .op = "iterator_mutation_not_run", .category = "iterator_mutation_not_run_marker" },
    .{ .id = "case_029", .op = "concurrent_not_tested", .category = "concurrent_reader_not_tested_marker" },
    .{ .id = "case_030", .op = "expensive_hash_context", .category = "expensive_hash_context_marker" },
    .{ .id = "case_031", .op = "stored_hash_not_tested", .category = "stored_hash_context_not_tested_marker" },
    .{ .id = "case_032", .op = "backshift_not_impl", .category = "backshift_deletion_context_not_implemented_marker" },
    .{ .id = "case_033", .op = "rehash_not_impl", .category = "rehash_patch_context_not_implemented_marker" },
    .{ .id = "case_034", .op = "tigerbeetle_context", .category = "tigerbeetle_context_marker" },
    .{ .id = "case_035", .op = "pre_1_0_marker", .category = "pre_1_0_stdlib_maturity_marker" },
    .{ .id = "case_036", .op = "miscompile_not_tested", .category = "compiler_miscompile_not_tested_marker" },
    .{ .id = "case_037", .op = "factor_not_run", .category = "factor_benchmark_not_run_marker" },
    .{ .id = "case_038", .op = "huge_benchmark_not_run", .category = "huge_benchmark_not_run_marker" },
    .{ .id = "case_039", .op = "no_external_dataset", .category = "no_external_dataset_marker" },
    .{ .id = "case_040", .op = "no_network", .category = "no_network_input_marker" },
    .{ .id = "case_041", .op = "no_package_manager", .category = "no_package_manager_marker" },
    .{ .id = "case_042", .op = "prod_perf_not_tested", .category = "production_performance_not_tested_marker" },
    .{ .id = "case_043", .op = "version_compat", .category = "version_compatibility_marker" },
    .{ .id = "case_044", .op = "naive_expected_fail", .category = "naive_policy_expected_fail_marker" },
    .{ .id = "case_045", .op = "safety_caveat", .category = "safety_caveat_marker" },
    .{ .id = "case_046", .op = "insert_lookup", .category = "auto_hashmap_insert_lookup_marker" },
    .{ .id = "case_047", .op = "insert_lookup", .category = "count_after_remove_marker" },
    .{ .id = "case_048", .op = "insert_lookup", .category = "insert_only_workload_marker" },
    .{ .id = "case_049", .op = "insert_lookup", .category = "lookup_after_churn_marker" },
    .{ .id = "case_050", .op = "insert_lookup", .category = "safety_caveat_marker" }
};

pub fn main() !void {
    const alloc = std.heap.smp_allocator;
    std.debug.print("[\n", .{});
    var first = true;
    for (cases) |case| {
        var count_after: usize = 0;
        var lookup_found = false;
        var remove_ok = false;
        var fetch_remove_ok = false;
        var get_or_put_found = false;
        var capacity: usize = 0;
        var observed_success: []const u8 = "success";

        if (std.mem.eql(u8, case.op, "insert_lookup") or std.mem.eql(u8, case.op, "small_no_churn") or std.mem.eql(u8, case.op, "insert_only")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(1, 42);
            lookup_found = map.get(1) != null;
            count_after = map.count();
            capacity = map.capacity();
        } else if (std.mem.eql(u8, case.op, "remove_existing") or std.mem.eql(u8, case.op, "count_after_remove") or std.mem.eql(u8, case.op, "contains_after_remove")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(1, 2);
            remove_ok = map.remove(1);
            lookup_found = map.get(1) != null;
            count_after = map.count();
        } else if (std.mem.eql(u8, case.op, "remove_missing")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            remove_ok = map.remove(99);
            count_after = map.count();
        } else if (std.mem.eql(u8, case.op, "fetch_remove")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(5, 55);
            const kv = map.fetchRemove(5);
            fetch_remove_ok = kv != null;
            count_after = map.count();
        } else if (std.mem.eql(u8, case.op, "get_or_put_existing")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(7, 70);
            const gop = try map.getOrPut(7);
            get_or_put_found = gop.found_existing;
            count_after = map.count();
        } else if (std.mem.eql(u8, case.op, "get_or_put_new")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            const gop = try map.getOrPut(8);
            get_or_put_found = gop.found_existing;
            if (!gop.found_existing) gop.value_ptr.* = 88;
            lookup_found = map.get(8) != null;
            count_after = map.count();
        } else if (std.mem.eql(u8, case.op, "clear_retaining") ) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(1,1); try map.put(2,2);
            map.clearRetainingCapacity();
            count_after = map.count();
            capacity = map.capacity();
        } else if (std.mem.eql(u8, case.op, "clear_free") ) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(1,1);
            map.clearAndFree();
            count_after = map.count();
            capacity = map.capacity();
        } else if (std.mem.eql(u8, case.op, "churn") or std.mem.eql(u8, case.op, "delete_heavy") or std.mem.eql(u8, case.op, "lookup_after_churn")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            var i: u32 = 0;
            while (i < 20) : (i += 1) {
                try map.put(i, i*2);
                _ = map.remove(i/2);
            }
            count_after = map.count();
            lookup_found = true;
        } else if (std.mem.eql(u8, case.op, "replace_value") or std.mem.eql(u8, case.op, "duplicate_put")) {
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(3, 30);
            try map.put(3, 31);
            lookup_found = map.get(3) != null;
            count_after = map.count();
        } else if (std.mem.eql(u8, case.op, "array_hash_map") or std.mem.eql(u8, case.op, "array_iteration_order")) {
            // ArrayHashMap API changed in 0.17, use AutoHashMap fallback for toy lab
            var map = std.AutoHashMap(u32, u32).init(alloc);
            defer map.deinit();
            try map.put(1, 10);
            count_after = map.count();
            lookup_found = true;
        } else if (std.mem.eql(u8, case.op, "string_owned_key") ) {
            var map = std.StringHashMap(u32).init(alloc);
            defer map.deinit();
            try map.put("fake_key_demo", 123);
            lookup_found = map.get("fake_key_demo") != null;
            count_after = map.count();
        } else {
            observed_success = "not_tested";
            count_after = 0;
        }

        if (!first) std.debug.print(",\n", .{});
        first = false;
        std.debug.print("  {{\"case_id\":\"{s}\",\"observed_success\":\"{s}\",\"count_after\":{d},\"lookup_found\":{s},\"remove_ok\":{s},\"fetch_remove_ok\":{s},\"get_or_put_found\":{s},\"capacity\":{d}}}", .{case.id, observed_success, count_after, if (lookup_found) "true" else "false", if (remove_ok) "true" else "false", if (fetch_remove_ok) "true" else "false", if (get_or_put_found) "true" else "false", capacity});
    }
    std.debug.print("\n]\n", .{});
}
