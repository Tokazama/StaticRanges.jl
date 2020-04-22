
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

