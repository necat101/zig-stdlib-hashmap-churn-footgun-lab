# VERIFY – zig-stdlib-hashmap-churn-footgun-lab

Fresh-clone verification transcript.

```
$ git clone https://github.com/necat101/zig-stdlib-hashmap-churn-footgun-lab.git
Cloning into 'zig-stdlib-hashmap-churn-footgun-lab'...
$ cd zig-stdlib-hashmap-churn-footgun-lab
$ python3 -m py_compile generate_cases.py run_lab.py
$ python3 generate_cases.py
Wrote 50 cases to cases.json
$ python3 run_lab.py
Loaded 50 cases
Zig: /tmp/zig-x86_64-linux-0.17.0-dev.1267+300116b02/zig version 0.17.0-dev.1267+300116b02
Wrote RESULTS.md, 850 result rows
Zig validated: True
$ /tmp/zig-x86_64-linux-0.17.0-dev.1267+300116b02/zig version
0.17.0-dev.1267+300116b02
$ /tmp/zig-x86_64-linux-0.17.0-dev.1267+300116b02/zig fmt --check hashmap_churn_lab.zig
$ /tmp/zig-x86_64-linux-0.17.0-dev.1267+300116b02/zig run hashmap_churn_lab.zig 2>&1 | head -20
[
  {"case_id":"case_001","observed_success":"success","count_after":1,"lookup_found":true,"remove_ok":false,"fetch_remove_ok":false,"get_or_put_found":false,"capacity":8},
  {"case_id":"case_002","observed_success":"success","count_after":0,"lookup_found":false,"remove_ok":true,"fetch_remove_ok":false,"get_or_put_found":false,"capacity":0},
  ...
]
```

- Zig harness compiled and ran successfully
- Hashmap operations observed: put/get/remove/fetchRemove/getOrPut all behaved as expected locally
- Clear/capacity observations: clearRetainingCapacity retains capacity, clearAndFree frees
- Churn timing: toy local only, not production
- ArrayHashMap context: API changed in 0.17 – fallback noted in harness
- String-key caveat: stable owned keys tested, ephemeral keys marked not_run
- Allocator/deinit: map.deinit() called, leak checker not_tested (toy scope)
- Iterator/concurrency: intentionally not_run
- No Factor run, no huge benchmark, no stdlib patch, no network, no external dataset, no package manager
- Version compatibility: Zig 0.17.0-dev.1267+300116b02, local only
- Production performance: NOT tested

All 50 cases generated deterministically (seed 42). Results reproducible.
