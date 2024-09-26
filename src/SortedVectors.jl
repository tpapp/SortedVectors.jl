"""
See [`SortedVector`](@ref).
"""
module SortedVectors

export SortedVector

using ArgCheck: @argcheck
using DocStringExtensions: SIGNATURES

import Base.Order

"""
Flag for indicating that

1. sorting should be verified,
2. the argument vector will not be modified later.

Not exported, but part of the API.
"""
struct CheckSorted end

"""
Flag for indicating that

1. the argument should be assumed to be sorted, and **this should not be checked**,
2. the argument vector will not be modified later.

Not exported, but part of the API.
"""
struct AssumeSorted end

struct SortedVector{T, V <: AbstractVector{T}, O} <: AbstractVector{T}
    "sorted contents"
    sorted_contents::V
    "order"
    order::O
    function SortedVector(::AssumeSorted, sorted_contents::V,
                          order::O = Order.Forward) where {V <: AbstractVector, O}
        new{eltype(sorted_contents), V, O}(sorted_contents, order)
    end
end

function SortedVector(::CheckSorted, sorted_contents::AbstractVector,
                      order = Order.Forward)
    @argcheck issorted(sorted_contents, order)
    SortedVector(AssumeSorted(), sorted_contents, order)
end

"""
    SortedVector(xs, order = Base.Ordering.Forward)

Sort `xs` by `order` and wrap in a SortedVector.

    SortedVector(SortedVectors.CheckSorted(), sorted_contents, order = Base.Order.Forward)

Checks that the vector is sorted, throws an `ArgumentError` if it isn't. This is a
relatively cheap operation if the vector is supposed to be sorted but this should be
checked.

    SortedVector(SortedVectors.AssumeSorted(), sorted_contents, order = Base.Order.Forward)

Unchecked, unsafe constructor. Use only if you are certain that `sorted_contents` is
sorted according to `order`, otherwise results are undefined.

For the last two constructors, it is assumed that `sorted_contents` is not modified by
another function later. If you cannot ensure that, `copy` before.

## API supported by `SortedVector`

`SortedVector{T} <: AbstractVector{T}`, so the array API is supported. `setindex!`
checks that the order is maintained. `sorted_contents` can have generalized indexing,
which is inherited by the wrapper.

`order` can be retrieved by using the property accessor `.order`.

To obtain the sorted contents, use `parent`.

See also [`cut`](@ref).
"""
function SortedVector(xs::AbstractVector, order::Order.Ordering = Order.Forward)
    SortedVector(AssumeSorted(), sort(xs; order), order)
end

Base.parent(sv::SortedVector) = sv.sorted_contents

####
#### array interface
####

for f in (:size, :getindex, :length, :axes, :firstindex, :lastindex)
    # call the same function on the field
    @eval function Base.$f(sorted_vector::SortedVector, args...)
        $f(sorted_vector.sorted_contents, args...)
    end
end

Base.IndexStyle(::Type{<:SortedVector}) = Base.IndexLinear()

function Base.setindex!(sorted_vector::SortedVector, x, i::Integer)
    (; order, sorted_contents) = sorted_vector
    a, b = firstindex(sorted_contents), lastindex(sorted_contents)
    a < i ≤ b && @argcheck Order.lt(order, sorted_contents[i-1], x)
    a ≤ i < b && @argcheck Order.lt(order, x, sorted_contents[i+1])
    sorted_contents[i] = x
end

####
#### cut
####

function Base.searchsortedfirst(sorted_vector::SortedVector, x)
    (; sorted_contents, order) = sorted_vector
    searchsortedfirst(sorted_contents, x, order)
end

function Base.searchsortedlast(sorted_vector::SortedVector, x)
    (; sorted_contents, order) = sorted_vector
    searchsortedlast(sorted_contents, x, order)
end

function Base.in(x, sorted_vector::SortedVector)
    (; sorted_contents, order) = sorted_vector
    i = searchsortedfirst(sorted_contents, x, order)
    i ≢ nothing && sorted_contents[i] == x
end


"""
$(SIGNATURES)

Assume that `<` etc represent the `order` of the `breaks`.

If `open_left`, return `i` such that `breaks[i] < x ≤ breaks[i + 1]`, where `<` is the
sorting of the vector.

If `!open_left`, return `i` such that `breaks[i] ≤ x < breaks[i + 1]`, where `<` is the
sorting of the vector.

For values outside the range, return the adjacent index ±1 as applicable.
"""
function cut(x, breaks::SortedVector, open_left::Bool = true)
    fi = firstindex(breaks)
    li = lastindex(breaks)
    if open_left
        ix = searchsortedfirst(breaks, x)
        if ix == fi
            fi - 1
        elseif ix == li + 1
            li
        else
            ix - 1
        end
    else
        ix = searchsortedlast(breaks, x)
        if ix == fi - 1
            fi - 1
        elseif ix == li
            li
        else
            ix
        end
    end
end

end # module
