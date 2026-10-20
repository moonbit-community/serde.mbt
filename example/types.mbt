// Types whose implementations are generated, not written.
//
// Run `moonx Yu-zh/data/derive example` (or, inside this repo,
// `moon run derive -- example`) to regenerate `types_derive.mbt` after
// changing anything here.

///|
#data.derive(Serialize, Deserialize)
pub(all) struct Point {
  x : Int32
  y : Int32
  /// An `Option` field: absent and explicitly null both read back as `None`.
  label : String?
} derive(Eq, Debug)

///|
#data.derive(Serialize, Deserialize)
pub(all) struct Config {
  /// The wire name need not be a legal MoonBit identifier.
  #data.rename("max-retries")
  max_retries : Int32
  /// Never written, and filled from `Default` on the way back in.
  #data.skip
  cache_generation : Int32
} derive(Eq, Debug)

///|
#data.derive(Serialize, Deserialize)
pub(all) enum Shape {
  Empty
  Circle(Double)
  Rect(Double, Double)
  Tagged(name~ : String, size~ : Int32)
  #data.rename("Ellipse")
  Oval(Double, Double)
} derive(Eq, Debug)

///|
#data.derive(Serialize, Deserialize)
pub(all) struct Pair[A, B] {
  first : A
  second : B
} derive(Eq, Debug)

///|
#data.derive(Serialize, Deserialize)
pub(all) struct Rgb(Int32, Int32, Int32) derive(Eq, Debug)

///|
/// One positional field is a wrapper, not a tuple of one: it is written as the
/// value it wraps, and the name survives only for formats that record it.
#data.derive(Serialize, Deserialize)
pub(all) struct Meters(Double) derive(Eq, Debug)

///|
/// Nothing to write, so it goes out as unit.
#data.derive(Serialize, Deserialize)
pub(all) struct Marker {} derive(Eq, Debug)
