abstract type StaticIndices{I,S,T,N,L} <: StaticArray{S,T,N} end

include("traits.jl")

Base.show(io::IO, si::StaticIndices) = showindices(io, si)
Base.show(io::IO, ::MIME"text/plain", si::StaticIndices) = showindices(io, si)

function showindices(io::IO, si::StaticIndices)
    for i in 1:ndims(si)
        print(io, "$(si.indices[i])\n")
    end
end

function _size()
end


#=
function LinearSIndices{I,S}() where {I,S}
    LinearSIndices{I,S,length(I.parameters)}()
end

function LinearSIndices{I,S,N}() where {I,S,N}
    LinearSIndices{I,S,N,prod(map(length, I.parameters))}()
end
=#

#=
@generated function unsafe_getindex(::LinearSIndices{I,S,N,L}, i::Int) where {I,S,N,L}
    out = :()
    sz = 1
    ind = :(i - 1)
    indnext = :()
    for D in 1:N
        indnext = :(div($ind, size(subinds, $D)))
        if D == 1
            out = :(first(subinds, $D) + ($ind - size(subinds, $D) * $indnext + 1 - firstindex(subinds, $D)) * step(subinds, $D))
        else
            out = :($out + $sz *
                    (first(subinds, $D) + ($ind - size(subinds, $D) *  $indnext + 1 - firstindex(subinds, $D)) * step(subinds, $D) - 1))
        end
        sz *= Size(S)[D]
        ind = indnext
    end
    return quote
        $out
    end
end

@pure length(::StaticIndices{I,S,T,N,L}) where {I,S,T,N,L} = L::Int
@pure static_length(::StaticIndices{I,S,T,N,L}) where {I,S,T,N,L} = SVal{L::Int,Int}()

#=
include("LinearSIndices.jl")
include("CartesianSIndices.jl")
=#

@inline StaticIndices(A::AbstractArray) = SubIndices(IndexStyle(A), A)
@inline StaticIndices(::IndexLinear, A) = LinearSIndices(A)
@inline StaticIndices(::IndexCartesian, A) = CartesianSIndices(A)


tmpfunc(args...;kwargs...) = (args, kwargs)


=#
