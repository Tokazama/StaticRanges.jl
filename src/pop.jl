###
### pop!
###
function Base.pop!(r::StepMRangeLen)
    isempty(r) && error("array must be non-empty")
    l = last(r)
    length(r) == 1 ? empty!(r) : setfield!(r, :len, length(r) - 1)
    return l
end

function Base.pop!(r::LinMRange)
    isempty(r) && error("array must be non-empty")
    l = last(r)
    if length(r) == 1
        empty!(r)
    else
        len = length(r) - 1
        setfield!(r, :stop, unsafe_getindex(r, len))
        setfield!(r, :len, len)
        setfield!(r, :lendiv, max(len - 1, 1))
    end
    return l
end

function Base.pop!(r::StepMRange{T}) where {T}
    isempty(r) && error("array must be non-empty")
    l = last(r)
    length(r) == 1 ? empty!(r) : set_last!(r, l - T(step(r)))
    return l
end

function Base.pop!(r::Union{UnitMRange{T},OneToMRange{T}}) where {T}
    if isempty(r)
        error("array must be non-empty")
    else
        lst = last(r)
        if length(r) == 1
            empty!(r)
        else
            set_last!(r, lst - oneunit(T))
        end
        return lst
    end
end

###
### popfirst!
###
function Base.popfirst!(r::StepMRangeLen)
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        empty!(r)
    else
        setfield!(r, :ref, @inbounds(r[2]))
        setfield!(r, :len, length(r) - 1)
    end
    return f
end

function Base.popfirst!(r::LinMRange)
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        empty!(r)
    else
        len = length(r) - 1
        setfield!(r, :start, @inbounds(r[2]))
        setfield!(r, :len, len)
        setfield!(r, :lendiv, max(len - 1, 1))
    end
    return f
end

function Base.popfirst!(r::Union{StepMRange,UnitMRange})
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        empty!(r)
    else
        setfield!(r, :start, @inbounds(r[2]))
    end
    return f
end

