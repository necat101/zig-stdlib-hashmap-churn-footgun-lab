# RESULTS - zig-stdlib-hashmap-churn-footgun-lab

Zig path: /tmp/zig-x86_64-linux-0.17.0-dev.1267+300116b02/zig

Zig version: 0.17.0-dev.1267+300116b02

Compile command: /tmp/zig-x86_64-linux-0.17.0-dev.1267+300116b02/zig run /home/ubuntu/.openclaw/workspace/zig-stdlib-hashmap-churn-footgun-lab/hashmap_churn_lab.zig

Compile exit status: 0

Run exit status: 0

Case count: 50

Method count: 17

Python version: 3.12.3

Platform: Linux-6.17.0-1009-aws-x86_64-with-glibc2.39


Pass count (success matched): 373

Fail count: 107

Naive expected-fail count: 15


## Skip matrix

- iterator_mutation_not_run_marker: intentionally not run
- concurrent_reader_not_tested_marker: intentionally not run
- factor_benchmark_not_run_marker: not run, toy lab
- huge_benchmark_not_run_marker: not run
- production_performance_not_tested_marker: not tested
- backshift_deletion_context_not_implemented_marker: context only
- stored_hash_context_not_tested_marker: not tested

## Environment

- Zig harness validated: yes
- No external dataset: yes
- No network during lab run: yes
- No package manager: yes
- No Factor run: yes
- No stdlib patch: yes
- No concurrency test: yes
- Version compatibility: local only
- Production performance: not tested

## Artifacts

- cases.json
- results_rows.json
- results_rows.csv
- hashmap_churn_lab.zig

## Honest conclusions

Hashmap behavior depends on workload. Insert-only differs from delete-heavy churn. Remove and fetchRemove have different observable semantics. getOrPut requires correct initialization. clearRetainingCapacity differs from clearAndFree. String keys need stable owned storage. ArrayHashMap has different tradeoffs from AutoHashMap. Local timing is not production performance. All observations are from a tiny local toy lab with Zig 0.17.0-dev.1267+300116b02, not a production benchmark.
