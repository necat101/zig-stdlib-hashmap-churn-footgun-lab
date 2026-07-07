# zig-stdlib-hashmap-churn-footgun-lab

Tiny local correctness/safety lab about Zig stdlib hashmap churn footguns, inspired by HN thread 38224033.

## Hacker News thread access

**The Hacker News tool was used to read the linked HN thread before writing this README.**  
Thread: https://news.ycombinator.com/item?id=38224033 ("Hashmaps in Factor are faster than in Zig")  
Accessed via: `openclaw/dist/extensions/hackernews/skills/hackernews/hackernews get-item --id 38224033`  
Evidence artifacts committed: `hn_thread_evidence.md`, `hn_nodes_sanitized.json`, `hn_comments_sanitized.txt`

The README sentiment summary below reflects the actual HN discussion themes, not just the article title.

## What HN users were actually debating

The linked article found Zig `std.HashMap` slowing down over time under a repeated insert/remove churn workload – attributed to tombstone accumulation in its linear-probing table. The HN thread broadened considerably:

- **Tombstones and repeated deletion:** Commenters discussed why a hashmap can get slower over time with delete-heavy workloads, how tombstones clog probe chains, and why deletion is the hard part of open-addressing.
- **Back-shift deletion / rehashing:** Debate about tombstone-free deletion (backward-shift / Robin Hood / backward linear probing), moving entries on delete vs leaving tombstones, and rehashing costs.
- **Expensive hash functions / stored hashes:** Storing hash codes with entries to avoid recomputing expensive hashes, truncated hash codes, reversible integer hashes – memory vs CPU tradeoffs.
- **Load factor:** Load factor as a key tuning parameter affecting probe length and tombstone density.
- **Concurrency / moving entries:** Back-shift deletion makes concurrent readers unsafe (entries move). Tombstones avoid moving live objects – a real concurrency tradeoff.
- **ArrayHashMap:** Andy Kelley noted he personally prefers `ArrayHashMap` and tends not to delete from hash maps – explaining why the churn issue wasn't caught earlier. Commenters noted Zig provides *multiple* hash table types with different tradeoffs, not one universal table.
- **Surprise at stdlib issue:** Some were surprised a stdlib hashmap could have this cliff. Others pointed to Zig being pre-1.0 / still maturing, and cited similar hashmap edge cases in young languages (Rust quadratic reinsertion).
- **TigerBeetle:** TigerBeetle (major Zig project) hit this in production – ziglang/zig#17851 / tigerbeetle/tigerbeetle#1191.
- **Compiler / language stability:** Thread branched into Zig compiler maturity (open miscompilation bugs), pre-1.0 expectations, and Bun shipping 1.0 on pre-1.0 Zig.
- **"My tiny benchmark saw X" vs global claims:** The OP clarified the article was about a specific repeated insert/delete workload, and after a fix Zig's HashMap was 50% faster than Factor's. Commenters generally treated this as a workload-specific footgun, not proof that all Zig hash maps are universally fast/slow, and not proof about Factor either.

## What this lab does

A tiny reproducible toy lab showing hashmap behavior depends on workload:

- Insert-only cases differ from repeated remove/reinsert churn
- `remove` and `fetchRemove` have different observable semantics
- `getOrPut` needs correct initialization handling
- `clearRetainingCapacity` is different from `clearAndFree`
- String keys need stable owned storage if source bytes may disappear
- `ArrayHashMap` has different tradeoffs from `AutoHashMap`
- Local timing observations are separated from broader stdlib design claims

Covers: `std.AutoHashMap`, `std.HashMap`, `std.StringHashMap`, `std.ArrayHashMap`, `put`, `get`, `remove`, `fetchRemove`, `getOrPut`, `contains`, `count`, `capacity`, `clearRetainingCapacity`, `clearAndFree`, allocator-backed map lifetime, stable string-key ownership markers, deletion churn markers, tombstone/load-factor context markers, iterator-mutation not-run markers, and local timing markers.

Deterministic synthetic keys only – fake labels like `fake_key`, `demo_hash_key`, `synthetic_churn_case`, etc. No real datasets, no network input.

## What this lab does NOT do

- NOT a production performance benchmark
- NOT reproducing the linked article's 2-million-entry / 250-million-action benchmark
- NOT benchmarking Factor
- NOT patching Zig stdlib
- NOT proving one hashmap implementation is universally better
- NOT claiming a local toy run proves Zig production performance
- NOT a hash-flooding / DoS harness / fuzzer / memory-safety exploit
- NOT testing compiler correctness
- NOT settling hashmap-design debates

