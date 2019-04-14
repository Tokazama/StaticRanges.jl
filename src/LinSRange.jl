struct LinSRange{T,B,E,L,D} <: AbstractUnitSRange{T,B,E,L}

    function LinSRange{T}(start::SVal{B,T}, stop::SVal{E,T}, len::SInt64{L}) where {T,B,E,L}
        len >= SZero || throw(ArgumentError("range($B, stop=$E, length=$L): negative length"))
        if len == SOne
            start == stop || throw(ArgumentError("range($B, stop=$E, length=$L): endpoints differ"))
            return new{T,SVal{B,T},SVal{E,T},SVal{1,Int},SVal{1,Int}}()
        end
        new{T,SVal{B,T},SVal{E,T},SVal{L,Int},SVal{max(L-1,1),Int}}()
    end
end

LinSRange(start::SVal{B,T}, stop::SVal{E,T}, len::SInteger{L}) where {T,B,E,L} =
    LinSRange{eltype((stop-start)/len)}(start, stop, len)


function show(io::IO, r::LinSRange)
    print(io, "srange(")
    show(io, first(r))
    print(io, ", stop=")
    show(io, last(r))
    print(io, ", length=")
    show(io, length(r))
    print(io, ')')
end

function _sr(start::T, ::SNothing, stop::S, len::SInteger) where {T,S}
    a, b = promote(start, stop)
    _sr(a, nothing, b, len)
end
_sr(start::SVal{B,T}, ::SNothing, stop::SVal{E,T}, len::SInteger) where {T<:Real,B,E} = LinSRange{T}(start, stop, len)
_sr(start::SVal{B,T}, ::SNothing, stop::SVal{E,T}, len::SInteger) where {T,B,E} = LinSRange{T}(start, stop, len)
_sr(start::SVal{B,T}, ::SNothing, stop::SVal{E,T}, len::SInteger) where {T<:Integer,B,E} =
    linspace(float(T), start, stop, len)
## for Float16, Float32, and Float64 we hit twiceprecision.jl to lift to higher precision StepRangeLen
# for all other types we fall back to a plain old LinRange
linspace(::Type{T}, start::SInteger, stop::SInteger, len::SInteger) where T = LinSRange{T}(start, stop, len)
#=
function linspace(
    ::Type{T},
    b::SInteger{B},
    e::SInteger{E},
    l::SInteger{L}
    ) where {T,B,E,L}
    snew = (E-B)/max(L-1, 1)
    if isa(snew, Integer)
        SRange{typeof(snew),SVal{oftype(snew, B)}(), SVal{oftype(snew, B)}(), SVal{snew}(), SVal{1}(),L}()
    else
        linspace(typeof(snew), b, e, l)
    end
end

=#
