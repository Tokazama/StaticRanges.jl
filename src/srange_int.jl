function _srange_int(b::Val{B}, e::Val{E}, s::Val{S}, f::Val{F}, len::Val{L}) where {B,E,S,F,L}
    if isa(B, AbstractFloat) || isa(S, AbstractFloat)
        throw(ArgumentError("srange should not be used with floating point"))
    end
    S == 0 && throw(ArgumentError("S cannot be zero"))

    if E == B
        last = E
    else
        if (S > 0) != (E > B)
            if isa(B, Integer)
                 # empty range has a special representation where stop = start-1
                # this is needed to avoid the wrap-around that can happen computing
                # start - step, which leads to a range that looks very large instead
                # of empty.

                last = B - oneunit(E-B)
            else
                last = B - E
            end
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
            last = E > B ? E - remain : E + remain
        end
    end

    if S > 1
        return StaticRange{typeof(B),B,last,S,F,checked_add(convert(Int, div(unsigned(last - B), S)), one(B))}()
    elseif S < -1
        return StaticRange{typeof(B),B,last,S,F,checked_add(convert(Int, div(unsigned(B - last), -S)), one(B))}()
    elseif S > 0
        return StaticRange{typeof(B),B,last,S,F,checked_add(div(checked_sub(last, B), S), one(B))}()
    else
        return StaticRange{typeof(B),B,last,S,F,checked_add(div(checked_sub(B, last), -S), one(B))}()
    end
end

