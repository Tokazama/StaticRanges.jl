function make_unique(x::AbstractVector{K}, y::AbstractVector{K}) where {K}
    if is_dynamic(x)
        return make_unique!(copy(x), y)
    else
        # TODO Better method of dealing with non dynamic vectors in make_unique
        return convert(typeof(x), make_unique!(Vector(x), y))
    end
end

"""
    make_unique!(x, y) -> x
"""
make_unique!(x, y) = make_unique!(promote(x, y)...)

function make_unique!(
    x::AbstractVector{T},
    y::AbstractVector{T},
    offset::T=unique_offset(x)
   ) where {T}
    for y_i in y
        if y_i in x
            push!(x, add_offset(x, y_i, offset))
        else
            push!(x, y_i)
        end
    end
    return x
end

function unique_offset(x::AbstractVector{T}) where {T<:Number}
    return T(round(maximum(names), RoundUp, sigdigits=1))
end
unique_offset(x::AbstractVector{Symbol}) = :_2
unique_offset(x::AbstractVector{AbstractString}) = "_2"

function add_offset(x, v::AbstractString, f::AbstractString)
    newval = v * f
    if newval in x
        return add_offset(x, newval, f)
    else
        return newval
    end
end
function add_offset(x, v::Number, f::Number)
    newval = v + f
    if newval in x
        return add_offset(x, newval, f)
    else
        return newval
    end
end
function add_offset(x, v::Symbol, f::Symbol)
    newval = Symbol(v, f)
    if newval in x
        return add_offset(x, newval, f)
    else
        return newval
    end
end
