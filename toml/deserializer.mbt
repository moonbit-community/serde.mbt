// `TomlDeserializer`, matching what `toml::de::Deserializer` is in Rust.
//
// The easier direction. `Deserializer` is a pull protocol, so a format may do
// whatever it likes before the first question arrives — and parsing the whole
// document up front is what `ValueDeserializer` already does. Nothing is bent
// to fit here; TOML simply has to be read whole, because a sub-table may be
// defined before its parent:
//
//   [a.b]
//   x = 1
//
//   [a]
//   y = 2      # `a`'s own key, after the whole [a.b] block
//
// A forward-only reader would have to answer for `a` before it had seen `y`.
// Parsing first makes the question disappear.

///|
/// Reads TOML.
///
/// Unlike `JsonDeserializer::new`, construction parses and so can fail: there
/// is no partial state to hand back.
struct TomlDeserializer {
  inner : @serde.ValueDeserializer
}

///|
pub fn TomlDeserializer::new(
  input : Bytes,
) -> TomlDeserializer raise @serde.DeError {
  { inner: @serde.ValueDeserializer::new(parse(input)), }
}

///|
/// Present for symmetry with the other formats, and trivially satisfied.
///
/// `JsonDeserializer::finish` exists to catch input after the value ends;
/// here the whole document was consumed by `new`, so trailing content was
/// already an error before any value was read.
pub fn TomlDeserializer::finish(_self : TomlDeserializer) -> Unit {

}

// ---- forwarding ----

///|
pub impl @serde.Deserializer for TomlDeserializer with fn path(self) {
  @serde.Deserializer::path(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_unit(self) {
  @serde.Deserializer::deserialize_unit(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_bool(self) {
  @serde.Deserializer::deserialize_bool(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_byte(self) {
  @serde.Deserializer::deserialize_byte(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_int16(
  self,
) {
  @serde.Deserializer::deserialize_int16(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_uint16(
  self,
) {
  @serde.Deserializer::deserialize_uint16(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_int(self) {
  @serde.Deserializer::deserialize_int(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_uint(self) {
  @serde.Deserializer::deserialize_uint(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_int64(
  self,
) {
  @serde.Deserializer::deserialize_int64(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_uint64(
  self,
) {
  @serde.Deserializer::deserialize_uint64(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_float(
  self,
) {
  @serde.Deserializer::deserialize_float(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_double(
  self,
) {
  @serde.Deserializer::deserialize_double(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_char(self) {
  @serde.Deserializer::deserialize_char(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_string(
  self,
) {
  @serde.Deserializer::deserialize_string(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_str_bytes(
  self,
) {
  @serde.Deserializer::deserialize_str_bytes(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_bytes(
  self,
) {
  @serde.Deserializer::deserialize_bytes(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_option(
  self,
) {
  @serde.Deserializer::deserialize_option(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_unit_struct(
  self,
  name,
) {
  @serde.Deserializer::deserialize_unit_struct(self.inner, name)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_newtype_struct(
  self,
  name,
) {
  @serde.Deserializer::deserialize_newtype_struct(self.inner, name)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_seq_begin(
  self,
) {
  @serde.Deserializer::deserialize_seq_begin(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_seq_next(
  self,
) {
  @serde.Deserializer::deserialize_seq_next(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_tuple_begin(
  self,
  len,
) {
  @serde.Deserializer::deserialize_tuple_begin(self.inner, len)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_tuple_next(
  self,
) {
  @serde.Deserializer::deserialize_tuple_next(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_tuple_end(
  self,
) {
  @serde.Deserializer::deserialize_tuple_end(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_tuple_struct_begin(
  self,
  name,
  len,
) {
  @serde.Deserializer::deserialize_tuple_struct_begin(self.inner, name, len)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_map_begin(
  self,
) {
  @serde.Deserializer::deserialize_map_begin(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_map_next_key(
  self,
) {
  @serde.Deserializer::deserialize_map_next_key(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_map_value(
  self,
) {
  @serde.Deserializer::deserialize_map_value(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_struct_begin(
  self,
  name,
  fields,
) {
  @serde.Deserializer::deserialize_struct_begin(self.inner, name, fields)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_field_name(
  self,
) {
  @serde.Deserializer::deserialize_field_name(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_field_value(
  self,
) {
  @serde.Deserializer::deserialize_field_value(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn skip_value(self) {
  @serde.Deserializer::skip_value(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_enum_begin(
  self,
  name,
  variants,
) {
  @serde.Deserializer::deserialize_enum_begin(self.inner, name, variants)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_unit_variant(
  self,
) {
  @serde.Deserializer::deserialize_unit_variant(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_newtype_variant(
  self,
) {
  @serde.Deserializer::deserialize_newtype_variant(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_enum_end(
  self,
) {
  @serde.Deserializer::deserialize_enum_end(self.inner)
}

///|
pub impl @serde.Deserializer for TomlDeserializer with fn deserialize_any(self) {
  @serde.Deserializer::deserialize_any(self.inner)
}

///|
/// Declared rather than inherited, for the same reason as on the writing side.
pub impl @serde.Deserializer for TomlDeserializer with fn is_human_readable(
  _self,
) {
  true
}
