# TODO:
# Make tests
#   - winds
abstract type SlidingWindow{W<:Tuple,S<:Tuple,P<:Tuple,T,N,L} <: AbstractArray{T,N} end

const SlidingWindowUnion{W,S,P,T,N,L} = Union{SlidingWindow{W,S,P,T,N,L},Type{<:SlidingWindow{W,S,P,T,N,L}}}


for (M1,M2) in ((:wfirst, :_first), (:wlast,   :_last),   (:wstep,   :_step),
                (:wsize,  :_size),  (:woffset, :_offset), (:weltype, :_eltype))
    @eval begin
        @pure $M1(::SlidingWindowUnion{W,S,P,T,N,0}, i::Int) where {W,S,P,T,N} = 0
        @pure $M1(::SlidingWindowUnion{W,S,P,T,N,L}, i::Int) where {W,S,P,T,N,L} = i <= N ? $M2(W, i) : 1
        @pure $M1(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = $M2(W)
    end
end
@pure wlength(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = prod(_size(W))


for (M1,M2) in ((:sfirst, :_first), (:slast,   :_last),   (:sstep,   :_step),
                (:ssize,  :_size),  (:soffset, :_offset), (:seltype, :_eltype))
    @eval begin
        @pure $M1(::SlidingWindowUnion{W,S,P,T,N,0}, i::Int) where {W,S,P,T,N} = 0
        @pure $M1(::SlidingWindowUnion{W,S,P,T,N,L}, i::Int) where {W,S,P,T,N,L} = i <= N ? $M2(S, i) : 1
        @pure $M1(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = $M2(S)
    end
end
@pure slength(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = prod(_size(S))

@pure length(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = L::Int
@pure size(::SlidingWindowUnion{W,S,P,T,N,L}, i::Int) where {W,S,P,T,N,L} =
    (_size(W, i) * _size(S, i))::Int
@pure size(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} =
    ntuple(i->_size(W, i) * _size(S, i), Val(N))::NTuple{N,Int}
@pure eltype(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = T
@pure Base.ndims(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = N::Int

@pure psize(::SlidingWindowUnion{W,S,P,T,N,L}, i::Int) where {W,S,P,T,N,L} = fieldtype(P, i)::Int
@pure psize(::SlidingWindowUnion{W,S,P,T,N,L}) where {W,S,P,T,N,L} = (P.parameters...,)::NTuple{N,Int}

@pure @inline function to_inds(sw::SlidingWindowUnion{W,S,P,T,N,L}, i::Int, s::Int) where {W,S,P,T,N,L}
    @_propagate_inbounds_meta
    @boundscheck if i < 1 || i > wlength(sw) || s < 1 || s > slength(sw)
        throw(BoundsError(sw, (i,s)))
    end
    out = 0
    sz = 1
    ind = i - 1
    indnext = 0

    stride_ind = s - 1
    stride_indnext = 0
    for D in 1:N
        indnext = div(ind, wsize(sw, D))
        sindnext = div(stride_ind, ssize(sw, D))
        if D == 1
            out +=  ((wfirst(sw, D) + (       ind - wsize(sw, D) *  indnext + 1 - woffset(sw, D)) * wstep(sw, D)) +
                     (sfirst(sw, D) + (stride_ind - ssize(sw, D) * sindnext + 1 - soffset(sw, D)) * sstep(sw, D)))
        else
            out += sz *
                    (((wfirst(sw, D) + (       ind - wsize(sw, D) *  indnext + 1 - woffset(sw, D)) * wstep(sw, D)) +
                     (sfirst(sw, D) + (stride_ind - ssize(sw, D) * sindnext + 1 - soffset(sw, D)) * sstep(sw, D))) - 1)
                   #((wfirst(sw, D) + (wfirst(sw, D) + ( ind - wsize(sw, D) *  indnext + wfirst(sw, D) - woffset(sw, D)) - woffset(sw, D)) * wstep(sw, D)) *
                   #                  (sfirst(sw, D) + ((stride_ind - ssize(sw, D) * sindnext + 1) - soffset(sw, D)) * sstep(sw, D)) - 1)
                    #(sfirst(sw, D) + (sfirst(sw, D) + (sind - ssize(sw, D) * sindnext + sfirst(sw, D) - soffset(sw, D)) - soffset(sw, D)) * sstep(sw, D)) - 1)
        end
        sz *= psize(sw, D)
        ind = indnext
        stride_ind
    end
    out
end

function Base.checkbounds(sw::SlidingWindowUnion{W,S,P,T,N,L}, i::Int, s::Int) where {W,S,P,T,N,L}
    if 1 > i || i > wlength(sw)
        throw(BoundsError(sw, i))
    elseif 1 > s || s > slength(sw)
        throw(BoundsError(sw, s))
    end
end

# TODO: SlidingWindow error messages
function check_slidingwindow_params(W,S,P,N,L)
    for i in OneToSRange{N}
        if _size(W, i) * _last(S, i) > P.parameters[i]
            error("")
        elseif _first(W, i) * _first(S, i) < 1
            error("")
        end
    end
end



struct SWIterator{W,S,P,N,L} <: SlidingWindow{W,S,P,Int,N,L}
    function SWIterator{W,S,P,N,L}() where {W,S,P,N,L}
        check_slidingwindow_params(W,S,P,N,L)
        new{W,S,P,N,L}()
    end
end

SWIterator(p::NTuple{N,Int}, window::W, stride::S) where {N,W<:Tuple{Vararg{<:StaticRange,N}},S<:Tuple{Vararg{<:StaticRange,N}}} =
    SWIterator{W,S,Tuple{p...}}()
SWIterator{W,S,P}() where {W,S,P} = SWIterator{W,S,P,length(P.parameters)}()
SWIterator{W,S,P,N}() where {W,S,P,N} = SWIterator{W,S,P,N,prod(_size(W))*prod(_size(S))}()

SWIterator(p::AbstractArray, window::Tuple{Vararg{<:StaticRange,N}}, stride::Tuple{Vararg{<:StaticRange,N}}=map(_->1,1:N)) where N =
    SWIterator(size(p), window, stride)
SWIterator(p::StaticArray{S,T,N}, window::Tuple{Vararg{<:StaticRange,N}}, stride::Tuple{Vararg{<:StaticRange,N}}=map(_->1,1:N)) where {S,T,N} =
    SWIterator{typeof(window),typeof(stride),S}()

SWIterator(psize::NTuple{N,Int}, wsize::NTuple{N,Int}, stride::NTuple{N,Int}, dilation::NTuple{N,Int}) where N =
    SWIterator{  Tuple{map(i->StaticRange{Int,1,wsize[i],dilation[i],1,div(wsize[i]-1,dilation[i])+1}, 1:N)...}}(psize, stride)
SWIterator{W}(psize::NTuple{N,Int}, stride::NTuple{N,Int}) where {W,N} =
    SWIterator{W,Tuple{map(i->StaticRange{Int,1,stride[i],1,1,1}, 1:N)...},Tuple{psize...}}()

"""

srange(Ew, P, step=S)
    getindex(w, i, s)

```jldoctest
using TiledIteration

A = reshape([1:10000...], (100,100));
titrs = TileIterator(axes(A), (10,10));
tile1, itr = iterate(titrs)


li = LinearIndices((100, 100));

w = (srange(1,20,step=2),srange(1,20,step=2))
s = (srange(0,40,step=10),srange(0,40,step=10))
sw = SWIterator(li, w,s);

li[w...][1] == sw[1, 1]
li[w...][6] == sw[6, 1]
li[w...][11] == sw[11, 1]




for tileaxs in TileIterator(axes(A), (10,10))
    @show tileaxs
end

```
"""
# index linear into which strides
# stride sub indices into window indices --> linear index
@inline function getindex(sw::SlidingWindow{W,S,P,T,N,L}, i::Int, s::Int) where {W,S,P,T,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(sw, i, s)
    #=
    ind = s - 1
    indnext = 0
    stride = 1
    s2i = 0
    for D in 1:N
        indnext = div(ind, ssize(sw, D))
        s2i += (wfirst(sw, D) + (ind - ssize(sw, 1) * indnext + sfirst(sw, 1))) +
               (i + woffset(sw, D)) * wstep(sw, D)
        stride *= psize(sw, D)
        ind = indnext
    end
    =#
    return to_inds(sw, i, s)
end
