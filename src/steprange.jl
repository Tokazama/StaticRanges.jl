function steprange(b::SVal{B,T}, s::SVal{S,Ts}, e::SVal{E,T}) where {T,Ts,B,S,E}
    steprange(T, b, s, steprange_last(b, s, e))
end


# srange(1:2:0)
function steprange(::Type{T}, b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Tb}) where {T,B,Tb,S,Ts,E}
    e = steprange_last(b, s, e)
    SRange{T,SVal{B,Tb},SVal{S,Ts},get(e),steprange_length(b,s,e),1}()
end

function steprange_length(b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}) where {B,E,S,T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    (B != E) & ((S > zero(S))) != (E > B) && return T(0)
    if S > 1
        return Base.Checked.checked_add(Int(div(unsigned(E - B), S)), one(B))
    elseif S < -1
        return Base.Checked.checked_add(Int(div(unsigned(B - E), -S)), one(B))
    elseif S > 0
        return Int(Base.Checked.checked_add(div(Base.Checked.checked_sub(E, B), S), one(B)))
    else
        return Int(Base.Checked.checked_add(div(Base.Checked.checked_sub(B, E), -S), one(B)))
    end
end

function steprange_length(b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}) where {B,E,S,T}
    n = Int(div((E - B) + S, S))
    (B != E) & ((S > zero(S))) != (E > B) ? zero(n) : n
end

steprange_last(b::SVal{B,T}, s::SVal{S}, e::SVal{B,T}) where {B,S,T} = b
function steprange_last(b::SVal{B}, s::SVal{S}, e::SVal{E}) where {B,S,E}
    z = zero(s)
    s == z && throw(ArgumentError("step cannot be zero"))

    if (S > 0) != (E > B)
        last = steprange_last_empty(b, s, e)
    else
        # Compute absolute value of difference between `B` and `E`
        # (to simplify handling both signed and unsigned T and checking for signed overflow):
        absdiff, absstep = E > B ? (E - B, S) : (B - E, -S)

        # Compute remainder as a nonnegative number:
        if typeof(B) <: Signed && absdiff < zero(absdiff)
            # handle signed overflow with unsigned rem
            remain = typeof(B, unsigned(absdiff) % absstep)
        else
            remain = absdiff % absstep
        end
        # Move `E` closer to `B` if there is a remainder:
        last = E > B ? SVal{E - remain}() : SVal{E + remain}()
    end
    return last
end


function steprange_last_empty(::SInteger{B}, ::SVal{S}, ::SVal{E}) where {B,E,S}
    # empty range has a special representation where stop = start-1
    # this is needed to avoid the wrap-around that can happen computing
    # start - step, which leads to a range that looks very large instead
    # of empty.
    if S > zero(S)
        return SVal{B - oneunit(E-B)}()
    else
        return SVal{B + oneunit(E-B)}()
    end
end
steprange_last_empty(::SVal{B}, ::SVal{S}, ::SVal{E}) where {B,E,S} = SVal{B-S}()