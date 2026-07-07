# HN Thread Evidence – zig-stdlib-hashmap-churn-footgun-lab

**Thread:** "Hashmaps in Factor are faster than in Zig"  
**HN ID:** 38224033  
**URL:** https://news.ycombinator.com/item?id=38224033  
**Accessed via:** Hacker News Firebase API CLI (`openclaw/dist/extensions/hackernews/skills/hackernews/hackernews get-item`)  
**Date accessed:** 2026-07-07

Raw thread JSON saved as: `hn_nodes_sanitized.json`

## Sentiment summary (own words, no invented quotes)

The linked article found Zig std.HashMap getting slower over time under repeated insert/remove churn, attributed to tombstone accumulation in its linear-probing table. HN discussion expanded well beyond "Factor vs Zig":

- **Tombstones / deletion churn:** Multiple commenters discussed why repeated remove/reinsert causes slowdown, tombstone buildup, and why deletion is the hard part of open-addressing hash tables.
- **Back-shift deletion / rehashing:** Commenters debated tombstone-free deletion (back-shift / backward-shift deletion, Robin Hood / backward linear probing), tradeoffs of moving entries on delete vs leaving tombstones, and rehashing costs.
- **Expensive hash functions / stored hashes:** Discussion about storing hash codes with entries to avoid recomputing expensive hashes, truncated hash codes, reversible hashes for integer keys, and the tradeoff of extra memory.
- **Load factor:** Load factor came up as a key tuning knob affecting probe length and tombstone density.
- **Concurrency / moving entries:** One major tradeoff repeatedly noted: back-shift deletion / compacting entries makes concurrent readers unsafe, since entries move. Tombstones avoid moving live objects, which helps concurrency.
- **ArrayHashMap:** Andy Kelley (Zig creator) commented that he personally prefers ArrayHashMap and tends not to delete from hash maps – explaining why the churn footgun wasn't noticed earlier. Other commenters noted Zig provides several *different* hash tables, not one universal table.
- **Surprise at stdlib issue:** Some commenters were surprised a stdlib hashmap could have this performance cliff. Others responded that Zig is pre-1.0 / still maturing, and that hashmap edge cases are common in young languages (Rust quadratic reinsertion bug was cited).
- **TigerBeetle:** TigerBeetle (a major Zig project) was noted as having hit this issue in production, filed at ziglang/zig#17851 and tigerbeetle/tigerbeetle#1191.
- **Compiler / language stability:** Discussion branched into Zig compiler maturity – miscompilation bugs still open, Zig being pre-1.0, and how Bun shipped 1.0 while built on pre-1.0 Zig. Versioning / SemVer expectations came up.
- **"My tiny benchmark saw X" vs global claims:** The OP (mrjbq7, Factor maintainer) clarified the article was about a specific repeated insert/delete workload, and that after a fix, Zig's HashMap was 50% faster than Factor's. Commenters generally treated this as a workload-specific footgun, not proof that "all Zig hash maps are slow" or "Factor is universally faster."

The discussion was technical and nuanced – about deletion algorithms, rehashing, hash code storage, load factor, container design tradeoffs, stdlib maturity expectations, and the difference between a local churn benchmark and production hashmap performance claims.

This lab does NOT reproduce the 2M-entry / 250M-action Factor benchmark, does NOT patch Zig stdlib, does NOT test Factor, and does NOT claim production performance conclusions. It is a tiny toy correctness/safety lab turning the HN debate themes into reproducible local observations.

## Evidence artifacts committed

- `hn_thread_evidence.md` (this file)
- `hn_nodes_sanitized.json` – full thread tree from HN API, sanitized (ids, authors, text, timestamps)
- `hn_comments_sanitized.txt` – (generated below if missing)
