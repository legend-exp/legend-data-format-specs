# Metadata

LEGEND metadata is stored in [JSON](https://www.json.org). Formatting guidelines:

* In general, field names should be interpretable as valid variable names in
  common programming languages (e.g. use underscores (`_`) instead of dashes
  (`-`))

## Physical units

Physical units should be specified as part of a field name by adding
`_in_<units>` at the end. For example:

```json
{
  "radius_in_mm": 11,
  "temperature_in_K": 7
}
```

## Specifying metadata validity in time (and system)

LEGEND adopts a custom file format to specify the validity of metadata (for
example a data production configuration that varies in time or according to the
data taking mode), called JSONL (JSON + Legend).

A JSONL file is essentially a collection of JSON-formatted records. Each record
is formatted as follows:

```json
{"valid_from": "TIMESTAMP", "category": "DATATYPE", "apply": ["FILE1", "FILE2", ...]}
```

where:

* `TIMESTAMP` is a LEGEND-style timestamp `yyymmddThhmmssZ` (in UTC time),
  also used to label data cycles, specifying the start of validity
* `DATATYPE` is the data type (`all`, `phy`, `cal`, `lar`, etc.) to which the
  metadata applies
* `apply` takes an array of metadata files, to be combined "in cascade"
  (precedence order right to left) into the final metadata object

The record above translates to:

> Combine `FILE1`, `FILE2` etc. into a single metadata object. Fields in
> `FILE2` override fields in `FILE1`. This metadata applies only to `DATATYPE`
> data and is valid from `TIMESTAMP` on.

Records are stored in JSONL files one per line, without special delimiters:

```json
{"valid_from": "TIMESTAMP1", "category": "DATATYPE1", "apply": ["FILE1", "FILE2", ...]}
{"valid_from": "TIMESTAMP2", "category": "DATATYPE2", "apply": ["FILE3", "FILE4", ...]}
...
```
