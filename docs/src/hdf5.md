# HDF5 File Format

[HDF5](https://www.hdfgroup.org/solutions/hdf5) is used as the primary binary data format in LEGEND.

The following describes a mapping between the abstract data model and HDF5. This specifies the structure of the HDF5 implicitly, but precisely, for any data that conforms to the data model. The mapping purposefully uses only common and basic HDF5 features, to ensure it can be easily and reliably implemented in multiple programming languages.

## HDF5 datasets, groups and attributes

Different data types may be stored as an HDF5 dataset of the same type (e.g. a 2-dimensional dataset may represent a matrix or a vector of same-sized vectors). To make the HDF5 files self-documenting, the HDF5 attribute `datatype` is used to indicate the type semantics of datasets and groups.

## Abstract data model representation

!!! note "Quick reference"
    | Data type | `datatype` attribute |
    | ---       | ---       |
    | Scalar | `real`, `string`, `symbol`, `bool`, ... |
    | Flat ``n``-dimensional array | `array<n>{ELEMENT_DTYPE}` |
    | Fixed-sized ``n``-dimensional array | `fixedsize_array<n>{ELEMENT_DTYPE}` |
    |``n``-dimensional array of ``m``-dimensional arrays of the same size | `array_of_equalsized_arrays<n,m>{ELEMENT_DTYPE}` |
    | Vector of vectors of different size | `array<1>{array<1>{ELEMENT_DTYPE}}` |
    | Struct | `struct{FIELDNAME_1,FIELDNAME_2,...}` |
    | Table | `table{COLNAME_1,COLNAME_2,...}` |
    | Enum | `enum{NAME_1=INT_VAL_1,NAME_2=INT_VAL_2,...}` |

The abstract data model is mapped as follows:

### Scalars

Single scalar values are stored as 0-dimensional HDF5 datasets.

    DATASET "scalar" {
        ATTRIBUTE "datatype" = "real"
        DATA = 3.14
    }

### Arrays

Collections of values. The `datatype` attribute will always contain `array`.

#### Flat arrays

Flat ``n``-dimensional arrays are stored as ``n``-dimensional HDF5 datasets.

    DATASET "unixtime" {
        ATTRIBUTE "datatype" = "array<1>{real}"
        ATTRIBUTE "units" = "ns"
        DATA = [1.44061e+09, 1.44061e+09, ...]
    }

#### Fixed-sized arrays

!!! warning
    Undocumented

#### Arrays of arrays of same size

``n-``dimensional arrays of ``m``-dimensional arrays of the same size are stored as flat ``n+m`` dimensional datasets.

    DATASET "waveform_values" {
        ATTRIBUTE "datatype" = "array<1,1>{real}"
        DATA = [[13712, 13712, 13683, ..., 15400]
                [13072, 13072, 12992, ..., 18806]
                ...
                [16918, 16918, 16962, ..., 18933]]
    }

#### Vectors of vectors of different size

A vector-of-vectors is stored as an HDF5 group that contains two datasets:

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

### Structs

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

### Tables

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

### Enums

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

## Waveform tables

Waveform tables are regular [Tables](@ref) with three columns (`table{t0,dt,values}`):

* `t0`: the waveform time offsets (ralative to a certain global reference), optionally with units
* `dt`: the waveform sampling periods, optionally with units
* `values`: the waveform values. May be [Arrays of arrays of same size](@ref), [Vectors of vectors of different size](@ref), etc.

Example:

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

## DAQ data example

A table `daqdata` with columns for channel number, unix-time, event type, veto and waveform will be written to an HDF5 file like this:

    GROUP "daqdata" {
        ATTRIBUTE "datatype" = "table{ch,unixtime,evttype,veto,waveform}"
        DATASET "ch" {
            ATTRIBUTE "datatype" = "array<1>{real}"
            DATA = [1, 3, 2, 4, ...]
        }
        DATASET "unixtime" {
            ATTRIBUTE "datatype" = "array<1>{real}"
            DATA = [1.44061e+09, 1.44061e+09, ...]
        }
        DATASET "evttype" {
            ATTRIBUTE "datatype" = "array<1>{enum{evt_undef=0,evt_real=1,evt_pulser=2,evt_mc=3,evt_baseline=4}}"
            DATA = [1, 2, 1, 1, ...]
        }
        DATASET "veto" {
            DATA = [1, 1, 0, 0, ...]
            ATTRIBUTE "datatype" = "array<1>{bool}"
            DATA = [1, 1, 0, 0, ...]
        }
        GROUP "waveform" {
            ATTRIBUTE "datatype" = "table{t0,dt,values}"
            DATASET "dt" {
                ATTRIBUTE "datatype"= "array<1>{real}"
                ATTRIBUTE "units"= "ns"
                DATA = [10, 10, 10, ...]
            }
            DATASET "t0" {
                ATTRIBUTE "datatype"= "array<1>{real}"
                ATTRIBUTE "units"= "ns"
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
    }

The actual numeric types of the datasets will be application-dependent.

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
