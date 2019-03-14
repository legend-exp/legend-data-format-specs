# HDF5 File Format [Incomplete]

HDF5 is used as the primary binary data format in LEGEND.

... limit use of HDF5 features to ...


## HDF5 datasets, groups and attributes

...

Different data types may be stored as an HDF5 dataset of the same type (e.g. a 2-dimensional dataset may represent a matrix or a vector of same-sized vectors). To make the HDF5 files self-documenting, the HDF5 attribute "datatype" is used to indicate the type semantics of datasets and groups.


## Abstract data model representation

The abstract data model is mapped as follows:


## Scalar values

Single scalar values are stored as 0-dimensional datasets

Attribute "datatype": "real", "string", "symbol", ...


## Arrays

### Flat arrays

Flat n-dimension arrays are stored as n-dimensional datasets

Attribute "datatype": "array<2>{ELEMENT_TYPE}"


### Fixed-sized arrays

...

Attribute "datatype": fixedsize_array<1>{ELEMENT_TYPE}"


### Arrays of arrays of same size

Nested arrays of dimensionality n, m, ... are stored as flat n+m+n dimensional datasets.

... attribute to denote dimensionality split ...

Attribute "datatype": "array_of_equalsized_arrays<N,M>{ELEMENT_TYPE}"


### Vectors of vectors of different size

Data of the inner arrays is flattened into a single 1-dimensional dataset. An auxiliary dataset stores the cumulative sum of the size of the inner arrays.

...

Attribute "datatype": "array<1>{array<1>{ELEMENT_TYPE}}"


## Structs

Structs are stored as HDF5 groups. Fields that are structs themselves are stored as sub-groups, scalars and arrays as datasets. Groups and datasets in the group are named after the fields of the struct.

Attribute "datatype": "struct{FIELDNAME_1,FIELDNAME_2,...}"


## Tables

...

Attribute "datatype": "table{FIELDNAME_1,FIELDNAME_2,...}"


# Units

... HDF5 dataset attribute "units" ...
