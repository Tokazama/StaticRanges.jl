
"""
    find_last(predicate::Function, A)

Return the index or key of the last element of A for which predicate returns
true. Return nothing if there is no such element.

Indices or keys are of the same type as those returned by keys(A) and pairs(A).

# Examples

```jldoctest
julia> using StaticRanges

julia> find_last(iseven, [1, 4, 2, 2])
4

julia> find_last(x -> x>10, [1, 4, 2, 2]) # returns nothing, but not printed in the REPL

julia> find_last(isequal(4), [1, 4, 2, 2])
2

julia> find_last(iseven, [1 4; 2 2])
CartesianIndex(2, 2)
```
"""
function find_last(f, x)
    if isempty(x)
        return nothing
    else
        return unsafe_find_last(f, x)
    end
end

@inline unsafe_find_last(f::Equal,              x) = unsafe_find_lasteq(f.x,   x)
@inline unsafe_find_last(f::Less,               x) = unsafe_find_lastlt(f.x,   x)
@inline unsafe_find_last(f::LessThanOrEqual,    x) = unsafe_find_lastlteq(f.x, x)
@inline unsafe_find_last(f::Greater,            x) = unsafe_find_lastgt(f.x,   x)
@inline unsafe_find_last(f::GreaterThanOrEqual, x) = unsafe_find_lastgteq(f.x, x)

@inline function unsafe_find_last(f, collection)
    for (i, collection_i) in Iterators.reverse(pairs(collection))
        f(collection_i) && return i
    end
    return nothing
end

#=
@inline find_last(f::Equal,              x) = find_lasteq(f.x,   x)
@inline find_last(f::Less,               x) = find_lastlt(f.x,   x)
@inline find_last(f::LessThanOrEqual,    x) = find_lastlteq(f.x, x)
@inline find_last(f::Greater,            x) = find_lastgt(f.x,   x)
@inline find_last(f::GreaterThanOrEqual, x) = find_lastgteq(f.x, x)
@inline function find_last(f, x)
    for (i, x_i) in Iterators.reverse(pairs(x))
        f(x_i) && return i
    end
    return nothing
end
=#

###
### find_lastgt(val, collection)
###
function unsafe_find_lastgt_forward(x, collection)
    if last(collection) <= x
        return nothing
    else
        return lastindex(collection)
    end
end

function unsafe_find_lastgt_reverse(x, collection)
    if first(collection) <= x
        return nothing
    elseif last(collection) > x
        return lastindex(collection)
    else
        index = unsafe_find_value(x, collection)
        if (@inbounds(collection[index]) == x) & (index != firstindex(collection))
            return index - oneunit(index)
        else
            return index
        end
    end
end

###
### find_lastgteq(val, collection)
###
function unsafe_find_lastgteq_forward(x, collection)
    if last(collection) < x
        return nothing
    else
        return lastindex(collection)
    end
end

function unsafe_find_lastgteq_reverse(x, collection)
    index = unsafe_find_value(x, collection)
    if firstindex(collection) > index
        return nothing
    elseif lastindex(collection) <= index
        return lastindex(collection)
    elseif @inbounds(collection[index]) >= x
        return index
    else
        return index - oneunit(index)
    end
end

###
### find_lastlt(val, collection)
###
@inline function unsafe_find_lastlt_forward(x, collection)
    index = unsafe_find_value(x, collection)
    if firstindex(collection) > index
        return nothing
    elseif lastindex(collection) < index
        return lastindex(collection)
    elseif @inbounds(collection[index]) < x
        return index
    else
        if index != firstindex(collection)
            return index - oneunit(index)
        else
            return nothing
        end
    end
end

@inline function unsafe_find_lastlt_reverse(x, collection)
    if last(collection) >= x
        return nothing
    else
        return lastindex(collection)
    end
end

###
### find_lastlteq(val, collection)
###
@inline function unsafe_find_lastlteq_forward(x, collection)
    if last(collection) <= x
        return lastindex(collection)
    elseif first(collection) > x
        return nothing
    else
        index = unsafe_find_value(x, collection)
        if @inbounds(collection[index]) <= x
            return index
        elseif index != firstindex(collection)
            return index - oneunit(index)
        else
            return nothing
        end
    end
end

@inline function unsafe_find_lastlteq_reverse(x, collection)
    if last(collection) > x
        return nothing
    else
        return lastindex(collection)
    end
end

###
### find_lasteq
###
# should be the same for unique sorted vectors like ranges
function find_lasteq(x, collection)
    if isempty(collection)
        return nothing
    else
        return unsafe_find_lasteq(x, collection)
    end
end

unsafe_find_lasteq(x, collection::AbstractRange) = unsafe_find_firsteq(x, collection)

function unsafe_find_lasteq(x, collection)
    for (i, collection_i) in Iterators.reverse(pairs(collection))
        x == collection_i && return i
    end
    return nothing
end

