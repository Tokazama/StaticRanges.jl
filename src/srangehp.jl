function srangehp(
    ::Type{Float64},
    b::Tuple{<:SVal{Hb,<:Integer},<:SVal{Lb,<:Integer}},
    s::Tuple{<:SVal{Hs,<:Integer},<:SVal{Ls,<:Integer}},
    nb::SVal{N,<:Integer},
    l::SVal{L,<:Integer},
    f::SVal{F,<:Integer}) where {Hb,Lb,Hs,Ls,L,F,N}
    steprangelen(HPSVal{Float64}(b), HPSVal{Float64}(s, nb), l, f)
end

function srangehp(
    ::Type{T},
    b::Tuple{SVal{Hb,<:Integer},SVal{Lb,<:Integer}},
    s::Tuple{SVal{Hs,<:Integer},SVal{Ls,<:Integer}},
    nb::SInteger{N},
    l::SInteger{L},
    f::SInteger{F}) where {Hb,Lb,Hs,Ls,L,F,N,T<:Union{Float16, Float32, Float64}}
    steprangelen(T, SVal{Hb/Lb}(), SVal{Hs/Ls}(), SVal{Int(L)}(), f)
end

#=
srangehp(::Type{Float64},
::Tuple{SVal{1.0,Float64},SVal{0.0,Float64}},
::Tuple{SVal{1.0,Float64},SVal{0.0,Float64}},
::Int64, ::Int64, ::SVal{1,Int64})
  | b::Tuple{SVal{1,Int128},SVal{1,Int128}} = (SVal(1::Int128), SVal(1::Int128))
  | s::Tuple{SVal{1,Int128},SVal{1,Int128}} = (SVal(1::Int128), SVal(1::Int128))
  | nb::SVal{1,Int64} = SVal(1::Int64)
  | l::SVal{2,Int64} = SVal(2::Int64)
  | f::SVal{1,Int64} = SVal(1::Int64)
  | Hb::Int128 = 1
  | Lb::Int128 = 1
  | Hs::Int128 = 1
  | Ls::Int128 = 1
  | L::Int64 = 2
  | F::Int64 = 1
  | N::Int64 = 1
  | T::DataType = Float32
=#
function srangehp(
    ::Type{Float64},
    b::SVal{B,<:AbstractFloat},
    s::SVal{S,<:AbstractFloat},
    nb::SInteger{N},
    l::SInteger{L},
    f::SInteger{F}
   ) where {B,S,L,F,N}
   steprangelen(
       HPSVal{Float64}(b),
       twiceprecision(HPSVal{Float64}(s), nb),
       SVal{Int(L)}(),f)
end

function srangehp(
    ::Type{Float64},
    b::Tuple{SVal{Hb,<:AbstractFloat},SVal{Lb,<:AbstractFloat}},
    s::Tuple{SVal{Hs,<:AbstractFloat},SVal{Ls,<:AbstractFloat}},
    nb::SInteger{N},
    l::SInteger{L},
    f::SInteger{F}
   ) where {L,F,N,Hb,Lb,Hs,Ls}
   steprangelen(
       HPSVal{Float64}(SVal{Hb}(),SVal{Lb}()),
       twiceprecision(HPSVal{Float64}(SVal{Hb}(), SVal{Lb}()), nb),
       SVal{Int(L)}(),f)
end

#=
   b = (SVal(1.0::Float64), SVal(0.0::Float64))
   s = (SVal(1.0::Float64), SVal(0.0::Float64))
   n = SVal(0::Int64)
   l = SVal(2::Int64)
   f = SVal(1::Int64)
   StaticRanges.srangehp(Float64, b, s, n, l, f)
   L = 2
  | F = 1
  | N = 0
  | Hb = 1.0
  | Lb = 0.0
  | Hs = 1.0
  | Ls = 0.0
   StepRangeLen(_TP(ref),
                 twiceprecision(_TP(step), nb), Int(len), offset)
=#
function srangehp(
    ::Type{T},
    b::Tuple{SVal{Hb,<:AbstractFloat},SVal{Lb,<:AbstractFloat}},
    s::Tuple{SVal{Hs,<:AbstractFloat},SVal{Ls,<:AbstractFloat}},
    nb::SInteger{N},
    l::SInteger{L},
    f::SInteger{F}) where {L,F,Hb,Lb,Hs,Ls,N,T<:Union{Float16,Float32}}
    steprangelen(T, SVal{Float64(Hb) + Float64(Lb),Float64}(), SVal{Float64(Hs) + Float64(Ls),Float64}(), SVal{Int(L),Int}(), f)
end


function srangehp(
    ::Type{T},
    b::SVal{B,<:AbstractFloat},
    s::SVal{S,<:AbstractFloat},
    nb::SInteger,
    l::SInteger{L},
    f::SInteger{F}
    ) where {L,F,B,S,T<:Union{Float16,Float32}}
    steprangelen(T, SFloat64(b), SFloat64(s), SVal{Int(L),Int}(), f)
 end