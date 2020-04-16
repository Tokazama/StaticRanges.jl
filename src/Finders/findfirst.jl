
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
@inline find_first(f::Equal,              a) = find_firsteq(f.x,   a)
@inline find_first(f::Less,               a) = find_firstlt(f.x,   a)
@inline find_first(f::LessThanOrEqual,    a) = find_firstlteq(f.x, a)
@inline find_first(f::Greater,            a) = find_firstgt(f.x,   a)
@inline find_first(f::GreaterThanOrEqual, a) = find_firstgteq(f.x, a)
@inline find_first(f::In,                 a) = find_firstin(f.x, a)


@inline function find_first(f, a)
    for (i, a_i) in pairs(a)
        f(a_i) && return i
    end
    return nothing
end

