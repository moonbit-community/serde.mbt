// The benchmark corpus, shared so every benchmark measures the same bytes.
//
// The corpus is generated rather than committed: four shapes, built in memory
// from a seeded generator, so the numbers are reproducible by anyone running
// `moon bench` without a multi-megabyte fixture in the repository.
//
// The shapes exist because JSON performance is not one number. Each isolates a
// different part of the parser, and a change that helps one routinely does
// nothing for another — every measurement in this package's history has split
// along these lines.

///|
/// xorshift64*, so a corpus is reproducible without depending on an RNG.
priv struct Seed {
  mut state : UInt64
}

///|
fn Seed::next(self : Seed) -> UInt64 {
  let mut x = self.state
  x = x ^ (x >> 12)
  x = x ^ (x << 25)
  x = x ^ (x >> 27)
  self.state = x
  x * 0x2545F4914F6CDD1DUL
}

///|
fn Seed::below(self : Seed, bound : Int32) -> Int32 {
  (self.next() % bound.to_uint64()).to_int()
}

///|
const LETTERS : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

///|
fn Seed::word(self : Seed, len : Int32) -> String {
  let out = StringBuilder()
  for _ in 0..<len {
    out.write_char(LETTERS.unsafe_get(self.below(52)).to_char().unwrap())
  }
  out.to_string()
}

///|
/// Coordinate pairs with 17-significant-digit doubles: the shape of the
/// `json-serde` benchmark's canada.json, and the hard case for float parsing.
/// Roughly 90% numeric characters.
pub fn numbers(pairs : Int32) -> Bytes {
  let seed = Seed::{ state: 0x9E3779B97F4A7C15UL, }
  let out = StringBuilder()
  out <+ "{\"type\":\"numbers\",\"coordinates\":["
  for i in 0..<pairs {
    if i > 0 {
      out <+ ","
    }
    let lon = -180.0 + seed.below(360000000).to_double() / 1000000.0
    let lat = -90.0 + seed.below(180000000).to_double() / 1000000.0
    out <+ "[\{lon},\{lat}]"
  }
  out <+ "]}"
  @utf8.encode(out.to_string())
}

///|
/// Many small objects with short ASCII keys: the shape where identifier
/// handling dominates and string values barely register.
pub fn keys(rows : Int32) -> Bytes {
  let seed = Seed::{ state: 0x123456789ABCDEFUL, }
  let out = StringBuilder()
  out <+ "{\"type\":\"keys\",\"rows\":["
  for i in 0..<rows {
    if i > 0 {
      out <+ ","
    }
    out <+
      "{\"id\":\{seed.below(1000000)},\"kind\":\{seed.below(64)},\"count\":\{seed.below(4096)},\"flag\":\{seed.below(2) == 0}}"
  }
  out <+ "]}"
  @utf8.encode(out.to_string())
}

///|
/// Long string values: the shape that decides whether a vectorised scan pays,
/// since the measured crossover for SIMD is around sixteen bytes and object
/// keys sit well below it.
pub fn text(rows : Int32, len : Int32) -> Bytes {
  let seed = Seed::{ state: 0xFEEDFACECAFEBEEFUL, }
  let out = StringBuilder()
  out <+ "{\"type\":\"text\",\"rows\":["
  for i in 0..<rows {
    if i > 0 {
      out <+ ","
    }
    out <+
      "{\"title\":\"\{seed.word(len)}\",\"body\":\"\{seed.word(len * 4)}\"}"
  }
  out <+ "]}"
  @utf8.encode(out.to_string())
}

///|
/// Strings needing frequent escapes: the path that can take no fast route, so
/// it catches a change that speeds up the common case by slowing this one.
pub fn escapes(rows : Int32) -> Bytes {
  let seed = Seed::{ state: 0x0BADC0DEDEADBEEFUL, }
  let out = StringBuilder()
  out <+ "{\"type\":\"escapes\",\"rows\":["
  for i in 0..<rows {
    if i > 0 {
      out <+ ","
    }
    let text = StringBuilder()
    for _ in 0..<8 {
      text.write_string(seed.word(4))
      text.write_string(
        ["\\n", "\\t", "\\\"", "\\\\", "\\u0001"][seed.below(5)],
      )
    }
    out <+ "{\"v\":\"\{text.to_string()}\"}"
  }
  out <+ "]}"
  @utf8.encode(out.to_string())
}
