# Metadata

LEGEND metadata is stored in [YAML](https://www.yaml.org) or
[JSON](https://www.json.org). Formatting guidelines:

* In general, field names should be interpretable as valid variable names in
  common programming languages (e.g. use underscores (`_`) instead of dashes
  (`-`))
* Snake casing is preferred, i.e. separating non-capitalized words with
  underscores (`_`).

## Physical units

Physical units should be specified as part of a field name by adding
`_in_<units>` at the end. For example:

```yaml
radius_in_mm: 11,
temperature_in_K: 7
```

## Specifying metadata validity in time (and system)

LEGEND adopts the YAML format to specify the validity of metadata (for
example a data production configuration that varies in time or according to the
data taking mode).

A `validity.yaml` file is essentially a collection of records. Each record is
formatted as follows:

```yaml
- valid_from: TIMESTAMP
  category: DATATYPE
  mode: MODE
  apply:
  - FILE1.yaml
  - FILE2.yaml
  - ...
```

where:

* `TIMESTAMP` is a LEGEND-style timestamp `yyymmddThhmmssZ` (in UTC time),
  also used to label data cycles, specifying the start of validity
* `DATATYPE` is the data type (`all`, `phy`, `cal`, `lar`, etc.) to which the
  metadata applies. If omitted, it should default to `all`.
* `MODE` can be `reset`, `append`, `remove`, `replace`. If omitted and this is
  the first record in the file, defaults to `reset`, otherwise defaults to
  `append`.
* `apply` takes an array of metadata files, to be comined into the main
  metadata object depending on `mode` (see below). In general, the files are
  combined "in cascade" (precedence order first to last) into the final metadata
  object.

The above example record, if appearing at the top of the validity file,
translates to:

> Combine `FILE1`, `FILE2` etc. into a single metadata object. Fields in
> `FILE2` override fields in `FILE1`. This metadata applies only to `DATATYPE`
> data and is valid from `TIMESTAMP` on.

Modes:

* `reset`: remove all entries from the existing metadata file list before
  applying (in cascade) the ones listed in `apply`.
* `append`: append (in cascade) files listed in `apply` to the current file
  list.
* `remove`: remove the file(s) listed in `apply` from the current file list.
* `replace`: replace, in the current fule list, the first file listed in
  `apply` with the second one.
