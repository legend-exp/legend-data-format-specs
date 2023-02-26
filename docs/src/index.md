# LEGEND Data Format Specifications

```@contents
```

## General considerations

In the interest of long-term data accessibility and to ensure compliance with [FAIR data principles](https://www.nature.com/articles/sdata201618),

* The number of different file formats should be kept to a reasonable minimum.
* Only mature, well documented and and widely supported data formats with mature implementations/bindings for multiple programming languages are used.
* Custom file formats are, if at all, only used for raw data produced by DAQ systems. As raw data tends to be archived long-term, any custom raw data formats must fulfil the following requirements:
    * A complete formal description of the format exists and is made publicly available under a license that allows for independent third-party implementations.
    * At least verified implementations is made publicly available under an open-source license.

## Choice of file formats

Depending on the kind of data, the following formats are preferred:

* Binary data: [HDF5](https://www.hdfgroup.org/solutions/hdf5)
* Metadata: [JSON](https://www.json.org)

## Abstract data model

LEGEND data should, wherever possible, be representable by a simple data model consisting of:

* Scalar values
* Vectors or higher-dimensional arrays. Arrays may be flat and contain scalar numerical values or nested and contain arrays, but must not contain structs or tables.
* Structs (resp. "Dicts" or named tuples) of named fields. Fields may contain scalar values, arrays or structs. In-memory representations of structs may be objects, named t
* Tables (a.k.a. "DataFrames"), represented by structs of column-vectors of equal length.

Numerical values may be accompanied by physical units.

A generic mapping of this data model must be defined for each file format used. The mapping must be self-documenting.
