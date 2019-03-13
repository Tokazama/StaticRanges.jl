Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)

function showrange(io::IO, r::StaticRange)
    print(io, "StaticRange(")
    show_mimic_range(io, r)
    print(io, ")")
end

#$(StaticRange)($(B):$(S):$(E))")
show_mimic_range(io::IO, ::StaticRange{T,B,E,S}) where {T,B,E,S} = print(io, "$(B):$(S):$(E)")
show_mimic_range(io::IO, ::UnitSRange{T,B,E,S}) where {T,B,E,S} = print(io, "$(B):$(E)")
show_mimic_range(io::IO, ::OneToSRange{N}) where {N} = print(io, "OneTo($(N))")

# ensure that sub range is integer (indexing) rane
#function show_mimic_range(io::IO, ::SubRange{Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T}) where {Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T}
#    showmimicrange(io, SRange{Bp,Ep,Sp,Lp,T}())
#    print(io, "[")
#    showmimicrange(io, SRange{Bi,Ei,Si,Li,Int}())
#    print(io, "]")
#end
#
#Base.show(io::IO, r::SubRange) = showrange(io, r)
#Base.show(io::IO, ::MIME"text/plain", r::SubRange) = showrange(io, r)
#
#function showrange(io::IO,
#    ::WindowRange{SubRange{Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T},SRange{Bs,Es,Ss,Ls,Int}}) where {Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T,Bs,Es,Ss,Ls}
#    print(io, "$T  WindowRange\n  ")
#
#    showmimicrange(io, SRange{Bp,Ep,Sp,Lp,T}())
#    print(io, "[")
#    showmimicrange(io, SRange{Bi,Ei,Si,Li,Int}())
#    print(io, "]")
#    print(io, " .+ $(Bs):$(Ss):$(Es)")
#end
#Base.show(io::IO, r::WindowRange) = showrange(io, r)
#Base.show(io::IO, ::MIME"text/plain", r::WindowRange) = showrange(io, r)



function showsindices(io::IO, inds::StaticIndices{S,T,N,L}) where {S,T,N,L}
    print(io, "$(typeof(inds).name)")
    showaxes(io, inds)
end

function showaxes(io::IO, inds::SubIndices{I,P,S,T,N,L}) where {I,P,S,T,N,L}
    for i in OneToSRange(N)
        print(io, "\n  ", fieldtype(I, i)())
    end
end

function showaxes(io::IO, inds::StaticIndices{S,T,N,L}) where {S,T,N,L}
    for i in OneToSRange(N)
        print(io, "\n  ", OneToSRange(fieldtype(S,i)))
    end
end


#Base.show(io::IO, inds::StaticIndices) = showsindices(io, inds)
#Base.show(io::IO, ::MIME"text/plain", inds::StaticIndices) = showsindices(io, inds)

# enable base range like interactions
@inline function Base.getproperty(r::StaticRange{T,B,E,S,L}, sym::Symbol) where {T,B,E,S,L}
    if sym === :step
        return step(r)::T
    elseif sym === :start
        return first(r)::T
    elseif sym === :stop
        return last(r)::T
    elseif sym === :len
        return length(r)::Int
    elseif sym === :lendiv
        return (E - B) / S
    elseif sym === :ref  # for now this is just treated the same as start
        return B
    elseif sym === :offset
        return 1   # TODO: should probably go back and actually implement this
    else
        error("type $(typeof(r)) has no field $sym")
    end
end

#include("MDTraits/MDTraits.jl")
