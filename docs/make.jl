# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.

using Documenter

makedocs(
    sitename = "LEGEND Data Format Specifications",
    modules = Module[],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://legend-exp.github.io/legend-data-format-specs/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "HDF5" => "hdf5.md",
        "Data Compression" => "data_compression.md",
        "DAQ Data" => "daq_data.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
)

deploydocs(
    repo = "github.com/legend-exp/legend-data-format-specs.git",
    forcepush = true,
    push_preview = true,
)
