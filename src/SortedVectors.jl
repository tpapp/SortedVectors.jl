module SortedVectors

export SortedVector

using ArgCheck: @argcheck
using Lazy: @forward
using Parameters: @unpack

struct SortedVector{T, F, V <: AbstractVector{T}} <: AbstractVector{T}
    "comparison function for sorting"
    lt::F
    "sorted contents"
    sorted_contents::V
    function SortedVector(::Val{:assumesorted}, lt::F,
                          sorted_contents::V) where {F, V <: AbstractVector}
        new{eltype(sorted_contents), F, V}(lt, sorted_contents)
    end
end

function SortedVector(::Val{:checksorted}, lt, sorted_contents::AbstractVector)
    @argcheck issorted(sorted_contents, lt)
    SortedVector(Val{:assumesorted}, lt, sorted_contents)
end

"""
    SortedVector([lt], xs)

Sort `xs` by `lt` (which defaults to `isless`) and wrap in a SortedVector. For reverse sorting, use `!lt`.

    SortedVector(Val{:checksorted}(), lt, sorted_contents)

Checks that the vector is sorted, throws an `ArgumentError` if it isn't. This is a
relatively cheap operation if the vector is supposed to be sorted but this should be
checked. `copy` the `sorted_contents` if they are mutable and may be modified.

    SortedVector(Val{:assumesorted}(), lt, sorted_contents)

Unchecked, unsafe constructor. Use only if you are certain that `sorted_contents` is sorted
according to `lt`, otherwise results are undefined. `copy` the `sorted_contents` if they are
mutable and may be modified.
"""
function SortedVector(lt, xs::AbstractVector)
    SortedVector(Val{:assumesorted}(), lt, sort(xs; lt = lt))
end

SortedVector(xs::AbstractVector) = SortedVector(isless, xs)

Base.parent(sv::SortedVector) = sv.sorted_contents

####
#### array interface
####

@forward SortedVector.sorted_contents (Base.size, Base.getindex, length, similar, axes)

Base.IndexStyle(::Type{<:SortedVector}) = Base.IndexLinear()

function Base.setindex!(sv::SortedVector, x, i::Integer)
    @unpack lt, sorted_contents = sv
    a, b = firstindex(sorted_contents), lastindex(sorted_contents)
    a < i ≤ b && @argcheck lt(sorted_contents[i-1], x)
    a ≤ i < b && @argcheck lt(x, sorted_contents[i+1])
    sorted_contents[i] = x
end

end # module
