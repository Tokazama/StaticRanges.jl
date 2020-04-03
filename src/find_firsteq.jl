
@propagate_inbounds function find_firsteq(x, r::AbstractRange)
    @boundscheck if !in(x, r)
        return nothing
    end
    return unsafe_findvalue(x, r)
end

function find_firsteq(x, a)
    for (i, a_i) in pairs(a)
        x == a_i && return i
    end
    return nothing
end

