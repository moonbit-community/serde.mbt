// Benchmarks against `moonbitlang/core/json`, on the shared corpus in
// `internal/corpus`.

///|
/// The corpora are valid by construction, and the parity test below proves it,
/// so a benchmark body may treat failure as unreachable rather than propagate
/// an error the timing loop cannot accept.
fn parse(doc : Bytes) -> @serde.Value {
  @json.from_bytes(doc) catch {
    _ => @serde.Null
  }
}

///|
fn write(value : @serde.Value) -> Bytes {
  @json.to_bytes(value) catch {
    _ => b""
  }
}

///|
fn parse_core(doc : Bytes) -> Json {
  @corejson.parse(@utf8.decode_lossy(doc)) catch {
    _ => Json::null()
  }
}

///|
/// Every corpus, at a size where a benchmark run stays quick.
fn corpora() -> Array[(String, Bytes)] {
  [
    ("numbers", @corpus.numbers(4000)),
    ("keys", @corpus.keys(4000)),
    ("text", @corpus.text(2000, 24)),
    ("escapes", @corpus.escapes(2000)),
  ]
}

///|
/// The corpus is only worth measuring on if it is being parsed correctly, so
/// parity with core's parser is asserted where the numbers are produced rather
/// than somewhere else in the suite.
test "every corpus round-trips identically to core" {
  for entry in corpora() {
    let (name, doc) = entry
    let ours : @serde.Value = @json.from_bytes(doc)
    let theirs = @corejson.parse(@utf8.decode_lossy(doc))
    let ours_text = @json.to_string(ours)
    let theirs_text = theirs.stringify()
    assert_eq(
      ours_text,
      theirs_text,
      msg="corpus `\{name}` disagrees with core",
    )
    // And the document survives a round-trip through our own writer.
    assert_eq((@json.from_bytes(@json.to_bytes(ours)) : @serde.Value), ours)
  }
}

///|
test "bench parse numbers" (it : @bench.T) {
  let doc = @corpus.numbers(4000)
  it.bench(() => it.keep(parse(doc)))
}

///|
test "bench parse keys" (it : @bench.T) {
  let doc = @corpus.keys(4000)
  it.bench(() => it.keep(parse(doc)))
}

///|
test "bench parse text" (it : @bench.T) {
  let doc = @corpus.text(2000, 24)
  it.bench(() => it.keep(parse(doc)))
}

///|
test "bench parse escapes" (it : @bench.T) {
  let doc = @corpus.escapes(2000)
  it.bench(() => it.keep(parse(doc)))
}

///|
test "bench write numbers" (it : @bench.T) {
  let value = parse(@corpus.numbers(4000))
  it.bench(() => it.keep(write(value)))
}

///|
test "bench write text" (it : @bench.T) {
  let value = parse(@corpus.text(2000, 24))
  it.bench(() => it.keep(write(value)))
}

// The core comparisons below are the yardstick. They parse the same bytes
// through `moonbitlang/core/json`, which must transcode to a `String` first
// because its parser takes one — that cost is charged here deliberately, since
// a file or a socket hands you bytes.

///|
test "bench parse numbers (core)" (it : @bench.T) {
  let doc = @corpus.numbers(4000)
  it.bench(() => it.keep(parse_core(doc)))
}

///|
test "bench parse keys (core)" (it : @bench.T) {
  let doc = @corpus.keys(4000)
  it.bench(() => it.keep(parse_core(doc)))
}

///|
test "bench parse text (core)" (it : @bench.T) {
  let doc = @corpus.text(2000, 24)
  it.bench(() => it.keep(parse_core(doc)))
}

///|
test "bench parse escapes (core)" (it : @bench.T) {
  let doc = @corpus.escapes(2000)
  it.bench(() => it.keep(parse_core(doc)))
}

// Core given a `String` it already holds, so the whole-document decode charged
// to it above is removed. This is the friendlier comparison for core, and the
// gap between each pair says how much of core's time that decode was.

///|
test "bench parse numbers (core, pre-decoded)" (it : @bench.T) {
  let text = @utf8.decode_lossy(@corpus.numbers(4000))
  it.bench(() => it.keep(@corejson.parse(text) catch { _ => Json::null() }))
}

///|
test "bench parse keys (core, pre-decoded)" (it : @bench.T) {
  let text = @utf8.decode_lossy(@corpus.keys(4000))
  it.bench(() => it.keep(@corejson.parse(text) catch { _ => Json::null() }))
}

///|
test "bench parse text (core, pre-decoded)" (it : @bench.T) {
  let text = @utf8.decode_lossy(@corpus.text(2000, 24))
  it.bench(() => it.keep(@corejson.parse(text) catch { _ => Json::null() }))
}

///|
test "bench parse escapes (core, pre-decoded)" (it : @bench.T) {
  let text = @utf8.decode_lossy(@corpus.escapes(2000))
  it.bench(() => it.keep(@corejson.parse(text) catch { _ => Json::null() }))
}
