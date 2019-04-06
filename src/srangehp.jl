const F_or_FF = Union{StaticFloat, Tuple{StaticFloat,StaticFloat}}
asF64(x::StaticFloat{V}) where V = SVal{Float64(V),Float64}()
asF64(x::Tuple{StaticFloat{V2},StaticFloat{V2}}) where {V1,V2} = SVal{Float64(V1) + Float64(V2),Float64}()


function srangehp(
    ::Type{Float64},
    b::Tuple{<:SVal{Hb,<:Integer},<:SVal{Lb,<:Integer}},
    s::Tuple{<:SVal{Hs,<:Integer},<:SVal{Ls,<:Integer}},
    nb::SVal{N,<:Integer},
    l::SVal{L,<:Integer},
    f::SVal{F,<:Integer}) where {Hb,Lb,Hs,Ls,L,F,N}
    steprangelen(HPSVal{Float64}(b), HPSVal{Float64}(s, nb), l, f)
end
#=
b = (SVal(Int128(3)), SVal(Int128(3)))
   s = (SVal(Int128(3)), SVal(Int128(3)))
    nb = SVal(Int(3))
    l = SVal(4)
    f = SVal(1)
  | l::SVal{4,Int64} = SVal(4::Int64)
  | f::SVal{1,Int64} = SVal(1::Int64)
  =#


function srangehp(
    ::Type{T},
    b::Tuple{SVal{Hb,<:Integer},SVal{Lb,Integer}},
    s::Tuple{SVal{Hs,<:Integer},SVal{Ls,Integer}},
    nb::SInteger{N},
    l::SInteger{L},
    f::SInteger{F}) where {Hb,Lb,Hs,Ls,L,F,N,T<:Union{Float16, Float32, Float64}}
    steprangelen(T, SVal{Hb/Lb}(), SVal{Hs/Ls}(), SVal{Int(L)}(), f)
end

function srangehp(
    ::Type{Float64},
    b::F_or_FF,
    s::F_or_FF,
    nb::SInteger{N},
    l::SInteger{L},
    f::SInteger{F}
   ) where {L,F,N}
   steprangelen(HPSVal{Floa64}(b), SNothing(), twiceprecision(HPSVal{Float64}(s), nb), SVal{Int(L)}(), f)
end


function srangehp(
    ::Type{T},
     b::F_or_FF,
     s::F_or_FF,
     nb::Integer,
     l::SInteger{L},
     f::SInteger{F}) where {L,F,T<:Union{Float16,Float32}}
     steprangelen(T, asF64(b), asF64(s), SVal{Int(L),Int}(), f)
 end