#!/usr/bin/env python3
"""
zig-stdlib-hashmap-churn-footgun-lab – generate_cases.py

Deterministic synthetic hashmap operation cases.
"""
import json, pathlib

cases = []

def add(case_id, category, **kw):
    base = {
        "case_id": case_id,
        "category": category,
        "fake_map_name": kw.get("fake_map_name", "example_map_case"),
        "synthetic_key_label": kw.get("synthetic_key_label", "fake_key"),
        "synthetic_value_label": kw.get("synthetic_value_label", "demo_hash_key"),
        "operation_sequence_label": kw.get("operation_sequence_label", "toy_lookup_case"),
        "expected_map_type_label": kw.get("expected_map_type_label", "std.AutoHashMap"),
        "expected_success": kw.get("expected_success", "success"),
        "expected_count_before": kw.get("expected_count_before", 0),
        "expected_count_after": kw.get("expected_count_after", 1),
        "expected_lookup_result": kw.get("expected_lookup_result", "found"),
        "expected_removal_result": kw.get("expected_removal_result", "not_applicable"),
        "expected_fetchRemove_result": kw.get("expected_fetchRemove_result", "not_applicable"),
        "expected_getOrPut_behavior": kw.get("expected_getOrPut_behavior", "not_applicable"),
        "expected_capacity_relation": kw.get("expected_capacity_relation", "not_tested"),
        "expected_churn_context": kw.get("expected_churn_context", "none"),
        "expected_timing_context": kw.get("expected_timing_context", "local_only"),
        "expected_string_key_ownership_caveat": kw.get("expected_string_key_ownership_caveat", "none"),
        "expected_allocator_deinit_behavior": kw.get("expected_allocator_deinit_behavior", "deinit_required"),
        "expected_iterator_concurrency_caveat": kw.get("expected_iterator_concurrency_caveat", "not_tested"),
        "expected_version_compatibility_truth": kw.get("expected_version_compatibility_truth", "local_version_only"),
        "expected_production_performance_truth": kw.get("expected_production_performance_truth", "not_tested"),
        "expected_failure_reason": kw.get("expected_failure_reason", ""),
        "expected_fail_for_naive": kw.get("expected_fail_for_naive", False),
    }
    base.update(kw)
    base["case_id"] = case_id
    base["category"] = category
    cases.append(base)

# Core AutoHashMap cases
add("auto_hashmap_insert_lookup_marker", "hashmap_basic",
    fake_map_name="example_map_case",
    synthetic_key_label="fake_key",
    operation_sequence_label="toy_lookup_case",
    expected_map_type_label="std.AutoHashMap",
    expected_count_before=0, expected_count_after=1,
    expected_lookup_result="found")

add("auto_hashmap_remove_existing_marker", "remove",
    fake_map_name="sample_remove_case",
    synthetic_key_label="demo_hash_key",
    operation_sequence_label="sample_remove_case",
    expected_map_type_label="std.AutoHashMap",
    expected_count_before=1, expected_count_after=0,
    expected_removal_result="removed",
    expected_lookup_result="not_found")

add("auto_hashmap_remove_missing_marker", "remove",
    fake_map_name="sample_remove_case",
    synthetic_key_label="fake_key",
    expected_removal_result="not_found",
    expected_lookup_result="not_found",
    expected_count_before=0, expected_count_after=0)

add("auto_hashmap_fetch_remove_marker", "remove",
    fake_map_name="sample_remove_case",
    synthetic_key_label="demo_hash_key",
    operation_sequence_label="fetch_remove_case",
    expected_map_type_label="std.AutoHashMap",
    expected_fetchRemove_result="found_and_removed",
    expected_count_before=1, expected_count_after=0)

add("get_or_put_existing_marker", "get_or_put",
    fake_map_name="example_map_case",
    synthetic_key_label="fake_key",
    operation_sequence_label="get_or_put_case",
    expected_getOrPut_behavior="found_existing",
    expected_count_before=1, expected_count_after=1)

