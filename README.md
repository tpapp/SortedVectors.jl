# SortedVectors

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![build](https://github.com/tpapp/SortedVectors.jl/workflows/CI/badge.svg)](https://github.com/tpapp/SortedVectors.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/tpapp/SortedVectors.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/SortedVectors.jl?branch=master)

A very lightweight Julia package to declare that a vector is sorted.

## Installation

The package is registered. Type `]` to enter `pkg` mode, and install with

```julia
pkg> add SortedVectors
```

## Documentation

See the docstring for `SortedVector`, the only exported symbol.

## Example
    
``` julia
julia> using SortedVectors

julia> sv = SortedVector([1, 3, 4])
3-element SortedVector{Int64, Vector{Int64}, Base.Order.ForwardOrdering}:
 1
 3
 4

julia> sv[2]
3

julia> 2 ∈ sv
false

julia> sv[2] = 7
ERROR: ArgumentError: Order.lt(order, x, sorted_contents[i + 1]) must hold. Got
Order.lt => lt
order => ForwardOrdering()
x => 7
sorted_contents[i + 1] => 4
Stacktrace:
 [1] throw_check_error(info::Any)
   @ ArgCheck ~/.julia/packages/ArgCheck/CA5vv/src/checks.jl:280
 [2] setindex!(sorted_vector::SortedVector{Int64, Vector{Int64}, Base.Order.ForwardOrdering}, x::Int64, i::Int64)
   @ SortedVectors ~/code/julia/SortedVectors/src/SortedVectors.jl:104
```
