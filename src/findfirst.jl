function Base.findfirst(
    f::Fix2{<:Union{typeof(==),typeof(isequal)}},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
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

function Base.findfirst(
    f::Fix2{<:Union{typeof(<),typeof(isless)}},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    if isforward(r)
        return first(r) < f.x ? firstindex(r) : nothing
    elseif isreverse(r)
        idx = unsafe_findvalue(f.x, r)
        if firstindex(r) > idx
            return 1
        elseif lastindex(r) < idx
            return nothing
        elseif f(@inbounds(r[idx]))
            return idx
        elseif idx != lastindex(r)
            return idx + 1
        else
            return nothing
        end
    else  # step(r) == 0
        return nothing
    end
end

function Base.findfirst(
    f::Fix2{typeof(<=)},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    if isforward(r)
        return first(r) <= f.x ? firstindex(r) : nothing
    elseif isreverse(r)
        idx = unsafe_findvalue(f.x, r)
        if lastindex(r) < idx
            return nothing
        elseif firstindex(r) >= idx
            return 1
        elseif (@inbounds(f(r[idx])))
            return idx
        else 
            return idx - 1
        end
    else  # step(r) == 0
        return nothing
    end
end

function Base.findfirst(
    f::Fix2{typeof(>)},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    if isforward(r)
        idx = unsafe_findvalue(f.x, r)

        if last(r) < f.x
            return nothing
        elseif first(r) > f.x
            return 1
        else
            if f(@inbounds(r[idx]))
                return idx
            elseif idx != lastindex(r)
                return idx + 1
            else
                return nothing
            end
        end
    elseif isreverse(r)
        return first(r) > f.x ? firstindex(r) : nothing
    else  # step(r) == 0
       return nothing
    end
end

function Base.findfirst(
    f::Fix2{typeof(>=)},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    if isforward(r)
        idx = unsafe_findvalue(f.x, r)
        if last(r) < f.x
            return nothing
        elseif first(r) > f.x
            return firstindex(r)
        elseif f(@inbounds(r[idx]))
            return idx
        else
            return idx + 1
        end
    elseif isreverse(r)
        return first(r) >= f.x ? firstindex(r) : nothing
    else  # step(r) == 0
       return nothing
    end
end
