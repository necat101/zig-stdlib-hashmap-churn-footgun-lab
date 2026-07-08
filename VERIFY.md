# VERIFY – zig-stdlib-hashmap-churn-footgun-lab

Fresh-clone verification transcript.

```
$ git clone https://github.com/necat101/zig-stdlib-hashmap-churn-footgun-lab.git
$ cd zig-stdlib-hashmap-churn-footgun-lab
$ python3 -m py_compile generate_cases.py run_lab.py
$ python3 generate_cases.py
Wrote 50 cases to cases.json
$ python3 run_lab.py
Zig path: /tmp/zig-linux-x86_64-0.14.0/zig
Zig version: 0.14.0
=== Zig harness output ===
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

Pass 506 Fail 4 Skip 340 Naive_fails 4
Wrote RESULTS.md
$ zig version
0.14.0
$ zig fmt --check hashmap_churn_lab.zig
$ zig run hashmap_churn_lab.zig
[ same harness output as above ]
```

## Verification checklist

- [x] `python3 -m py_compile generate_cases.py run_lab.py` – OK
- [x] `python3 generate_cases.py` – wrote 50 cases
- [x] `python3 run_lab.py` – Zig 0.14.0 discovered, harness compiled and ran, Pass 506 / Fail 4 / Skip 340
- [x] Zig harness observations: AutoHashMap insert/lookup, remove/fetchRemove, getOrPut, clear/capacity, churn timing, ArrayHashMap context, StringHashMap key lifetime, allocator deinit – all observed
- [x] No network calls during lab run
- [x] No huge benchmark (2M / 250M actions NOT run)
- [x] No Factor run
- [x] No Zig stdlib patches
- [x] No concurrency / iterator mutation (intentionally not run)
- [x] HN thread accessed via Hacker News CLI before README – evidence files present
- [x] `cases.json` committed
- [x] `results_rows.csv` / `results_rows.json` committed
- [x] `hashmap_churn_lab.zig` committed
- [x] `README.md`, `RESULTS.md`, `VERIFY.md`, `hn_thread_evidence.md` all present

Toy lab – correctness before performance – synthetic keys only – local Zig version only.
