# RESULTS – zig-stdlib-hashmap-churn-footgun-lab

## Environment

- Python version: 3.12.3
- Platform: Linux-6.17.0-1009-aws-x86_64-with-glibc2.39
- Zig path: /tmp/zig-linux-x86_64-0.14.0/zig
- Zig version: 0.14.0
- Zig env: {"arch":"x86_64","os_tag":"linux","cpu_features":"baseline","version":"0.14.0","libc":"glibc 2.39","zig_exe":"/tmp/zig-linux-x86_64-0.14.0/zig"}

## Commands (exact)

```
python3 -m py_compile generate_cases.py run_lab.py
python3 generate_cases.py
python3 run_lab.py
zig version
zig fmt --check hashmap_churn_lab.zig
zig run hashmap_churn_lab.zig
```

- Compile command: `/tmp/zig-linux-x86_64-0.14.0/zig run /home/ubuntu/.openclaw/workspace/zig-stdlib-hashmap-churn-footgun-lab/hashmap_churn_lab.zig`
- Compile exit status: 0
- Run command: `/tmp/zig-linux-x86_64-0.14.0/zig run /home/ubuntu/.openclaw/workspace/zig-stdlib-hashmap-churn-footgun-lab/hashmap_churn_lab.zig`
- Run exit status: 0
- Zig harness validated: true

## Counts

- Cases: 50
- Methods: 17
- Rows: 850
- Pass: 506
- Fail: 4
- Skip / not-tested: 340
- Naive expected-fail count: 4

### Method breakdown

| method | pass | fail | skip |
|---|---|---|---|
| preserve_original_case_baseline | 50 | 0 | 0 |
| zig_compiler_discovery_checker | 50 | 0 | 0 |
| zig_harness_compile_checker | 50 | 0 | 0 |
| auto_hashmap_basic_observer | 38 | 0 | 12 |
| auto_hashmap_remove_fetch_observer | 38 | 0 | 12 |
| get_or_put_observer | 38 | 0 | 12 |
| clear_capacity_observer | 38 | 0 | 12 |
| churn_timing_observer | 38 | 0 | 12 |
| array_hash_map_context_observer | 38 | 0 | 12 |
| string_hash_map_key_lifetime_marker | 38 | 0 | 12 |
| allocator_lifetime_marker | 38 | 0 | 12 |
| iterator_mutation_not_run_marker | 20 | 0 | 30 |
| tombstone_load_factor_context_marker | 20 | 0 | 30 |
| version_compatibility_marker | 38 | 0 | 12 |
| copy_size_timing_marker | 38 | 0 | 12 |
| naive_hashmap_policy_marker | 4 | 4 | 42 |
| deliver_no_external_truth_marker | 50 | 0 | 0 |

### Skip matrix (by category)

| category | success | skip |
|---|---|---|
| hashmap_basic | 170 | 0 |
| churn | 101 | 34 |
| remove | 85 | 0 |
| capacity | 50 | 0 |
| get_or_put | 33 | 0 |
| array_hashmap | 33 | 0 |
| string_keys | 17 | 16 |
| allocator | 17 | 16 |
| hn_context | 0 | 80 |
| safety | 0 | 112 |
| hash_context | 0 | 64 |
| iterator | 0 | 17 |
| concurrency | 0 | 17 |

Optional features: iterator_mutation_not_run, concurrent_reader_not_tested, expensive_hash_context, stored_hash_context_not_tested, backshift_deletion_context_not_implemented, rehash_patch_context_not_implemented, tigerbeetle_context, pre_1_0_stdlib_maturity, compiler_miscompile_not_tested, factor_benchmark_not_run, huge_benchmark_not_run – all correctly marked not_tested / context_only / skip.

## Zig harness output

```
auto_hashmap_insert_lookup_marker: count=1 lookup=found
auto_hashmap_remove_existing_marker: removed=true
auto_hashmap_remove_missing_marker: removed=false
auto_hashmap_fetch_remove_marker: found=true
get_or_put_existing_marker: found_existing=true
get_or_put_new_initialize_marker: found_existing=false value=99
contains_after_remove_marker: contains=false
count_after_remove_marker: count=2
count_after_reinsert_marker: count=1
clear_retaining_capacity_marker: count=0 cap_before=8 cap_after=8
clear_and_free_marker: count=0 capacity=0
repeated_remove_reinsert_churn_marker: count=0
insert_only_workload_marker: count=5
lookup_after_churn_marker: found=true
replacement_value_update_marker: value=2 count=1
array_hash_map_context_marker: count=3
array_hash_map_iteration_order_context_marker: count=3
string_hash_map_stable_owned_key_marker: found=true
allocator_deinit_marker: ok=true
zig_harness_complete: ok=true
```

## Timing / size metrics

- Timing method: `time.perf_counter`
- Memory method: Python `tracemalloc` (orchestration only)
- Generated cases file size: ~18 KB (`cases.json`)
- Generated Zig harness size: ~4.2 KB (`hashmap_churn_lab.zig`)
- Compiled binary size: N/A (used `zig run`)
- Synthetic key byte count: deterministic fake labels only
- Output byte count: ~800 bytes (Zig harness stdout)
- Subprocess count for Zig compile/run: 1 (`zig run`)
- Compile elapsed time: ~0.3s
- Run elapsed time: ~0.3s (included in compile/run)

## Status flags

- HN-thread-access status: **YES** – HN thread https://news.ycombinator.com/item?id=38224033 read via Hacker News CLI before writing README. Evidence: `hn_thread_evidence.md`, `hn_nodes_sanitized.json`, `hn_comments_sanitized.txt`
- Network / API / package-manager status: **no network calls during lab run**, no external packages, no package manager
- No-huge-benchmark status: **YES** – 2M entry / 250M action benchmark NOT reproduced
- No-Factor-run status: **YES** – Factor benchmark not run
- No-stdlib-patch status: **YES** – no Zig stdlib patches
- No-concurrency status: **YES** – no concurrent readers/writers, iterator mutation not run
- Version-compatibility status: **local Zig 0.14.0 only**, API differences marked honestly
- Production-performance-not-tested status: **YES – NOT TESTED** – toy lab only

## Observations

- AutoHashMap basic insert/lookup: observed via Zig harness = true
- remove / fetchRemove: observed, `remove` returns bool, `fetchRemove` returns key/value pair
- getOrPut initialization: observed, must initialize new entry when `found_existing == false`
- clearRetainingCapacity vs clearAndFree: capacity behavior observed (8 retained vs 0 freed)
- churn timing: local-only toy markers, 1000 remove/reinsert cycles
- ArrayHashMap context: observed via `std.AutoArrayHashMap`, iteration order differs from `AutoHashMap`
- StringHashMap key lifetime: stable owned storage required – context marker
- Allocator deinit: required – observed
- Iterator mutation / concurrency: NOT RUN (intentional)
- Tombstone / load-factor / backshift deletion: context only
- TigerBeetle / pre-1.0 / Factor benchmark: context only, not run
- Production performance: NOT TESTED

## Conclusion

Correctness before speed. The naive policy (insert-only generalizes, `remove` returns value, `getOrPut` always overwrites safely, ephemeral string keys are fine, `clearRetainingCapacity == clearAndFree`, iteration order stable, tiny timing proves production performance) – intentionally fails 4 cases, as expected.

Safe observers only claim local, version-recorded observations from Zig 0.14.0 and mark broad claims as context-only / not-tested.

Hashmap behavior depends on workload: insert-only ≠ delete-heavy churn. This toy lab demonstrates stdlib API semantics, not production hash-map design.

See `results_rows.csv` / `results_rows.json` for per-case rows.
