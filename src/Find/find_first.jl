
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


"""
    find_firstlt(val, collection)

Return the first index of `collection` where the element is less than `val`.
If no element of `collection` is less than `val`, `nothing` is returned.
"""
@inline function find_firstlt(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_firstlt_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_firstlt_reverse(x, collection)
    end
end

@inline function unsafe_find_firstlt_forward(x, collection)
    if first(collection) >= x
        return nothing
    else
        return firstindex(collection)
    end
end

@inline function unsafe_find_firstlt_reverse(x, collection)
    index = unsafe_findvalue(x, collection)
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

function find_firstlt(x, collection)
    for (i, collection_i) in pairs(collection)
        collection_i < x && return i
    end
    return nothing
end

"""
    find_firstlteq(val, collection)

Return the first index of `collection` where the element is less than or equal to
`val`. If no element of `collection` is less than or equal to `val`, `nothing`
is returned.
"""
@inline function find_firstlteq(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_firstlteq_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_firstlteq_reverse(x, collection)
    end
end

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
        index = unsafe_findvalue(x, collection)
        if @inbounds(collection[index]) <= x
            return index
        else
            return index + oneunit(index)
        end
    end
end

function find_firstlteq(x, a)
    for (i, a_i) in pairs(a)
        a_i <= x && return i
    end
    return nothing
end

"""
    find_firstgt(val, collection)

Return the first index of `collection` where the element is greater than `val`.
If no element of `collection` is greater than `val`, `nothing` is returned.
"""
@inline function find_firstgt(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_firstgt_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_firstgt_reverse(x, collection)
    end
end

@inline function unsafe_find_firstgt_forward(x, collection)
    if last(collection) <= x
        return nothing
    elseif first(collection) > x
        return firstindex(collection)
    else
        index = unsafe_findvalue(x, collection)
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
        return unsafe_findvalue(x, collection, RoundUp)
    end
end

function find_firstgt(x, a)
    for (i, a_i) in pairs(a)
        a_i > x && return i
    end
    return nothing
end

"""
    find_firstgteq(val, collection)

Return the first index of `collection` where the element is greater than or equal
to `val`. If no element of `collection` is greater than or equal to `val`, `nothing`
is returned.
"""
@inline function find_firstgteq(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_firstgteq_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_firstgteq_reverse(x, collection)
    end
end

@inline function unsafe_find_firstgteq_forward(x, collection)
    if last(collection) < x
        return nothing
    elseif first(collection) >= x
        return firstindex(collection)
    else
        index = unsafe_findvalue(x, collection)
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

function find_firstgteq(x, a)
    for (i, a_i) in pairs(a)
        a_i >= x && return i
    end
    return nothing
end

"""
    find_firsteq(val, collection)

Return the first index of `collection` where the element is equal to `val`.
If no element of `collection` is equal to `val`, `nothing` is returned.
"""
function find_firsteq(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    else
        return unsafe_find_firsteq(x, collection)
    end
end

function unsafe_find_firsteq(x, collection)
    if minimum(collection) > x || maximum(collection) < x
        return nothing
    else
        index = unsafe_findvalue(x, collection)
        if @inbounds(collection[index]) == x
            return index
        else
            return nothing
        end
    end
end

#=

find_firsteq(x, r::OneToUnion) = _find_firsteq_oneto(x, r)

function _find_firsteq_oneto(x::Integer, r)
    if (x < 1) | (x > last(r))
        return nothing
    else
        return x
    end
end

function _find_firsteq_oneto(x, r)
    idx = round(Integer, x)
    if idx == x
        return _find_firsteq_oneto(idx, r)
    else
        return nothing
    end
end
=#

function find_firsteq(x, a)
    for (i, a_i) in pairs(a)
        x == a_i && return i
    end
    return nothing
end
