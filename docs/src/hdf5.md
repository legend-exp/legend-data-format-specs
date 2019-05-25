# HDF5 File Format [Incomplete]

HDF5 is used as the primary binary data format in LEGEND.

The following describes a mapping between the abstract data model and HDF5. This specifies the structure of the HDF5 implicitly, but precisely, for any data that conforms to the data model. The mapping purposefully uses only common and basic HDF5 features, to ensure it can be easily and reliably implemented in multiple programming languages.


## HDF5 datasets, groups and attributes

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

HDF Attributes:

* "datatype": "array<1>{array<1>{ELEMENT_TYPE}}"
* "cumsum_length": HDF5 object reference to the dataset that stores the cumulative sum of the size of the inner vectors.

Note: Instead of referring to the auxiliary dataset by name, a HDF5 dataset reference may be used in the future (still to be evaluated).


## Structs

Structs are stored as HDF5 groups. Fields that are structs themselves are stored as sub-groups, scalars and arrays as datasets. Groups and datasets in the group are named after the fields of the struct.

HDF Attributes:

* "datatype": "struct{FIELDNAME_1,FIELDNAME_2,...}"


## Tables

A Table are stored are group of datasets, each representing a column of the table.

HDF Attributes:

* "datatype": "table{COLNAME_1,COLNAME_2,...}"


## Enums

Enum values are stores as integer values, but with the "datatype" attribute: "enum{NAME=INT_VALUE,...}". So a vector of enum values will have a "datatype" attribute like "array<N>{enum{NAME=INT_VALUE,...}}""


# Values with physical units

For values with physical units, the dataset only contains the numerical values. The attribute "units" stores the unit information. The attribute value is the string representation of the common scientific notation for the unit. Unicode must not be used.

HDF Attributes:

* "units": e.g. "mm", "um", "keV"
