# The goal is to create type stable merges that don't instantly result in an explosion
# of allocations because everything has to become an array.


###
### OneTo
###
combine(x::OneToUnion, y::OneToUnion) = promote_type(typeof(x), typeof(y))(max(x, y))

###
### AbstractUnitRange
###
function combine(x::AbstractUnitRange{<:Integer}, y::AbstractUnitRange{<:Integer})
    R = promote_type(typeof(x), typeof(y))
    if isempty(x)
        if isempty(y)
            return GapRange(R(1, 0), R(1, 0))
        else
            return GapRange(R(1, 0), R(first(y), last(y)))
        end
    elseif isempty(y)
        return GapRange(R(1, 0), R(first(x), last(x)))
    else
        xmax = last(x)
        xmin = first(x)
        ymax = last(y)
        ymin = first(y)
        if xmax < ymin  # all x below y
            return GapRange(R(xmin, xmax), R(ymin, ymax))
        elseif ymax < xmin  # all y below x
            return GapRange(R(ymin, ymax), R(xmin, xmax))
        else # x and y overlap so we just set the first range to length of one
            rmin = min(xmin, ymin)
            return GapRange(R(rmin, rmin), R(rmin + oneunit(eltype(R)), max(xmax, ymax)))
        end
    end
end

function combine(x, y)::Vector
    if is_after(x, y)
        return vcat(y, x)
    elseif is_before(x, y)
        return vcat(x, y)
    else
        return vcat_sort(x, y)
    end
end
