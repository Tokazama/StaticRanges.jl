
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
@inline find_last(f::Equal,              a) = find_lasteq(f.x, a)
@inline find_last(f::Less,               a) = find_lastlt(f.x, a)
@inline find_last(f::LessThanOrEqual,    a) = find_lastlteq(f.x, a)
@inline find_last(f::Greater,            a) = find_lastgt(f.x, a)
@inline find_last(f::GreaterThanOrEqual, a) = find_lastgteq(f.x, a)

@inline function find_last(f, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        f(a_i) && return i
    end
    return nothing
end

