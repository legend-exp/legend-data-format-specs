# Detector ID encoding

LEGEND detectors IDs are variable-length strings, so their string representation is not ideal as an in-memory representation, for storage as binary tabular data and GPU memory. Therefore, the following 32-bit unsigned integer encoding should be used when writing detector IDs to files, it can also serve as an efficient in-memory representation.

## Binary encoding

Encoding length: 4-byte unsigned integer value, stored as a 32-bit or 64-bit integer.

Format (nibbles): RT XX XX XY

* Reserved (R): 1 Nibble, always zero

* Type (T), 1 Nibble:

    * 0x0: reserved
    * 0x1: C (Coax HPGe)
    * 0x2: B (BEGe HPGe)
    * 0x3: P (PPC HPGe)
    * 0x4: V (ICPC HPGe)
    * 0x5: reserved
    * 0x6: reserved
    * 0x7: reserved
    * 0x8: reserved
	* 0x9: S (SiPM)
    * 0xa: PMT (PMT)
	* 0xb: PULS
    * 0xc: AUX
    * 0xd: DUMMY
    * 0xe: BSLN
    * 0xf: MUON

* Serial-Number (XXXXX), 5 Nibbles, unsigned integer in binary form (not BCD).

* Sub-Serial-Number (Y), 1 Nibble, unsigned integer in binary form (not BCD):

    * For HPGe: Detector slice, 0 = A, 1 = B, 2 = C, ...
    * For SiPM: always 0
    * For PMT: always 0
    * For Pulser: 0 = `PULSnn`, 1 = `PULSnnANA`
    * For Dummy: always 0


## String representation

* `[B|C|P|V]nnnnn[A|B|C|D|M]`: represent serial number with five digits in string
* `Snnn`: represent serial number with three digits in string
* `PMTnnn`:  represent serial number with three digits in string
* `PULSnn`, `PULSnnANA`: represent serial number with two digits in string
* `AUXnn`:  represent serial number with two digits in string
* `DUMMYnn`: represent serial number with two digits in string. Special case: legacy data may contain DUMMY0 to DUMMY9, with a single digit, it should be possible to parse these as well, but when converting integer to string representation, two digits should be used.
* `BSLNnn`: represent serial number with two digits in string
* `MUONnn`: represent serial number with two digits in string

## Special cases:

* C00ANGn: Encode as `R[C][f100n][0]`
* C000RGn: Encode as `R[C][f200n][0]`


## Test cases:

```
"B00000C" <-> 0x02000002
"B59231A" <-> 0x020e75f0
"C00000A" <-> 0x01000000
"C83847I" <-> 0x01147878
"C000RG4" <-> 0x01f20040
"C00ANG7" <-> 0x01f10070
"P94752A" <-> 0x03172200
"P00000K" <-> 0x0300000a
"V99999J" <-> 0x041869f9
"V98237P" <-> 0x0417fbdf
"S000" <-> 0x09000000
"S632" <-> 0x09002780
"S999" <-> 0x09003e70
"PMT000" <-> 0x0a000000
"PMT183" <-> 0x0a000b70
"PMT999" <-> 0x0a003e70
"PULS00" <-> 0x0b000000
"PULS00ANA" <-> 0x0b000001
"PULS99" <-> 0x0b000630
"PULS99ANA" <-> 0x0b000631
"AUX00" <-> 0x0c000000
"AUX99" <-> 0x0c000630
"DUMMY0" <-> 0x0d000000
"DUMMY00" <-> 0x0d000000
"DUMMY9" <-> 0x0d000090
"DUMMY09" <-> 0x0d000090
"DUMMY10" <-> 0x0d0000a0
"DUMMY99" <-> 0x0d000630
"BSLN00" <-> 0x0e000000
"BSLN99" <-> 0x0e000630
"MUON00" <-> 0x0f000000
"MUON99" <-> 0x0f000630
"C000RG4" <-> 0x01f20040
"C00ANG7" <-> 0x01f10070
```
