// Typed benchmarks: the same corpora, read into structs instead of a tree.
//
// This is the comparison derive exists for. A derived `Deserialize` reads
// fields straight out of the bytes and never builds a document tree, while
// core's `derive(FromJson)` has to decode to a `String`, parse that into a
// `Json`, and only then walk the tree into the struct. Each type carries both
// derives so the two paths fill the identical shape.
//
// The types live in a test file, so the generator writes their implementations
// to `typed_bench_derive_test.mbt`. Re-run `moon run derive -- typed_bench`
// after changing them. They are `pub(all)` only because the generator's
// `extend` line for a private type is an unused binding, which `--deny-warn`
// rejects.

///|
#serde.derive(Deserialize)
pub(all) struct NumbersDoc {
  coordinates : Array[Array[Double]]
} derive(FromJson, Eq, Debug)

///|
#serde.derive(Deserialize)
pub(all) struct KeyRow {
  id : Int32
  kind : Int32
  count : Int32
  flag : Bool
} derive(FromJson, Eq, Debug)

///|
#serde.derive(Deserialize)
pub(all) struct KeysDoc {
  rows : Array[KeyRow]
} derive(FromJson, Eq, Debug)

///|
#serde.derive(Deserialize)
pub(all) struct TextRow {
  title : String
  body : String
} derive(FromJson, Eq, Debug)

///|
#serde.derive(Deserialize)
pub(all) struct TextDoc {
  rows : Array[TextRow]
} derive(FromJson, Eq, Debug)

///|
#serde.derive(Deserialize)
pub(all) struct EscapeRow {
  v : String
} derive(FromJson, Eq, Debug)

///|
#serde.derive(Deserialize)
pub(all) struct EscapesDoc {
  rows : Array[EscapeRow]
} derive(FromJson, Eq, Debug)

///|
/// As with `parse`, the corpora are valid by construction and the parity test
/// below proves both readers accept them, so failure is unreachable here.
fn[T : @serde.Deserialize] read_typed(doc : Bytes, fallback : T) -> T {
  @sjson.from_bytes(doc) catch {
    _ => fallback
  }
}

///|
fn[T : FromJson] read_core(doc : Bytes, fallback : T) -> T {
  @json.from_json(@json.parse(@utf8.decode_lossy(doc))) catch {
    _ => fallback
  }
}

///|
test "typed reads agree with core's FromJson" {
  let numbers = @corpus.numbers(4000)
  let ours : NumbersDoc = @sjson.from_bytes(numbers)
  let theirs : NumbersDoc = @json.from_json(
    @json.parse(@utf8.decode_lossy(numbers)),
  )
  assert_eq(ours.coordinates.length(), 4000)
  assert_eq(ours, theirs)
  let keys = @corpus.keys(4000)
  let ours : KeysDoc = @sjson.from_bytes(keys)
  let theirs : KeysDoc = @json.from_json(@json.parse(@utf8.decode_lossy(keys)))
  assert_eq(ours.rows.length(), 4000)
  assert_eq(ours, theirs)
  let text = @corpus.text(2000, 24)
  let ours : TextDoc = @sjson.from_bytes(text)
  let theirs : TextDoc = @json.from_json(@json.parse(@utf8.decode_lossy(text)))
  assert_eq(ours.rows.length(), 2000)
  assert_eq(ours, theirs)
  let escapes = @corpus.escapes(2000)
  let ours : EscapesDoc = @sjson.from_bytes(escapes)
  let theirs : EscapesDoc = @json.from_json(
    @json.parse(@utf8.decode_lossy(escapes)),
  )
  assert_eq(ours.rows.length(), 2000)
  assert_eq(ours, theirs)
}

///|
test "bench typed numbers" (it : @bench.T) {
  let doc = @corpus.numbers(4000)
  it.bench(() => it.keep(read_typed(doc, NumbersDoc::{ coordinates: [], })))
}

///|
test "bench typed keys" (it : @bench.T) {
  let doc = @corpus.keys(4000)
  it.bench(() => it.keep(read_typed(doc, KeysDoc::{ rows: [], })))
}

///|
test "bench typed text" (it : @bench.T) {
  let doc = @corpus.text(2000, 24)
  it.bench(() => it.keep(read_typed(doc, TextDoc::{ rows: [], })))
}

///|
test "bench typed escapes" (it : @bench.T) {
  let doc = @corpus.escapes(2000)
  it.bench(() => it.keep(read_typed(doc, EscapesDoc::{ rows: [], })))
}

///|
test "bench typed numbers (core FromJson)" (it : @bench.T) {
  let doc = @corpus.numbers(4000)
  it.bench(() => it.keep(read_core(doc, NumbersDoc::{ coordinates: [], })))
}

///|
test "bench typed keys (core FromJson)" (it : @bench.T) {
  let doc = @corpus.keys(4000)
  it.bench(() => it.keep(read_core(doc, KeysDoc::{ rows: [], })))
}

///|
test "bench typed text (core FromJson)" (it : @bench.T) {
  let doc = @corpus.text(2000, 24)
  it.bench(() => it.keep(read_core(doc, TextDoc::{ rows: [], })))
}

///|
test "bench typed escapes (core FromJson)" (it : @bench.T) {
  let doc = @corpus.escapes(2000)
  it.bench(() => it.keep(read_core(doc, EscapesDoc::{ rows: [], })))
}
