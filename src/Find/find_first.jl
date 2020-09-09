
"""
    find_first(predicate::Function, A)

Return the index or key of the first element of A for which predicate returns
true. Return nothing if there is no such element.

Indices or keys are of the same type as those returned by keys(A) and pairs(A).

# Examples

```jldoctest
julia> using StaticRanges

julia> A = [1, 4, 2, 2];

julia> find_first(iseven, A)
2

julia> find_first(x -> x>10, A) # returns nothing, but not printed in the REPL

julia> find_first(isequal(4), A)
2

julia> find_first(iseven, [1 4; 2 2])
CartesianIndex(2, 1)
```
"""
function find_first(f, collection)
    if isempty(collection)
        return nothing
    else
        return unsafe_find_first(f, collection)
    end
end


@inline unsafe_find_first(f::Equal,              x) = unsafe_find_firsteq(f.x,   x)
@inline unsafe_find_first(f::Less,               x) = unsafe_find_firstlt(f.x,   x)
@inline unsafe_find_first(f::LessThanOrEqual,    x) = unsafe_find_firstlteq(f.x, x)
@inline unsafe_find_first(f::Greater,            x) = unsafe_find_firstgt(f.x,   x)
@inline unsafe_find_first(f::GreaterThanOrEqual, x) = unsafe_find_firstgteq(f.x, x)
@inline function unsafe_find_first(f, x)
    for (i, x_i) in pairs(x)
        f(x_i) && return i
    end
    return nothing
end

#=

@inline find_first(f::Equal,              x) = find_firsteq(f.x,   x)
@inline find_first(f::Less,               x) = find_firstlt(f.x,   x)
@inline find_first(f::LessThanOrEqual,    x) = find_firstlteq(f.x, x)
@inline find_first(f::Greater,            x) = find_firstgt(f.x,   x)
@inline find_first(f::GreaterThanOrEqual, x) = find_firstgteq(f.x, x)
@inline find_first(f::In,                 x) = find_firstin(f.x,   x)
@inline function find_first(f, x)
    for (i, x_i) in pairs(x)
        f(x_i) && return i
    end
    return nothing
end

=#
###
### find_firstlt(val, collection)
###
@inline function unsafe_find_firstlt_forward(x, collection)
    if first(collection) >= x
        return nothing
    else
        return firstindex(collection)
    end
end

@inline function unsafe_find_firstlt_reverse(x, collection)
    index = unsafe_find_value(x, collection)
    if lastindex(collection) <= index
        return nothing
    elseif firstindex(collection) > index
        return firstindex(collection)
    elseif @inbounds(collection[index]) < x
        return index
    else
        return index + oneunit(index)
    end
end

###
### find_firstlteq(val, collection)
###

@inline function unsafe_find_firstlteq_forward(x, collection)
    if first(collection) > x
        return nothing
    else
        return firstindex(collection)
    end
end

@inline function unsafe_find_firstlteq_reverse(x, collection)
    if first(collection) <= x
        return firstindex(collection)
    elseif last(collection) > x
        return nothing
    else
        index = unsafe_find_value(x, collection)
        if @inbounds(collection[index]) <= x
            return index
        else
            return index + oneunit(index)
        end
    end
end

###
### find_firstgt
###
@inline function unsafe_find_firstgt_forward(x, collection)
    if last(collection) <= x
        return nothing
    elseif first(collection) > x
        return firstindex(collection)
    else
        index = unsafe_find_value(x, collection)
        if @inbounds(collection[index]) > x
            return index
        else
            return index + oneunit(index)
        end
    end
end

@inline function unsafe_find_firstgt_reverse(x, collection)
    if first(collection) > x
        return firstindex(collection)
    elseif last(collection) < x
        return nothing
    else
        return unsafe_find_value(x, collection, RoundUp)
    end
end

###
### find_firstgteq
###
@inline function unsafe_find_firstgteq_forward(x, collection)
    if last(collection) < x
        return nothing
    elseif first(collection) >= x
        return firstindex(collection)
    else
        index = unsafe_find_value(x, collection)
        if @inbounds(collection[index]) >= x
            return index
        else
            return index + oneunit(index)
        end
    end
end

@inline function unsafe_find_firstgteq_reverse(x, collection)
    if first(collection) >= x
        return firstindex(collection)
    else
        return nothing
    end
end

###
### find_firsteq
###

function find_firsteq(x, collection)
    if isempty(collection)
        return nothing
    else
        return unsafe_find_firsteq(x, collection)
    end
end

function unsafe_find_firsteq(x, collection::AbstractRange)
    if minimum(collection) > x || maximum(collection) < x
        return nothing
    else
        index = unsafe_find_value(x, collection)
        if @inbounds(collection[index]) == x
            return index
        else
            return nothing
        end
    end
end

function unsafe_find_firsteq(x, collection)
    for (index, collection_i) in pairs(collection)
        x == collection_i && return index
    end
    return nothing
end

