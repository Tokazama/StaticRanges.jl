function _in_range(x, r::AbstractSRange)
    if step(r) == 0
        return !isempty(r) && first(r) == x
    else
        n = round(Integer, (x - first(r)) / step(r)) + 1
        return n >= 1 && n <= length(r) && r[n] == x
    end
end

in(x::Real, r::AbstractSRange{<:Real}) = _in_range(x, r)
# This method needs to be defined separately since -(::T, ::T) can be implemented
# even if -(::T, ::Real) is not
in(x::T, r::AbstractSRange{T}) where {T} = _in_range(x, r)

function in(x::Real, r::AbstractSRange{T}) where {T<:Integer}
    isa(x, Integer) && !isempty(r) && x >= minimum(r) && x <= maximum(r) &&
        (mod(convert(T,x), step(r)) - mod(first(r),step(r)) == 0)
end
function in(x::AbstractChar, r::AbstractSRange{<:AbstractChar})
    !isempty(r) && x >= minimum(r) && x <= maximum(r) &&
        (mod(Int(x) - Int(first(r)), step(r)) == 0)
end

@pure function in(x::Integer, r::AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L}}) where {T<:Integer,B,E,L}
    ( B::T <= x) & (x <= E::T)
end

function in(x, r::AbstractSRange)
    anymissing = false
    for y in itr
        v = (y == x)
        if ismissing(v)
            anymissing = true
        elseif v
            return true
        end
    end
    return anymissing ? missing : false
end
