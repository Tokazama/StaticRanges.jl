
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

