
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


"""
    find_lastgt(val, collection)

Return the last index of `collection` where the element is greater than `val`.
If no element of `collection` is greater than `val`, `nothing` is returned.
"""
@inline function find_lastgt(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_lastgt_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_lastgt_reverse(x, collection)
    end
end

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

@inline function find_lastgt(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i > x && return i
    end
    return nothing
end

"""
    find_lastgteq(val, collection)

Return the last index of `collection` where the element is greater than or equal
to `val`. If no element of `collection` is greater than or equal to `val`, `nothing`
is returned.
"""
@inline function find_lastgteq(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_lastgteq_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_lastgteq_reverse(x, collection)
    end
end

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

function find_lastgteq(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i >= x && return i
    end
    return nothing
end

"""
    find_lastlt(val, collection)

Return the last index of `collection` where the element is less than `val`.
If no element of `collection` is less than `val`, `nothing` is returned.
"""
@inline function find_lastlt(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_lastlt_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_lastlt_reverse(x, collection)
    end
end

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

function find_lastlt(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i < x && return i
    end
    return nothing
end


"""
    find_lastlteq(val, collection)

Return the last index of `collection` where the element is less than or equal to
`val`. If no element of `collection` is less than or equal to`val`, `nothing` is
returned.
"""
@inline function find_lastlteq(x, collection::AbstractRange)
    if isempty(collection)
        return nothing
    elseif drop_unit(step(collection)) > 0
        return unsafe_find_lastlteq_forward(x, collection)
    else  # drop_unit(step(collection)) < 0
        return unsafe_find_lastlteq_reverse(x, collection)
    end
end

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

function find_lastlteq(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i <= x && return i
    end
    return nothing
end

"""
    find_lasteq(val, collection)

Return the last index of `collection` where the element is equal to `val`.
If no element of `collection` is equal to `val`, `nothing` is returned.
"""
function find_lasteq end

# should be the same for unique sorted vectors like ranges
find_lasteq(x, r::AbstractRange) = find_firsteq(x, r)

function find_lasteq(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        x == a_i && return i
    end
    return nothing
end

