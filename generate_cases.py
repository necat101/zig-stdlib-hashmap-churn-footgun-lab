#!/usr/bin/env python3
"""Generate deterministic synthetic hashmap churn cases."""
import json, random
random.seed(42)

cases = [
    # (id, category, operation)
    ("case_001", "auto_hashmap_insert_lookup_marker", "insert_lookup"),
    ("case_002", "auto_hashmap_remove_existing_marker", "remove_existing"),
    ("case_003", "auto_hashmap_remove_missing_marker", "remove_missing"),
    ("case_004", "auto_hashmap_fetch_remove_marker", "fetch_remove"),
    ("case_005", "get_or_put_existing_marker", "get_or_put_existing"),
    ("case_006", "get_or_put_new_initialize_marker", "get_or_put_new"),
    ("case_007", "contains_after_remove_marker", "contains_after_remove"),
    ("case_008", "count_after_remove_marker", "count_after_remove"),
    ("case_009", "count_after_reinsert_marker", "count_after_reinsert"),
    ("case_010", "clear_retaining_capacity_marker", "clear_retaining"),
    ("case_011", "clear_and_free_marker", "clear_free"),
    ("case_012", "repeated_remove_reinsert_churn_marker", "churn"),
    ("case_013", "tombstone_context_marker", "tombstone_context"),
    ("case_014", "load_factor_context_marker", "load_factor_context"),
    ("case_015", "capacity_growth_context_marker", "capacity_growth"),
    ("case_016", "small_map_no_churn_marker", "small_no_churn"),
    ("case_017", "insert_only_workload_marker", "insert_only"),
    ("case_018", "delete_heavy_workload_marker", "delete_heavy"),
    ("case_019", "lookup_after_churn_marker", "lookup_after_churn"),
    ("case_020", "replacement_value_update_marker", "replace_value"),
    ("case_021", "duplicate_put_overwrite_marker", "duplicate_put"),
    ("case_022", "array_hash_map_context_marker", "array_hash_map"),
    ("case_023", "array_hash_map_iteration_order_context_marker", "array_iteration_order"),
    ("case_024", "string_hash_map_stable_owned_key_marker", "string_owned_key"),
    ("case_025", "string_hash_map_ephemeral_key_context_not_run_marker", "string_ephemeral_not_run"),
    ("case_026", "allocator_deinit_marker", "allocator_deinit"),
    ("case_027", "allocator_leak_not_tested_marker", "allocator_leak_not_tested"),
    ("case_028", "iterator_mutation_not_run_marker", "iterator_mutation_not_run"),
    ("case_029", "concurrent_reader_not_tested_marker", "concurrent_not_tested"),
    ("case_030", "expensive_hash_context_marker", "expensive_hash_context"),
    ("case_031", "stored_hash_context_not_tested_marker", "stored_hash_not_tested"),
    ("case_032", "backshift_deletion_context_not_implemented_marker", "backshift_not_impl"),
    ("case_033", "rehash_patch_context_not_implemented_marker", "rehash_not_impl"),
    ("case_034", "tigerbeetle_context_marker", "tigerbeetle_context"),
    ("case_035", "pre_1_0_stdlib_maturity_marker", "pre_1_0_marker"),
    ("case_036", "compiler_miscompile_not_tested_marker", "miscompile_not_tested"),
    ("case_037", "factor_benchmark_not_run_marker", "factor_not_run"),
    ("case_038", "huge_benchmark_not_run_marker", "huge_benchmark_not_run"),
    ("case_039", "no_external_dataset_marker", "no_external_dataset"),
    ("case_040", "no_network_input_marker", "no_network"),
    ("case_041", "no_package_manager_marker", "no_package_manager"),
    ("case_042", "production_performance_not_tested_marker", "prod_perf_not_tested"),
    ("case_043", "version_compatibility_marker", "version_compat"),
    ("case_044", "naive_policy_expected_fail_marker", "naive_expected_fail"),
    ("case_045", "safety_caveat_marker", "safety_caveat"),
]

# pad to 50 cases
extra_cats = [
    "auto_hashmap_insert_lookup_marker",
    "count_after_remove_marker",
    "insert_only_workload_marker",
    "lookup_after_churn_marker",
    "safety_caveat_marker",
]
for i in range(5):
    cid = f"case_{46+i:03d}"
    cat = extra_cats[i]
    cases.append((cid, cat, "insert_lookup"))

