# HN Thread Evidence – zig-stdlib-hashmap-churn-footgun-lab

HN story: https://news.ycombinator.com/item?id=38224033  
Title: "Hashmaps in Factor are faster than in Zig"  
Score: 180, Descendants: 61  
URL: https://re.factorcode.org/2023/11/factor-is-faster-than-zig.html

Accessed via the bundled Hacker News CLI (`openclaw skills hackernews`), 2026-07-08.

Full comment tree saved as:
- `hn_nodes_sanitized.json` (66 nodes, raw HN Firebase API output)
- `hn_comments_sanitized.txt` (text-only, tags stripped)

## Thread sentiment summary (used for README)

Commenters debated the Zig `std.HashMap` churn slowdown reported in the linked Factor article (repeated insert/delete workload, tombstone accumulation in linear probing).

Key themes from the actual thread:

- **Tombstones / deletion churn:** Top comment (senderista) – "I don't see a compelling reason to use tombstones in linear probing except in a concurrent context (where you can't move entries around). The tombstone-free deletion algorithm is quite simple". Others discussed trailing-tombstone deletion, and a heuristic for avoiding most tombstones when load factor isn't too high (arxiv.org/pdf/1808.04602.pdf).

- **Back-shift deletion / rehashing:** JacksonAllan replied that back-shift deletion requires rehashing every candidate to avoid shifting beyond its home bucket (unlike Robin Hood). "Hence, it is pretty unsuitable when the hash function is expensive, unless we're storing hash codes or keeping the load factor very low."

- **Expensive hash functions / load factor:** String-key benchmarks at 0.95 load factor were cited. Robin Hood maps "spike upwards dramatically as the load factor gets high, becoming as much as 5-6 times slower at 0.95 vs 0.5". SIMD maps (Boost, Absl) and a Fastmap design were "mostly immune to load factor".

- **Concurrency / moving entries:** senderista: "The main tradeoff is concurrency: it's difficult to safely read a hash table while its entries are being concurrently relocated. Another tradeoff is (probably) higher average latency (but worst-case latency is much better since there's no global rehashing required)."

- **ArrayHashMap:** Andy Kelley (Zig creator, user AndyKelley) commented directly: "I personally have two habits that made me not notice: 1. I generally prefer ArrayHashMap 2. I tend to not delete things from hash maps"

- **Multiple hash-table types in Zig:** tialaramex: "My impression from the article is that Zig provides several different hashtables and not all of them are broken in this way." Discussion about stdlib container design tradeoffs, Rust LinkedList analogy.

- **Surprise at stdlib issue:** lll-o-lll: "Hash maps are such a fundamentally important data structure that it comes as a surprise that the Zig implementation is so broken. Good to see it's getting fixed, but surprising that this wasn't detected before."

- **Pre-1.0 / maturity expectations:** brabel: "When you use a language that's in alpha- (maybe beta- now?) stage, this kind of thing should be expected. Even with the latest version of Zig, perfectly correct programs can segfault due to miscompilation, so performance issues are not even the biggest worry you should have."

- **TigerBeetle:** shemii: "Actually it seems according to the issue that TigerBeetle (one of the bigger zig projects out there) noticed this issue" – links to ziglang/zig#17851 and tigerbeetle/tigerbeetle#1191.

- **Compiler / language stability:** Above brabel comment, plus discussion about Bun reaching 1.0 while being written in Zig which hasn't reached 1.0. Reply: Bun can work around compiler bugs with close to 100% test coverage, but "it's a risky bet".

- **Benchmark scope caveat:** murkt: "Not that many hashmaps see hundreds of millions of entries in their lifetime. Given that Zig isn't widely used, it's probable that noone has really stumbled upon this behaviour in a non-benchmark setting." liftm linked Rust's accidentally-quadratic hash iteration reinsertion – "surprisingly common for fledgling programming languages".

- **"my tiny local churn benchmark saw X" vs global claims:** Extensive sub-thread between senderista and JacksonAllan debating Robin Hood vs BLP (bidirectional linear probing), benchmark methodology, load factor measurement intervals, key types (integer keys favor open-addressing), hash function cost, moving elements cost, cache misses, JVM microbenchmark trust issues. Both agreed "benchmarking hash tables is pretty difficult because there's many variables that affect their performance and it's hard to cover all use cases."

All of the above is reflected in this lab's README "Hacker News thread sentiments" section. No quotes are invented – summaries are derived from the saved HN API output.