add("get_or_put_new_initialize_marker", "get_or_put",
    fake_map_name="example_map_case",
    synthetic_key_label="demo_hash_key",
    operation_sequence_label="get_or_put_case",
    expected_getOrPut_behavior="inserted_new_must_initialize",
    expected_count_before=0, expected_count_after=1,
    expected_fail_for_naive=True,
    expected_failure_reason="naive getOrPut assumes overwrite safe without init check")

add("contains_after_remove_marker", "remove",
    fake_map_name="example_map_case",
    expected_lookup_result="not_found",
    expected_removal_result="removed")

add("count_after_remove_marker", "remove",
    expected_count_before=3, expected_count_after=2,
    expected_removal_result="removed")

add("count_after_reinsert_marker", "churn",
    fake_map_name="synthetic_churn_case",
    operation_sequence_label="synthetic_churn_case",
    expected_count_before=1, expected_count_after=1,
    expected_churn_context="remove_reinsert")

# clear / capacity
add("clear_retaining_capacity_marker", "capacity",
    fake_map_name="synthetic_capacity_case",
    operation_sequence_label="clear_retaining_case",
    expected_capacity_relation="capacity_retained",
    expected_count_before=5, expected_count_after=0,
    expected_fail_for_naive=True,
    expected_failure_reason="naive assumes clearRetainingCapacity == clearAndFree")

add("clear_and_free_marker", "capacity",
    fake_map_name="synthetic_capacity_case",
    operation_sequence_label="clear_free_case",
    expected_capacity_relation="capacity_freed",
    expected_count_before=5, expected_count_after=0)

# churn / tombstone context
add("repeated_remove_reinsert_churn_marker", "churn",
    fake_map_name="synthetic_churn_case",
    synthetic_key_label="toy_tombstone_context",
    operation_sequence_label="synthetic_churn_case",
    expected_churn_context="repeated_delete_heavy",
    expected_timing_context="local_only")

add("tombstone_context_marker", "churn",
    fake_map_name="toy_tombstone_context",
    synthetic_key_label="toy_tombstone_context",
    operation_sequence_label="tombstone_context",
    expected_churn_context="tombstone_linear_probing",
    expected_production_performance_truth="not_tested")

add("load_factor_context_marker", "churn",
    fake_map_name="hashmap_policy_case",
    operation_sequence_label="load_factor_case",
    expected_churn_context="load_factor_affects_probing")

add("capacity_growth_context_marker", "capacity",
    fake_map_name="synthetic_capacity_case",
    expected_capacity_relation="capacity_grows",
    expected_count_before=0, expected_count_after=10)

add("small_map_no_churn_marker", "hashmap_basic",
    expected_count_before=0, expected_count_after=2)

add("insert_only_workload_marker", "hashmap_basic",
    operation_sequence_label="insert_only_case",
    expected_churn_context="none",
    expected_count_before=0, expected_count_after=5)

add("delete_heavy_workload_marker", "churn",
    fake_map_name="synthetic_churn_case",
    operation_sequence_label="delete_heavy_case",
    expected_churn_context="delete_heavy",
    expected_fail_for_naive=True,
    expected_failure_reason="naive assumes insert-only generalizes to delete-heavy")

add("lookup_after_churn_marker", "churn",
    fake_map_name="synthetic_churn_case",
    expected_lookup_result="found",
    expected_churn_context="lookup_after_delete_cycle")

add("replacement_value_update_marker", "hashmap_basic",
    operation_sequence_label="overwrite_case",
    expected_count_before=1, expected_count_after=1,
    expected_lookup_result="found")

add("duplicate_put_overwrite_marker", "hashmap_basic",
    operation_sequence_label="duplicate_put_case",
    expected_count_before=1, expected_count_after=1)

# ArrayHashMap
add("array_hash_map_context_marker", "array_hashmap",
    fake_map_name="example_map_case",
    expected_map_type_label="std.ArrayHashMap",
    expected_count_before=0, expected_count_after=3)

add("array_hash_map_iteration_order_context_marker", "array_hashmap",
    expected_map_type_label="std.ArrayHashMap",
    expected_iterator_concurrency_caveat="iteration_order_stable_for_ArrayHashMap_only",
    expected_fail_for_naive=True,
    expected_failure_reason="naive assumes iteration order stable across map types")

