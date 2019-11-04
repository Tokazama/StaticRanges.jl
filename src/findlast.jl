function Base.findlast(f::Fix2{<:Union{typeof(==),typeof(isequal)}}, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    if isempty(r)
        return nothing
    else
        idx = unsafe_findvalue(f.x, r)
        @boundscheck if (firstindex(r) > idx || idx > lastindex(r)) || @inbounds(!f(r[idx]))
            return nothing
        end
        return idx
    end
end

function Base.findlast(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    if isforward(r)
        idx = unsafe_findvalue(f.x, r)
        if lastindex(r) < idx
            return lastindex(r)
        elseif firstindex(r) > idx
            return nothing
        elseif f(@inbounds(r[idx]))
            return idx
        elseif idx != firstindex(r)
            return idx - 1
        else
            return nothing
        end
    elseif isreverse(r)
        return last(r) < f.x ? lastindex(r) : nothing
    else  # step(r) == 0
        return nothing
    end
end

function Base.findlast(f::Fix2{typeof(<=)}, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    if isforward(r)
        if f(last(r))
            return lastindex(r)
        elseif first(r) > f.x
            return nothing
        else
            idx = unsafe_findvalue(f.x, r)
            if f(@inbounds(r[idx]))
                return idx
            elseif idx != firstindex(r)
                return idx - 1
            end
        end
    elseif isreverse(r)
        return f(last(r)) ? lastindex(r) : nothing
    else  # step(r) == 0
        return nothing
    end
end

function Base.findlast(f::Fix2{typeof(>)}, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    if isforward(r)
        return last(r) > f.x ? lastindex(r) : nothing
    elseif isreverse(r)
        if last(r) > f.x
            return lastindex(r)
        elseif first(r) < f.x
            return nothing
        else
            idx = unsafe_findvalue(f.x, r)
            if f(@inbounds(r[idx]))
                return idx
            elseif idx != firstindex(r)
                return idx - 1
            end
        end
    else  # step(r) == 0
        return nothing
    end
end

function Base.findlast(
    f::Fix2{typeof(>=)},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    if isforward(r)
        return last(r) >= f.x ? lastindex(r) : nothing
    elseif isreverse(r)
        if first(r) < f.x
            return nothing
        elseif last(r) > f.x 
            return lastindex(r)
        else
            idx = unsafe_findvalue(f.x, r)
            if f(@inbounds(r[idx]))
                return idx
            else
                return idx - 1
            end
        end
    else  # step(r) == 0
        return nothing
    end
end