out = []
for idx, (case_id, category, op) in enumerate(cases, 1):
    fake_map_name = f"example_map_case_{idx}"
    synthetic_key_label = f"fake_key_{idx}"
    synthetic_value_label = f"demo_hash_key_{idx}"
    operation_sequence_label = op
    expected_map_type_label = "AutoHashMap" if "array" not in category and "string" not in category else ("ArrayHashMap" if "array" in category else "StringHashMap")
    
    # Determine expected outcomes
    expected_success = "success"
    expected_count_before = 0
    expected_count_after = 1
    expected_lookup_result = "found"
    expected_removal_result = "n/a"
    expected_fetch_remove_result = "n/a"
    expected_get_or_put_behavior = "n/a"
    expected_capacity_relation = "n/a"
    expected_churn_context = "none" if "churn" not in category and "tombstone" not in category else "churn_toy"
    expected_string_key_ownership_caveat = "stable_owned" if "string" in category else "n/a"
    expected_allocator_deinit_behavior = "deinit_called"
    expected_iterator_concurrency_caveat = "not_run" if any(x in category for x in ["iterator", "concurrent"]) else "n/a"
    expected_version_compatibility_truth = "local_only"
    expected_production_performance_truth = "not_tested"
    skip_reason = ""
    not_tested = False
    context_only = False

    if "remove_existing" in category:
        expected_removal_result = "removed_true"
        expected_count_after = 0
    if "remove_missing" in category:
        expected_removal_result = "removed_false"
        expected_count_after = 0
    if "fetch_remove" in category:
        expected_fetch_remove_result = "kv_returned"
    if "get_or_put_existing" in category:
        expected_get_or_put_behavior = "found_existing_true"
    if "get_or_put_new" in category:
        expected_get_or_put_behavior = "found_existing_false_init_required"
    if "contains_after_remove" in category:
        expected_lookup_result = "not_found"
    if "count_after_remove" in category:
        expected_count_after = 0
    if "count_after_reinsert" in category:
        expected_count_after = 1
    if "clear_retaining" in category:
        expected_capacity_relation = "capacity_retained"
        expected_count_after = 0
    if "clear_and_free" in category:
        expected_capacity_relation = "capacity_freed"
        expected_count_after = 0
    if "duplicate_put" in category or "replace_value" in category:
        expected_count_after = 1
        expected_lookup_result = "found_updated"
    if any(x in category for x in ["not_tested", "not_run", "not_implemented", "context_marker", "no_external", "no_network", "no_package", "production_performance", "factor_benchmark", "huge_benchmark", "compiler_miscompile", "tigerbeetle", "pre_1_0", "expensive_hash", "stored_hash", "backshift", "rehash", "allocator_leak", "concurrent_reader", "iterator_mutation", "string_hash_map_ephemeral", "array_hash_map_iteration_order", "safety_caveat", "naive_policy"]):
        expected_success = "not_tested" if "not_tested" in category or "not_run" in category or any(s in category for s in ["production_performance", "factor_benchmark", "huge_benchmark", "compiler_miscompile", "stored_hash", "backshift", "rehash", "allocator_leak", "concurrent"]) else "context_only"
        not_tested = "not_tested" in expected_success
        context_only = "context" in expected_success
        skip_reason = "intentionally_not_run_toy_lab_scope"
        expected_lookup_result = "n/a"
        expected_count_after = 0

    if "ephemeral" in category:
        expected_string_key_ownership_caveat = "ephemeral_unsafe_context_only"
    if "iterator" in category or "concurrent" in category:
        expected_iterator_concurrency_caveat = "intentionally_not_run"

    out.append({
        "case_id": case_id,
        "category": category,
        "fake_map_name": fake_map_name,
        "synthetic_key_label": synthetic_key_label,
        "synthetic_value_label": synthetic_value_label,
        "operation_sequence_label": operation_sequence_label,
        "expected_map_type_label": expected_map_type_label,
        "expected_success": expected_success,
        "expected_count_before": expected_count_before,
        "expected_count_after": expected_count_after,
        "expected_lookup_result": expected_lookup_result,
        "expected_removal_result": expected_removal_result,
        "expected_fetch_remove_result": expected_fetch_remove_result,
        "expected_get_or_put_behavior": expected_get_or_put_behavior,
        "expected_capacity_relation": expected_capacity_relation,
        "expected_churn_context": expected_churn_context,
        "expected_string_key_ownership_caveat": expected_string_key_ownership_caveat,
        "expected_allocator_deinit_behavior": expected_allocator_deinit_behavior,
        "expected_iterator_concurrency_caveat": expected_iterator_concurrency_caveat,
        "expected_version_compatibility_truth": expected_version_compatibility_truth,
        "expected_production_performance_truth": expected_production_performance_truth,
        "expected_reason_for_failure_or_skip": skip_reason,
        "naive_expected_fail": category == "naive_policy_expected_fail_marker",
        "synthetic": True,
    })

with open("cases.json", "w") as f:
    json.dump(out, f, indent=2)
print(f"Wrote {len(out)} cases to cases.json")
