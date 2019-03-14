#!/bin/bash

julia --project=docs/ docs/make.jl make.jl "$@"
