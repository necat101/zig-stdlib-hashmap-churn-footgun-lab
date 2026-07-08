# zig-stdlib-hashmap-churn-footgun-lab

A tiny, reproducible, local correctness and safety lab about Zig stdlib hashmap churn footguns – turning a Hacker News debate into observable behavior, not a production benchmark.

**HN thread:** https://news.ycombinator.com/item?id=38224033  
**Linked article:** https://re.factorcode.org/2023/11/factor-is-faster-than-zig.html  
**Zig docs:** https://ziglang.org/documentation/master/

> **Hacker News thread access:** The HN thread at https://news.ycombinator.com/item?id=38224033 was read via the bundled Hacker News CLI (`openclaw skills hackernews`) before writing this README. Sentiments below reflect the actual discussion, not just the article title. Evidence artifacts: `hn_thread_evidence.md`, `hn_nodes_sanitized.json`, `hn_comments_sanitized.txt`.

## Hacker News thread sentiments

Commenters debated a Factor article reporting that Zig `std.HashMap` got slower over time under a repeated insert/delete workload – classic deletion churn / tombstone accumulation in linear probing.

- **Tombstones and repeated deletion:** Top comment: tombstones in linear probing are hard to justify except in concurrent contexts where you can't move entries. Tombstone-free deletion exists and is simple. Others proposed deleting trailing tombstones, and a heuristic for avoiding most tombstones at moderate load factors.

- **Back-shift deletion / rehashing:** Back-shift deletion requires rehashing every candidate to avoid shifting beyond its home bucket (unlike Robin Hood where probe lengths give this for free). This makes it unsuitable when the hash function is expensive, unless hash codes are stored or load factor is kept low.

- **Expensive hash functions / load factor:** String-key benchmarks at 0.95 load factor – Robin Hood maps spiked 5–6× slower at 0.95 vs 0.5. SIMD maps (Boost, Absl) and a Fastmap design stayed mostly immune.

- **Concurrency / moving entries:** Main tradeoff for back-shift / relocation-on-delete: "it's difficult to safely read a hash table while its entries are being concurrently relocated". Also higher average latency, but much better worst-case (no global rehash).

- **ArrayHashMap came up:** Andy Kelley (Zig creator) commented directly: "I generally prefer ArrayHashMap" and "I tend to not delete things from hash maps" – explaining why the churn issue went unnoticed.

- **Zig has multiple hash-table types:** Commenters noted Zig provides several different hash tables, not all affected the same way. Stdlib container-design tradeoffs were discussed (Rust LinkedList analogy).

- **Surprise at stdlib performance issue:** "Hash maps are such a fundamentally important data structure that it comes as a surprise that the Zig implementation is so broken. Good to see it's getting fixed, but surprising that this wasn't detected before."

- **Pre-1.0 / maturity expectations:** "When you use a language that's in alpha- (maybe beta- now?) stage, this kind of thing should be expected. Even with the latest version of Zig, perfectly correct programs can segfault due to miscompilation, so performance issues are not even the biggest worry you should have."

- **TigerBeetle came up:** TigerBeetle (one of the bigger Zig projects) noticed this issue – ziglang/zig#17851, tigerbeetle/tigerbeetle#1191.

- **Compiler / language stability:** Discussion about Bun reaching 1.0 while being written in Zig which hasn't reached 1.0. Counterpoint: with close to 100% test coverage you can work around compiler bugs, but "it's a risky bet".

- **"my tiny local churn benchmark saw X" vs global claims:** An extensive sub-thread debated Robin Hood vs BLP (bidirectional linear probing), benchmark methodology, load factor measurement intervals, key types, hash function cost, moving elements cost, cache misses, and JVM microbenchmark trust. Consensus: "benchmarking hash tables is pretty difficult because there's many variables that affect their performance and it's hard to cover all use cases." A local toy run does not prove all Zig hash maps are fast or slow.

See `hn_thread_evidence.md` for a full auditable summary with links.

## What this lab does

