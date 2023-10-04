# HDF5 File Format

```@contents
Pages = ["hdf5.md"]
Depth = 5
```

[HDF5](https://www.hdfgroup.org/solutions/hdf5) is used as the primary binary data format in LEGEND.

The following describes a mapping between the abstract data model and HDF5. This specifies the structure of the HDF5 implicitly, but precisely, for any data that conforms to the data model. The mapping purposefully uses only common and basic HDF5 features, to ensure it can be easily and reliably implemented in multiple programming languages.

## HDF5 datasets, groups and attributes

Different data types may be stored as an HDF5 dataset of the same type (e.g. a 2-dimensional dataset may represent a matrix or a vector of same-sized vectors). To make the HDF5 files self-documenting, the HDF5 attribute `datatype` is used to indicate the type semantics of datasets and groups.

## Basic types

!!! note "Quick reference"
    | Data type                                                            | `datatype` attribute                              |
    | -------------------------------------------------------------------- | ------------------------------------------------- |
    | Scalar                                                               | `real`, `string`, `symbol`, `bool`, ...           |
    | Flat ``n``-dimensional array                                         | `array<n>{ELTYPE}`                                |
    | Fixed-sized ``n``-dimensional array                                  | `fixedsize_array<n>{ELTYPE}`                      |
    | ``n``-dimensional array of ``m``-dimensional arrays of the same size | `array_of_equalsized_arrays<n,m>{ELTYPE}`         |
    | Vector of vectors of different size                                  | `array<1>{array<1>{ELTYPE}}`                      |
    | Struct                                                               | `struct{FIELDNAME_1,FIELDNAME_2,...}`             |
    | Table                                                                | `table{COLNAME_1,COLNAME_2,...}`                  |
    | Enum                                                                 | `enum{NAME_1=INT_VAL_1,NAME_2=INT_VAL_2,...}`     |
    | Encoded vector of vectors of different size                          | `array<1>{encoded_array<1>{ELTYPE}}`              |
    | Encoded array of arrays of the same size                             | `array_of_equalsized_encoded_arrays<n,m>{ELTYPE}` |

The abstract data model is mapped as follows:

### Scalar

Single scalar values are stored as 0-dimensional HDF5 datasets.

    DATASET "scalar" {
        ATTRIBUTE "datatype" = "real"
        DATA = 3.14
    }

### Array

Collections of values. The `datatype` attribute will always contain `array`.

Flat ``n``-dimensional arrays are stored as ``n``-dimensional HDF5 datasets.

    DATASET "unixtime" {
        ATTRIBUTE "datatype" = "array<1>{real}"
        ATTRIBUTE "units" = "ns"
        DATA = [1.44061e+09, 1.44061e+09, ...]
    }

#### Fixed-sized array

!!! warning
    Undocumented

#### Array of equal-sized arrays

``n-``dimensional arrays of ``m``-dimensional arrays of the same size are stored as flat ``n+m`` dimensional datasets.

    DATASET "waveform_values" {
        ATTRIBUTE "datatype" = "array<1,1>{real}"
        DATA = [[13712, 13712, 13683, ..., 15400]
                [13072, 13072, 12992, ..., 18806]
                ...
                [16918, 16918, 16962, ..., 18933]]
    }

#### Vector of vectors

A vector of vectors of unqual sizes is stored as an HDF5 group that contains two datasets:

* A 1-dimensional dataset `flattened_data` that stores the concatenation of all vectors into a single vector.
* A 1-dimensional dataset `cumulative_length` that stores the cumulative sum of the length of all vectors.

The two datasets in the group also have `datatype` (and possibly `units`) attributes that match their content.

    GROUP "vector_of_vectors" {
        ATTRIBUTE "datatype" = "array<1>{array<1>{real}}"
        DATASET "flattened_data" {
            ATTRIBUTE "datatype" = "array<1>{real}"
            DATA = [1, 4, 3, ...]
        }
        DATASET "cumulative_length" {
            ATTRIBUTE "datatype" = "array<1>{real}"
            DATA = [3, 10, 34, ...]
        }
    }

### Struct

Structs are stored as HDF5 groups. Fields that are structs themselves are stored as sub-groups, scalars and arrays as datasets. Groups and datasets in the group are named after the fields of the struct.

    GROUP "struct" {
        ATTRIBUTE "datatype" = "struct{array1,flag2,obj3}
        DATASET "array1" {
            ATTRIBUTE "datatype" = "array<1>{real}"
            DATA = [5, 23, 4, ...]
        }
        DATASET "flag2" {
            ATTRIBUTE "datatype" = "bool"
            DATA = 0
        }
        GROUP "obj3" {
            ATTRIBUTE "datatype" = "struct{obj2}"
            ...
        }
    }

### Table

A table is struct where all the fields (also called "columns") have the same length. It is stored as a group of datasets, each representing a column of the table.

    GROUP "waveform" {
        ATTRIBUTE "datatype" = "table{t0,dt,values}"
        DATASET "dt" {
            ATTRIBUTE "datatype" = "array<1>{real}"
            ATTRIBUTE "units" = "ns"
            DATA = [10, 10, 10, ...]
        }
        DATASET "t0" {
            ATTRIBUTE "datatype"= "array<1>{real}"
            ATTRIBUTE "units" = "ns"
            DATA = [76420, 76420, 76420, ...]
        }
        GROUP "values" {
            ATTRIBUTE "datatype"= "array<1>{array<1>{real}}"
            DATASET "cumulative_length" {
                ATTRIBUTE "datatype" = "array<1>{real}"
                DATA = [1000, 2000, 3000, 4000, ...]
            }
            DATASET "flattened_data" {
                ATTRIBUTE "datatype" = "array<1>{real}"
                DATA = [14440, 14442, 14441, 14434, ...]
            }
        }
    }

### Enum

Enum values are stored as integer values, but with the `datatype` attribute: `enum{NAME=INT_VALUE,...}`

    DATASET "evttype" {
        ATTRIBUTE "datatype" = "array<1>{enum{evt_real=1,evt_pulser=2,evt_baseline=4}}"
        DATA = [1, 2, 1, 1, ...]
    }

### Values with physical units

For values with physical units, the dataset only contains the numerical values. The attribute `units` stores the unit information. Its value is the string representation of the common scientific notation for the unit. Unicode must not be used.

    DATASET "energy" {
        ATTRIBUTE "datatype" = "array<1>{real}"
        ATTRIBUTE "units" = "keV"
        DATA = {2453.25, 234.34, 2039.22, ...]
    }

## Encoded arrays

Specialized structures should exist to represent encoded data. An important application is for lossless compression of waveform vectors (see [Data Compression](@ref)). All HDF5 objects representing encoded arrays must carry (in addition to the usual `datatype`) a `codec` string attribute holding the encoder algorithm identifier (a list can be found in [Data Compression](@ref)) in order to be decoded. Some decoders might require additional mandatory attributes.

### Encoded [Array of equal-sized arrays](@ref)

An encoded array of equal-sized arrays is stored as an HDF5 group that contains two datasets:

* `encoded_data`: the encoded data, for example a [Vector of vectors](@ref). The type of the elements must be unsigned 8-bit integers (i.e. bytes)
* `decoded_size`: 1-dimensional dataset that stores the lengths of the original (decoded) arrays

Example of encoded waveform values, where `encoded_data` is an `array<1>{array<1>{real}}` of bytes.

    GROUP "waveform_values" {
        ATTRIBUTE "datatype" = "array_of_encoded_equalsized_arrays<1,1>{real}"
        ATTRIBUTE "codec" = "radware_sigcompress"
        ATTRIBUTE "codec_shift" = -32768
        GROUP "encoded_data" {
            ATTRIBUTE "datatype" = "array<1>{array<1>{real}}"
            DATASET "cumulative_length" {
                ATTRIBUTE "datatype" = "array<1>{real}"
                DATA = [...]
            }
            DATASET "flattened_data" {
                ATTRIBUTE "datatype" = "array<1>{real}"
                DATA = [...]
            }
        }
        DATASET "decoded_size" {
            ATTRIBUTE "datatype" = "real"
            DATA = ...
        }

### Encoded [Vector of vectors](@ref)

An encoded vector of vectors of unqual sizes is stored as an HDF5 group that contains two datasets:

* `encoded_data`: the encoded data, for example a [Vector of vectors](@ref). The type of the elements must be unsigned 8-bit integers (i.e. bytes)
* `decoded_size`: 0-dimensional (i.e. scalar) dataset that stores the length of the original (decoded) arrays

## Histograms

A 1-dimensional histogram will be written as

    GROUP "hist_1d" {
        ATTRIBUTE "datatype" = "struct{binning,weights,isdensity}"
        GROUP "binning" {
            ATTRIBUTE "datatype" = "struct{axis_1}"
            GROUP "axis_1" {
                ATTRIBUTE "datatype" = "struct{binedges,closedleft}"
                GROUP "binedges" {
                    ATTRIBUTE "datatype" = "struct{first,last,step}"
                    DATASET "first" {
                        ATTRIBUTE "datatype" = "real"
                        DATA = 0
                    }
                    DATASET "last" {
                        ATTRIBUTE "datatype" = "real"
                        DATA = 3000
                    }
                    DATASET "step" {
                        ATTRIBUTE "datatype" = "real"
                        DATA = 1
                    }
                }
                DATASET "closedleft" {
                    ATTRIBUTE "datatype" = "bool"
                    DATA = 1
                }
            }
        }
        DATASET "isdensity" {
            ATTRIBUTE "datatype" = "bool"
            DATA = 0
        }
        DATASET "weights" {
            ATTRIBUTE "datatype" = "array<1>{real}"
            DATA = [...]
        }
    }

Multi-dimensional histograms will have groups `axis_2`, etc., with a multi-dimensional array as the value of dataset `weights`.