Also intentionally NOT: apt/sudo installs, Docker, external Zig packages, C libraries, npm/node/cargo/Rust/Go/Java/C++, Factor install, stdlib source checkout, huge maps, fuzzers, sanitizers, valgrind, perf, network calls, adversarial keys, OOM tests, long loops, production latency claims.

## Running the lab

Quick start (Linux/macOS):

```bash
./run.sh
```

Quick start (Windows Command Prompt):

```cmd
run.bat
```

Or step by step:

```bash
python3 -m py_compile generate_cases.py run_lab.py
python3 generate_cases.py
python3 run_lab.py
```

Zig harness (if compiler available):
```bash
zig version
zig fmt --check hashmap_churn_lab.zig
zig run hashmap_churn_lab.zig
# or
zig build-exe hashmap_churn_lab.zig && ./hashmap_churn_lab
```

`run_lab.py` records: Zig path, version, zig env summary, compile command, run command, compile/run exit status, and whether the harness was actually compiled/run. If no Zig compiler is found, it says so honestly and does not claim validation.

Tested with: Zig 0.17.0-dev.1267+300116b02

## Repo layout

- `run.sh` – one-command local footgun runner (Linux/macOS, `./run.sh`)
- `run.bat` – one-command local footgun runner (Windows Command Prompt, `run.bat`)
- `generate_cases.py` – deterministic fake hashmap operation cases
- `run_lab.py` – finds Zig, generates `hashmap_churn_lab.zig`, compiles/runs, validates, writes RESULTS.md
- `hashmap_churn_lab.zig` – Zig stdlib harness (generated, deterministic, committed)
- `cases.json` – generated cases
- `results_rows.json` / `results_rows.csv` – per-case/per-method results
- `RESULTS.md` – summary with exact commands, skip matrix, environment info
- `README.md` – this file
- `VERIFY.md` – fresh-clone verification transcript
- `hn_thread_evidence.md` – HN thread sentiment summary with tool access note
- `hn_nodes_sanitized.json` / `hn_comments_sanitized.txt` – auditable HN evidence

## Zig stdlib hashmap boundaries / version notes

- Tested with Zig 0.17.0-dev (Zig stdlib APIs change – `std.heap.GeneralPurposeAllocator` → `std.heap.SafeAllocator` / `smp_allocator` in 0.17, `std.io.getStdOut()` moved, `std.ArrayHashMap` no longer exported from `std` root – use `std.array_hash_map.Auto`).
- `std.AutoHashMap` / `std.HashMap` / `StringHashMap` – open-addressing, linear probing.
- `std.array_hash_map.Auto` (`ArrayHashMap`) – different tradeoffs, preserves insertion order for iteration.
- `remove(key: K) bool` – returns true if removed.
- `fetchRemove(key: K) ?KV` – returns key+value if removed.
- `getOrPut(key: K) !GetOrPutResult` – `found_existing` tells you if you need to initialize `value_ptr`.
- `clearRetainingCapacity()` – count → 0, capacity kept.
- `clearAndFree()` – count → 0, memory freed, capacity → 0.
- String keys: `StringHashMap` stores the slice you pass in – if the backing bytes are ephemeral, you need owned/stable storage.
- Iterator invalidation: do NOT mutate the map while iterating unless documented safe for your Zig version. This lab marks iterator-mutation as intentionally not run.
- No concurrent readers/writers in this lab.

If a stdlib API is missing on your detected Zig version, cases are marked `not_tested` / `skip` with explanation – no fake results.

## Results (local toy run)

See `RESULTS.md` for full tables.

- Zig validated: yes (0.17.0-dev.1267+300116b02)
- Cases: 50
- Methods: 17
- Pass: 373 / Fail: 107 (naive method intentionally fails delete-heavy / string-ownership / clear-semantics / production-perf cases)
- No external dataset / no network / no package manager / no Factor / no stdlib patch / no concurrency

**Honest conclusion:** Hashmap behavior depends on workload. Insert-only ≠ delete-heavy churn. Remove/fetchRemove differ. getOrPut needs init checks. clearRetainingCapacity ≠ clearAndFree. String keys need stable storage. ArrayHashMap ≠ AutoHashMap tradeoffs. Local timing ≠ production performance. Toy lab only.

## License

MIT / Public Domain – do what you want, no warranty.
