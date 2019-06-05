# HDF5 File Format [Incomplete]

HDF5 is used as the primary binary data format in LEGEND.

The following describes a mapping between the abstract data model and HDF5. This specifies the structure of the HDF5 implicitly, but precisely, for any data that conforms to the data model. The mapping purposefully uses only common and basic HDF5 features, to ensure it can be easily and reliably implemented in multiple programming languages.


## HDF5 datasets, groups and attributes

Different data types may be stored as an HDF5 dataset of the same type (e.g. a 2-dimensional dataset may represent a matrix or a vector of same-sized vectors). To make the HDF5 files self-documenting, the HDF5 attribute "datatype" is used to indicate the type semantics of datasets and groups.


## Abstract data model representation

The abstract data model is mapped as follows:


### Scalar values

Single scalar values are stored as 0-dimensional datasets

Attribute "datatype": "real", "string", "symbol", ...


### Arrays

#### Flat arrays

Flat n-dimension arrays are stored as n-dimensional datasets

Attribute "datatype": "array<2>{ELEMENT_TYPE}"


#### Fixed-sized arrays

...

Attribute "datatype": fixedsize_array<1>{ELEMENT_TYPE}"


#### Arrays of arrays of same size

Nested arrays of dimensionality n, m, ... are stored as flat n+m+n dimensional datasets.

... attribute to denote dimensionality split ...

Attribute "datatype": "array_of_equalsized_arrays<N,M>{ELEMENT_TYPE}"


#### Vectors of vectors of different size

A Vector of vectors is stored as a group that contains two datasets:

* A 1-dimensional dataset "flattened_data" that stores the concatenation of all vectors into a single vector.
* A 1-dimensional dataset "cumulative_length" that stores the cumulative sum of the length of all vectors.

HDF5 Attributes of the group:

* "datatype": "array<1>{array<1>{ELEMENT_TYPE}}"

The two datasets in the group also have "datatype" (and possibly "units") attributes that match their content.


### Structs

Structs are stored as HDF5 groups. Fields that are structs themselves are stored as sub-groups, scalars and arrays as datasets. Groups and datasets in the group are named after the fields of the struct.

HDF5 Attributes:

* "datatype": "struct{FIELDNAME_1,FIELDNAME_2,...}"


### Tables

A Table are stored are group of datasets, each representing a column of the table.

HDF5 Attributes:

* "datatype": "table{COLNAME_1,COLNAME_2,...}"


### Enums

Enum values are stores as integer values, but with the "datatype" attribute: "enum{NAME=INT_VALUE,...}". So a vector of enum values will have a "datatype" attribute like "array<N>{enum{NAME=INT_VALUE,...}}""


### Values with physical units

For values with physical units, the dataset only contains the numerical values. The attribute "units" stores the unit information. The attribute value is the string representation of the common scientific notation for the unit. Unicode must not be used.

HDF5 Attributes:

* "units": e.g. "mm", "ns", "keV"


## Example

A table "daqdata" with columns for channel number, event type, energy (online reco) and waveform would be written to an HDF5 file like this:

* Group "/daqdata"
    * Attribute "datatype": "table{channel,evttype,daqclk,energy,waveform}"

    * Dataset "/daqdata/channel" (1-dim, `int32`)
        * Attribute "datatype": "array<1>{real}"

    * Dataset "/daqdata/evttype" (1-dim, `int32`)
        * Attribute "datatype": "array<1>{enum{evt_real=1,evt_pulser=2,evt_baseline=4}}"

    * Dataset "/daqdata/daqclk" (1-dim, `uint64`)
        * Attribute "datatype": "array<1>{real}"

    * Dataset "/daqdata/energy" (1-dim, `int32`)
        * Attribute "datatype": "array<1>{real}"

    * Group "/daqdata/waveform"
        * Attribute "datatype": "table{t0,dt,values}"

        * Dataset "/daqdata/waveform/t0" (1-dim, `int32`)
            * Attribute "datatype": "array<1>{real}"
            * Attribute "units": "ns"

        * Dataset "/daqdata/waveform/dt" (1-dim, `int32`)
            * Attribute "datatype": "array<1>{real}"
            * Attribute "units": "ns"

        * Group "/daqdata/waveform/values"
            * Attribute "datatype": "array<1>{array<1>{real}}"

            * Dataset "/daqdata/waveform/values/flattened_data" (1-dim, `int32`)
                * Attribute "datatype": "array<1>{real}"

            * Dataset "/daqdata/waveform/values/cumulative_length" (1-dim, `int64`)
                * Attribute "datatype": "array<1>{real}"

The actual numeric types of the datasets will be application-dependent.
