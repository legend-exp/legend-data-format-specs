# Low-level DAQ Data Structure

## General DAQ structure

(Data Acquisition) DAQ data is represented by a table, each row represents a DAQ event on a single (physical or logical) input channel. Event building will happen at a higher data level.

The detailed structure of DAQ data will depend on the DAQ system and experimental setup. However, fields like these may become mandatory for all DAQs:

* `ch`: `array<1>{real}`
* `evttype`: `array<1>{enum{evt_undef=0,evt_real=1,evt_pulser=2,evt_mc=3,evt_baseline=4}}`
* `daqevtno`: `array<1>{real}`

A DAQ system with waveform digitization will provide columns like

* `waveform_lf`: `array<1>{waveform}` (see [Waveform vectors](@ref))
* `waveform_hf`: `array<1>{waveform}`

If the DAQ performs an internal pulse-shape analysis (digital or analog), energy reconstruction and other columns may be available, e.g.:

* `psa_energy`: `array<1>{real}`
* `psa_trise`: `array<1>{real}`

Other DAQ and setup-specific columns will often be present, e.g.

* `muveto`: `array<1>{real}`

The collaboration will decide on a list of recommended columns names, to ensure columns with same semantics will have the same name, independent of DAQ/setup.

Legacy data that does not separate low-level DAQ data and event building will also include a column

* `evtno`: `array<1>{real}`

## Waveform vectors

Waveform data as be stored either directly in compressed form. Uncompressed waveform data is stored as a `table{t0,dt,values}`:

* `t0`: `array<1>{real}`
* `dt`: `array<1>{real}`
* Either `values`: `array<1>{array<1>{real}}` or `array_of_equalsized_arrays<1,1>{real}`
* or `encvalues`: `table{bytes,... codec information ...}`

* `encvalues`: `table{bytes,... codec information ...}`
* `bytes`: `array<1>{array<1>{real}}`
* `some_codec_information`: ...

Compressed waveform data is stored as a `table{t0,dt,encvalues}`:

* `t0`: `array<1>{real}`
* `dt`: `array<1>{real}`
* `encvalues`: `table{bytes,... codec information ...}`

The column `encvalues` has the structure

* `bytes`: `array<1>{array<1>{real}}`
* `some_codec_information`: ...