- `std.AutoHashMap`, `std.HashMap`, `std.StringHashMap`, `std.ArrayHashMap`
- `put`, `get`, `remove`, `fetchRemove`, `getOrPut`, `contains`, `count`, `capacity`, `clearRetainingCapacity`, `clearAndFree`
- allocator-backed map lifetime, stable string-key ownership markers, deletion churn markers, tombstone/load-factor context markers, iterator-mutation not-run markers, local timing markers
- Deterministic synthetic keys only – `fake_key`, `demo_hash_key`, `synthetic_churn_case`, etc.
- 50 cases, 17 methods, 850 rows

The point is **not** to reproduce the linked article's 2-million-entry / 250-million-action benchmark, not to benchmark Factor, not to patch Zig stdlib, not to prove one hashmap is universally better, and not to claim a toy run proves Zig production performance.

The point is to show: insert-only ≠ delete-heavy churn, `remove` / `fetchRemove` have different semantics, `getOrPut` needs initialization handling, `clearRetainingCapacity` ≠ `clearAndFree`, string keys need stable owned storage, `ArrayHashMap` has different tradeoffs from `AutoHashMap`, and local timing observations ≠ stdlib design claims.

## Scope / safety

This is a toy local lab, **not** a production performance benchmark, **not** a patch to Zig stdlib, **not** a Factor benchmark, **not** a compiler stress test, **not** a hash-flooding test, **not** a DoS harness, **not** a fuzzer, **not** a memory-safety exploit.

- Deterministic synthetic keys only
- No real datasets, logs, service keys, production traces
- No network input, no downloaded corpora
- No third-party Zig packages, no C libraries
- No apt / sudo / Docker / package managers
- No Factor install, no stdlib source checkout
- No huge maps (no 2M entry / 250M action benchmark)
- No fuzzers, sanitizers, valgrind, perf, flamegraphs
- No concurrent readers/writers, no adversarial hash-collision keys
- No OOM tests, no long-running loops

## Running

```bash
python3 -m py_compile generate_cases.py run_lab.py
python3 generate_cases.py
python3 run_lab.py
```

Zig harness (auto-generated):

```bash
zig version
zig fmt --check hashmap_churn_lab.zig
zig run hashmap_churn_lab.zig
```

`run_lab.py` records: Zig path, Zig version, `zig env`, compile/run commands, exit statuses, and whether the harness was actually validated. If no Zig compiler is available, it records that honestly.

Tested with Zig 0.14.0 (Linux x86_64).

## Results

See [RESULTS.md](RESULTS.md) – includes summary tables, skip matrix, Zig version, compile/run status, and per-case artifacts (`results_rows.csv`, `results_rows.json`).

Correctness before speed. Naive policy (assuming insert-only generalizes, `remove` returns the value, `getOrPut` always overwrites safely, ephemeral string keys are fine, `clearRetainingCapacity` == `clearAndFree`, iteration order is stable, tiny timing proves production performance) – intentionally fails selected cases.

Safe observers only claim local, version-recorded observations and mark broad claims as context-only / not-tested.

## Files

- `generate_cases.py` – deterministic case generator
- `run_lab.py` – finds Zig, compiles/runs `hashmap_churn_lab.zig`, validates, writes results
- `hashmap_churn_lab.zig` – Zig stdlib-only harness (Auto-generated, committed)
- `cases.json` – 50 synthetic cases
- `RESULTS.md` – summary + Zig version + harness output
- `results_rows.csv` / `results_rows.json` – per-case/per-method
- `hn_thread_evidence.md` + `hn_nodes_sanitized.json` + `hn_comments_sanitized.txt` – auditable HN thread evidence
- `VERIFY.md` – fresh-clone verification transcript

## What this lab does NOT test

- Factor performance (not run)
- Huge 2M / 250M-action benchmark (not run)
- Zig stdlib patches (none)
- Back-shift deletion algorithms (context only)
- Stored hash-code designs (not tested)
- Concurrent hashmaps (not run)
- Compiler miscompilations (not tested)
- Production latency (not tested)
- Hashmap-design debates (not settled)

---

Toy lab – correctness before performance – synthetic keys only – local Zig version only.
