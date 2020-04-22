
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