# StringHashMap
add("string_hash_map_stable_owned_key_marker", "string_keys",
    fake_map_name="demo_string_key_case",
    synthetic_key_label="demo_string_key_case",
    expected_map_type_label="std.StringHashMap",
    expected_string_key_ownership_caveat="stable_owned_storage_required")

add("string_hash_map_ephemeral_key_context_not_run_marker", "string_keys",
    expected_map_type_label="std.StringHashMap",
    expected_string_key_ownership_caveat="ephemeral_bytes_unsafe",
    expected_success="not_tested",
    expected_fail_for_naive=True,
    expected_failure_reason="naive assumes ephemeral string bytes always safe")

# allocator
add("allocator_deinit_marker", "allocator",
    expected_allocator_deinit_behavior="deinit_required",
    expected_count_before=2, expected_count_after=2)

add("allocator_leak_not_tested_marker", "allocator",
    expected_allocator_deinit_behavior="not_tested",
    expected_success="not_tested")

# iterator / concurrency – not run
add("iterator_mutation_not_run_marker", "iterator",
    expected_iterator_concurrency_caveat="mutation_during_iteration_not_run",
    expected_success="not_tested")

add("concurrent_reader_not_tested_marker", "concurrency",
    expected_iterator_concurrency_caveat="concurrent_read_relocate_not_tested",
    expected_success="not_tested")

# hash / deletion algorithm context
add("expensive_hash_context_marker", "hash_context",
    expected_churn_context="expensive_hash_function",
    expected_success="context_only")

add("stored_hash_context_not_tested_marker", "hash_context",
    expected_success="not_tested",
    expected_churn_context="stored_hash_code_design")

add("backshift_deletion_context_not_implemented_marker", "hash_context",
    expected_success="context_only",
    expected_churn_context="backshift_deletion",
    expected_production_performance_truth="not_tested")

add("rehash_patch_context_not_implemented_marker", "hash_context",
    expected_success="context_only",
    expected_churn_context="rehash_on_delete")

# HN thread specific context markers
add("tigerbeetle_context_marker", "hn_context",
    expected_success="context_only",
    expected_production_performance_truth="not_tested",
    expected_failure_reason="TigerBeetle noticed Zig HashMap churn – context only")

add("pre_1_0_stdlib_maturity_marker", "hn_context",
    expected_success="context_only",
    expected_version_compatibility_truth="pre_1_0",
    expected_production_performance_truth="not_tested")

add("compiler_miscompile_not_tested_marker", "hn_context",
    expected_success="not_tested",
    expected_production_performance_truth="not_tested")

add("factor_benchmark_not_run_marker", "hn_context",
    expected_success="not_run",
    expected_production_performance_truth="not_tested",
    expected_failure_reason="Factor benchmark not run – toy lab only")

add("huge_benchmark_not_run_marker", "hn_context",
    expected_success="not_run",
    expected_production_performance_truth="not_tested",
    expected_failure_reason="2M entry / 250M action benchmark not reproduced")

# safety / scope markers
for cid, cat, reason in [
("no_external_dataset_marker", "safety", "synthetic keys only"),
("no_network_input_marker", "safety", "no network"),
("no_package_manager_marker", "safety", "no external packages"),
("production_performance_not_tested_marker", "safety", "toy lab only"),
("version_compatibility_marker", "safety", "local_version_only"),
("naive_policy_expected_fail_marker", "safety", "naive insert-only assumption"),
("safety_caveat_marker", "safety", "toy lab – not production benchmark"),
]:
    add(cid, cat,
        expected_success="context_only" if "not_tested" not in cid else "not_tested",
        expected_production_performance_truth="not_tested",
        expected_failure_reason=reason,
        expected_fail_for_naive=("naive" in cid))

# Fill up to ~45 cases – add a few more basic variations
for i in range(1,6):
    add(f"auto_hashmap_basic_variant_{i}_marker", "hashmap_basic",
        synthetic_key_label=f"fake_key_{i}",
        expected_count_before=i-1,
        expected_count_after=i)

path = pathlib.Path(__file__).parent / "cases.json"
path.write_text(json.dumps(cases, indent=2))
print(f"Wrote {len(cases)} cases to {path}")
