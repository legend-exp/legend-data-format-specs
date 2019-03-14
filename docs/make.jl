# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [fixdoctests]
#
# for local builds.

import Pkg

try
    using Documenter
catch err
    if err isa ArgumentError
        Pkg.pkg"instantiate"
        using Documenter
    else
        rethrow()
    end
end

makedocs(
    sitename = "LEGEND Data Format Specifications",
    modules = Module[],
    format = Documenter.HTML(
        prettyurls = ("prettyurls" in ARGS),
        canonical = "https://legend-exp.github.io/legend-data-format-specs/stable/"
    ),
    pages=[
        "Home" => "index.md",
        "HDF5" => "hdf5.md",
        "Data Compression" => "data_compression.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
)

deploydocs(
    repo = "github.com/legend-exp/legend-data-format-specs.git",
    forcepush = true
)
