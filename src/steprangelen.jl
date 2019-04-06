function steprangelen(b::SVal{B,Tb}, s::SVal{S,Ts}, l::SInteger{L}, f::SInteger{F}=SVal{1,Int}()) where {B,Tb,S,Ts,L,F}
    steprangelen(typeof(B+0*S), b, s, l, f)
end

function steprangelen(b::HPSVal{T,Hb,Lb}, s::HPSVal{T,Hs,Ls}, l::SInteger{L}, f::SInteger{F}=SVal{1,Int}()) where {T,Hb,Lb,Hs,Ls,L,F}
    steprangelen(T, HPSVal{T,Hb,Lb}(), HPSVal{T,Hs,Ls}(), l, f)
end

function steprangelen(::Type{T}, b::SVal{B,Tb}, s::SVal{S,Ts}, l::SInteger{L}, f::SInteger{F}=SVal{1,Int}()) where {T,B,Tb,S,Ts,L,F}
    SRange{T,SVal{B,Tb},SVal{S,Ts},T(B + (L-F) * S),L,F}()
end

function steprangelen(
    ::Type{T},
    b::HPSVal{Tb,Hb,Lb},
    s::HPSVal{Ts,Hs,Ls},
    l::SInteger{L},
    f::SInteger{F}=SVal{1,Int}()
    ) where {T,Tb,Hb,Lb,Ts,Hs,Ls,L,F}
    u = L - F
    shift_hi, shift_lo = u*Hs, u*Ls
    x_hi, x_lo = Base.add12(Hb, shift_hi)
    SRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},T(x_hi + (x_lo + (shift_lo + Lb))),L,F}()
end

function *(x::Real, r::StaticRange{<:Real,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    oftype(r, steprangelen(x*HPSVal{Tb,Hb,Lb}(), twiceprecision(x*HPSVal{Ts,Hs,Ls}(), nbitslen(r)), SVal{L}(), SVal{F}()))
end

*(r::StaticRange{<:Real,<:HPSVal}, x::Real) = x*r

function /(x::Real, r::StaticRange{<:Real,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    steprangelen(HPSVal{Tb,Hb,Lb}()/x, twiceprecision(HPSVal{Ts,Hs,Ls}()/x, nbitslen(r)), SVal{L}(), SVal{F}(0))
end

function sum(r::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    # Compute the contribution of step over all indices.
    # Indexes on opposite side of r.offset contribute with opposite sign,
    #    r.step * (sum(1:np) - sum(1:nn))
    np, nn = L - F, F - 1  # positive, negative
    # To prevent overflow in sum(1:n), multiply its factors by the step
    sp, sn = sumpair(np), sumpair(nn)
    tp = _tp_prod(SVal{Ts,Hs,Ls}(), sp[1], sp[2])
    tn = _tp_prod(r.step, sn[1], sn[2])
    s_hi, s_lo = add12(tp.hi, -tn.hi)
    s_lo += tp.lo - tn.lo
    # Add in contributions of ref
    ref = r.ref * l
    sm_hi, sm_lo = add12(s_hi, ref.hi)
    add12(sm_hi, sm_lo + ref.lo)[1]
end

# sum(1:n) as a product of two integers
#=
sumpair(n::Integer) = iseven(n) ? (n+1, n>>1) : (n, (n+1)>>1)

function +(r1::StaticRange{T,HPSVal{Tb}}, r2::StaticRange{T,HPSVal{Hb}}) where {T,Tb}
    len = length(r1)
    (len == length(r2) ||
        throw(DimensionMismatch("argument dimensions must match")))
    if r1.offset == r2.offset
        imid = r1.offset
        ref = r1.ref + r2.ref
    else
        imid = round(Int, (r1.offset+r2.offset)/2)
        ref1mid = _getindex_hiprec(r1, imid)
        ref2mid = _getindex_hiprec(r2, imid)
        ref = ref1mid + ref2mid
    end
    step = twiceprecision(r1.step + r2.step, nbitslen(T, len, imid))
    StepRangeLen{T,typeof(ref),typeof(step)}(ref, step, len, imid)
end
=#

#= not sure if this is really applicable with static ranges
StepRangeLen{T,R,S}(r::StepRangeLen{T,R,S}) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision} = r

(::Type{StepRangeLen{Float64}})(r::StepRangeLen) =
    _convertSRL(StepRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
StepRangeLen{T}(r::StepRangeLen) where {T<:IEEEFloat} =
    _convertSRL(StepRangeLen{T,Float64,Float64}, r)

(::Type{StepRangeLen{Float64}})(r::AbstractRange) =
    _convertSRL(StepRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
StepRangeLen{T}(r::AbstractRange) where {T<:IEEEFloat} =
    _convertSRL(StepRangeLen{T,Float64,Float64}, r)

function _convertSRL(::Type{StepRangeLen{T,R,S}}, r::StepRangeLen{<:Integer}) where {T,R,S}
    StepRangeLen{T,R,S}(R(r.ref), S(r.step), length(r), r.offset)
end

function _convertSRL(::Type{StepRangeLen{T,R,S}}, r::AbstractRange{<:Integer}) where {T,R,S}
    StepRangeLen{T,R,S}(R(first(r)), S(step(r)), length(r))
end

function _convertSRL(::Type{StepRangeLen{T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
    # if start and step have a rational approximation in the old type,
    # then we transfer that rational approximation to the new type
    f, s = first(r), step(r)
    start_n, start_d = rat(f)
    step_n, step_d = rat(s)
    if start_d != 0 && step_d != 0 &&
            U(start_n/start_d) == f && U(step_n/step_d) == s
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if den != 0 && abs(f*den) <= m && abs(s*den) <= m &&
                rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, f*den)
            step_n = round(Int, s*den)
            return floatrange(T, start_n, step_n, length(r), den)
        end
    end
    __convertSRL(StepRangeLen{T,R,S}, r)
end

function __convertSRL(::Type{StepRangeLen{T,R,S}}, r::StepRangeLen{U}) where {T,R,S,U}
    StepRangeLen{T,R,S}(R(r.ref), S(r.step), length(r), r.offset)
end
function __convertSRL(::Type{StepRangeLen{T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
    StepRangeLen{T,R,S}(R(first(r)), S(step(r)), length(r))
end

=#