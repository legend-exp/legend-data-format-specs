# Low-level DAQ Data Structure

DAQ data is represented by a table, each row represents a DAQ event on a single (physical or logical) input channel. Event building will happen at a higher data level. The detailed structure of DAQ data will depend on the DAQ system and experimental setup.

## Waveform vectors

Waveform vectors are regular [Table](@ref)s with three columns (`table{t0,dt,values}`):

* `t0`: the waveform time offsets (ralative to a certain global reference), optionally with units
* `dt`: the waveform sampling periods, optionally with units
* `values`: the waveform values. May be [Array of equal-sized arrays](@ref), [Vector of vectors](@ref), etc. `t0` and `dt` must have one dimension (the last) less than `values`.

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


## Generic DAQ data example

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


## LEGEND FlashCam DAQ data read out by Orca

Full format specification of the *raw* tier data.

**Coming Soon...**
