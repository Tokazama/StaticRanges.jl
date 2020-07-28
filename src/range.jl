
"""
    srange(start[, stop]; length, stop, step=1)

Constructs static ranges within similar syntax and argument semantics as `range`.

## Examples
```jldoctest
julia> using StaticRanges

julia> srange(1, length=100)
UnitSRange(1:100)

julia> srange(1, stop=100)
UnitSRange(1:100)

julia> srange(1, step=5, length=100)
StepSRange(1:5:496)

julia> srange(1, step=5, stop=100)
StepSRange(1:5:96)

julia> srange(1, step=5, stop=100)
StepSRange(1:5:96)

julia> srange(1, 10, length=101)
StepSRangeLen(1.0:0.09:10.0)

julia> srange(1, 100, step=5)
StepSRange(1:5:96)

julia> srange(1, 10)
UnitSRange(1:10)

julia> srange(1.0, length=10)
StepSRangeLen(1.0:1.0:10.0)

```
"""
srange

"""
    mrange(start[, stop]; length, stop, step=1)

Constructs static ranges within similar syntax and argument semantics as `range`.

## Examples
```jldoctest
julia> using StaticRanges

julia> mrange(1, length=100)
UnitMRange(1:100)

julia> mrange(1, stop=100)
UnitMRange(1:100)

julia> mrange(1, step=5, length=100)
StepMRange(1:5:496)

julia> mrange(1, step=5, stop=100)
StepMRange(1:5:96)

julia> mrange(1, step=5, stop=100)
StepMRange(1:5:96)

julia> mrange(1, 10, length=101)
StepMRangeLen(1.0:0.09:10.0)

julia> mrange(1, 100, step=5)
StepMRange(1:5:96)

julia> mrange(1, 10)
UnitMRange(1:10)

julia> mrange(1.0, length=10)
StepMRangeLen(1.0:1.0:10.0)
```
"""
mrange

for (F,f) in ((:M,:m), (:S,:s))
    frange = Symbol(f, :range)
    _frange = Symbol(:_, f, :range)
    _fcolon_colon = Symbol(:_, f, :colon_colon)
    fcolon = Symbol(:_, f, :colon)
    _frangestyle = Symbol(:_, f, :rangestyle)
    floatfrange = Symbol(:float, f, :range)
    stepfrangelen_hp = Symbol(:step, f, :rangelen_hp)
    flinspace1 = Symbol(:_, f, :linspace1)
    flinspace = Symbol(:_, f, :linspace)

    LINR = Symbol(:Lin, F, :Range)
    SRL = Symbol(:Step, F, :RangeLen)
    SR = Symbol(:Step, F, :Range)
    UR = Symbol(:Unit, F, :Range)
    @eval begin
        function $(frange)(start; length::Union{Integer,Nothing}=nothing, stop=nothing, step=nothing)
            return $(_frange)(start, step, stop, length)
        end

        function $(frange)(start, stop; length::Union{Integer,Nothing}=nothing, step=nothing)
            return $(_frange)(start, step, stop, length)
        end

        # Range from start to stop: range(a, [step=s,] stop=b), no length
        $(_frange)(start, step,      stop, ::Nothing) = $(fcolon)(start, step, stop)
        $(_frange)(start, ::Nothing, stop, ::Nothing) = $(fcolon)(start, stop)

        $(fcolon)(a::Real, b::Real) = $(fcolon)(promote(a,b)...)

        $(fcolon)(start::T, stop::T) where {T<:Real} = $(UR){T}(start, stop)

        $(fcolon)(start::T, stop::T) where {T} = $(fcolon)(start, oftype(stop-start, 1), stop)

        $(fcolon)(a::T, b::T) where {T<:AbstractFloat} = $(fcolon)(a, T(1), b)

       function $(fcolon)(a::T, b::AbstractFloat, c::T) where {T<:Real}
            return $(fcolon)(promote(a,b,c)...)
        end
        function $(fcolon)(a::T, b::AbstractFloat, c::T) where {T<:AbstractFloat}
            return $(fcolon)(promote(a,b,c)...)
        end
        function $(fcolon)(a::T, b::Real, c::T) where {T<:AbstractFloat}
            return $(fcolon)(promote(a,b,c)...)
        end

        # promote start and stop, leaving step alone
        function $(fcolon)(start::A, step, stop::C) where {A<:Real,C<:Real}
            return $(fcolon)(convert(promote_type(A, C), start),
                             step,
                             convert(promote_type(A, C), stop)
                            )
        end
        function $(fcolon)(start::T, step, stop::T) where {T}
            return $(_fcolon_colon)(start, step, stop)
        end
        function $(fcolon)(start::T, step, stop::T) where {T<:Real}
            return $(_fcolon_colon)(start, step, stop)
        end
 

        function $(fcolon)(start::T, step::T, stop::T) where T<:Union{Float16,Float32,Float64}
            step == 0 && throw(ArgumentError("range step cannot be zero"))
            # see if the inputs have exact rational approximations (and if so,
            # perform all computations in terms of the rationals)
            step_n, step_d = Base.rat(step)
            if step_d != 0 && T(step_n/step_d) == step
                start_n, start_d = Base.rat(start)
                stop_n, stop_d = Base.rat(stop)
                if start_d != 0 && stop_d != 0 &&
                        T(start_n/start_d) == start && T(stop_n/stop_d) == stop
                    den = lcm(start_d, step_d) # use same denominator for start and step
                    m = maxintfloat(T, Int)
                    if den != 0 && abs(start*den) <= m && abs(step*den) <= m &&  # will round succeed?
                            rem(den, start_d) == 0 && rem(den, step_d) == 0      # check lcm overflow
                        start_n = round(Int, start*den)
                        step_n = round(Int, step*den)
                        len = max(0, div(den*stop_n - stop_d*start_n + step_n*stop_d, step_n*stop_d))
                        # Integer ops could overflow, so check that this makes sense
                        if Base.isbetween(start, start + (len-1)*step, stop + step/2) &&
                                !Base.isbetween(start, start + len*step, stop)
                            # Return a 2x precision range
                            return $(floatfrange)(T, start_n, step_n, len, den)
                        end
                    end
                end
            end
            # Fallback, taking start and step literally
            lf = (stop-start)/step
            if lf < 0
                len = 0
            elseif lf == 0
                len = 1
            else
                len = round(Int, lf) + 1
                stop′ = start + (len-1)*step
                # if we've overshot the end, subtract one:
                len -= (start < stop < stop′) + (start > stop > stop′)
            end
            return $(stepfrangelen_hp)(T, start, step, 0, len, 1)
        end
        # AbstractFloat specializations
        function $(_fcolon_colon)(start::T, step, stop::T) where {T}
            T′ = typeof(start+zero(step))
            return $(SR)(convert(T′,start), step, convert(T′,stop))
        end

        function $(fcolon)(start::T, step::T, stop::T) where {T<:AbstractFloat}
            return $(_fcolon_colon)(Base.OrderStyle(T), Base.ArithmeticStyle(T), start, step, stop)
        end
        $(fcolon)(start::T, step::T, stop::T) where {T<:Real} =
            $(_fcolon_colon)(Base.OrderStyle(T), Base.ArithmeticStyle(T), start, step, stop)
        $(_fcolon_colon)(::Base.Ordered, ::Any, start::T, step, stop::T) where {T} = $(SR)(start, step, stop)
        # for T<:Union{Float16,Float32,Float64} see twiceprecision.jl
        $(_fcolon_colon)(::Base.Ordered, ::Base.ArithmeticRounds, start::T, step, stop::T) where {T} =
            $(SRL)(start, step, floor(Int, (stop-start)/step)+1)
        $(_fcolon_colon)(::Any, ::Any, start::T, step, stop::T) where {T} =
            $(SRL)(start, step, floor(Int, (stop-start)/step)+1)
        # range of a given length: range(a, [step=s,] length=l), no stop
        $(_frange)(a::Real,          ::Nothing,         ::Nothing, len::Integer) = $(UR){typeof(a)}(a, oftype(a, a+len-1))
        $(_frange)(a::AbstractFloat, ::Nothing,         ::Nothing, len::Integer) = $(_frange)(a, oftype(a, 1),   nothing, len)
        $(_frange)(a::AbstractFloat, st::AbstractFloat, ::Nothing, len::Integer) = $(_frange)(promote(a, st)..., nothing, len)
        $(_frange)(a::Real,          st::AbstractFloat, ::Nothing, len::Integer) = $(_frange)(float(a), st,      nothing, len)
        $(_frange)(a::AbstractFloat, st::Real,          ::Nothing, len::Integer) = $(_frange)(a, float(st),      nothing, len)
        $(_frange)(a,                ::Nothing,         ::Nothing, len::Integer) = $(_frange)(a, oftype(a-a, 1), nothing, len)

        function $(_frange)(a::T, step::T, ::Nothing, len::Integer) where {T <: AbstractFloat}
            return $(_frangestyle)(Base.OrderStyle(T), Base.ArithmeticStyle(T), a, step, len)
        end
        function $(_frange)(a::T, step, ::Nothing, len::Integer) where {T}
            return $(_frangestyle)(Base.OrderStyle(T), Base.ArithmeticStyle(T), a, step, len)
        end
        function $(_frangestyle)(::Base.Ordered, ::Base.ArithmeticWraps, a::T, step::S, len::Integer) where {T,S}
            return $(SR){T,S}(a, step, convert(T, a+step*(len-1)))
        end
        function $(_frangestyle)(::Any, ::Any, a::T, step::S, len::Integer) where {T,S}
            return $(SRL){typeof(a+0*step),T,S}(a, step, len)
        end

        function $(_frange)(start::T, ::Nothing, stop::T, len::Integer) where {T<:IEEEFloat}
            len < 2 && return $(flinspace1)(T, start, stop, len)
            start == stop && $(stepfrangelen_hp)(T, start, zero(T), 0, len, 1)
            # Attempt to find exact rational approximations
            start_n, start_d = rat(start)
            stop_n, stop_d = rat(stop)
            if start_d != 0 && stop_d != 0
                den = lcm(start_d, stop_d)
                m = maxintfloat(T, Int)
                if den != 0 && abs(den*start) <= m && abs(den*stop) <= m
                    start_n = round(Int, den*start)
                    stop_n = round(Int, den*stop)
                    if T(start_n/den) == start && T(stop_n/den) == stop
                        return $(flinspace)(T, start_n, stop_n, len, den)
                    end
                end
            end
            return $(flinspace)(start, stop, len)
        end

        $(_frange)(start,     step,      ::Nothing, ::Nothing) = # range(a, step=s)
            throw(ArgumentError("At least one of `length` or `stop` must be specified"))
        $(_frange)(start,     ::Nothing, ::Nothing, ::Nothing) = # range(a)
            throw(ArgumentError("At least one of `length` or `stop` must be specified"))
        $(_frange)(::Nothing, ::Nothing, ::Nothing, ::Nothing) = # range(nothing)
            throw(ArgumentError("At least one of `length` or `stop` must be specified"))
        $(_frange)(start::Real, step::Real, stop::Real, length::Integer) = # range(a, step=s, stop=b, length=l)
            throw(ArgumentError("Too many arguments specified; try passing only one of `stop` or `length`"))
        $(_frange)(::Nothing, ::Nothing, ::Nothing, ::Integer) = # range(nothing, length=l)
            throw(ArgumentError("Can't start a range at `nothing`"))


        function $(_frange)(start::T, ::Nothing, stop::S, len::Integer) where {T,S}
            a, b = promote(start, stop)
            return $(_frange)(a, nothing, b, len)
        end
        $(_frange)(start::T, ::Nothing, stop::T, len::Integer) where {T<:Real} = $(LINR){T}(start, stop, len)
        $(_frange)(start::T, ::Nothing, stop::T, len::Integer) where {T} = $(LINR){T}(start, stop, len)
        $(_frange)(start::T, ::Nothing, stop::T, len::Integer) where {T<:Integer} =
            $(flinspace)(float(T), start, stop, len)
        ## for Float16, Float32, and Float64 we hit twiceprecision.jl to lift to higher precision StepRangeLen
        # for all other types we fall back to a plain old LinRange
        $(flinspace)(::Type{T}, start::Integer, stop::Integer, len::Integer) where T = $(LINR){T}(start, stop, len)

        function $(flinspace)(::Type{T}, start::Integer, stop::Integer, len::Integer) where {T<:IEEEFloat}
            return $(flinspace)(T, start, stop, len, 1)
        end
        function $(flinspace)(
            ::Type{T},
            start_n::Integer,
            stop_n::Integer,
            len::Integer,
            den::Integer
           ) where {T<:IEEEFloat}
            len < 2 && return $(flinspace1)(T, start_n/den, stop_n/den, len)
            start_n == stop_n && return $(stepfrangelen_hp)(T, (start_n, den), (zero(start_n), den), 0, len, 1)
            tmin = -start_n/(Float64(stop_n) - Float64(start_n))
            imin = round(Int, tmin*(len-1)+1)
            imin = clamp(imin, 1, Int(len))
            ref_num = Int128(len-imin) * start_n + Int128(imin-1) * stop_n
            ref_denom = Int128(len-1) * den
            ref = (ref_num, ref_denom)
            step_full = (Int128(stop_n) - Int128(start_n), ref_denom)
            return $(stepfrangelen_hp)(T, ref, step_full,  nbitslen(T, len, imin), Int(len), imin)
        end

        function $(flinspace1)(::Type{T}, start, stop, len::Integer) where {T<:IEEEFloat}
            len >= 0 || throw(ArgumentError("range($start, stop=$stop, length=$len): negative length"))
            if len <= 1
                len == 1 && (start == stop || throw(ArgumentError("range($start, stop=$stop, length=$len): endpoints differ")))
                # Ensure that first(r)==start and last(r)==stop even for len==0
                # The output type must be consistent with steprangelen_hp
                if T<:Union{Float32,Float16}
                    return $(SRL){T}(Float64(start), Float64(start) - Float64(stop), len, 1)
                else
                    return $(SRL)(TwicePrecision(start, zero(T)), TwicePrecision(start, -stop), len, 1)
                end
            end
            throw(ArgumentError("should only be called for len < 2, got $len"))
        end
        function $(_frange)(a::T, st::T, ::Nothing, len::Integer) where T<:Union{Float16,Float32,Float64}
            start_n, start_d = Base.rat(a)
            step_n, step_d = Base.rat(st)
            if start_d != 0 && step_d != 0 &&
                    T(start_n/start_d) == a && T(step_n/step_d) == st
                den = lcm(start_d, step_d)
                m = Base.maxintfloat(T, Int)
                if abs(den*a) <= m && abs(den*st) <= m &&
                        rem(den, start_d) == 0 && rem(den, step_d) == 0
                    start_n = round(Int, den*a)
                    step_n = round(Int, den*st)
                    return $(floatfrange)(T, start_n, step_n, len, den)
                end
            end
            return $(stepfrangelen_hp)(T, a, st, 0, len, 1)
        end

        function $(stepfrangelen_hp)(
            ::Type{Float64},
            ref::Tuple{Integer,Integer},
            step::Tuple{Integer,Integer},
            nb::Integer,
            len::Integer,
            offset::Integer
           )
            $(SRL)(TwicePrecision{Float64}(ref), TwicePrecision{Float64}(step, nb), Int(len), offset)
        end

        function $(stepfrangelen_hp)(
            ::Type{T},
            ref::Tuple{Integer,Integer},
            step::Tuple{Integer,Integer},
            nb::Integer,
            len::Integer,
            offset::Integer
           ) where {T<:IEEEFloat}
            return $(SRL){T}(ref[1]/ref[2], step[1]/step[2], Int(len), offset)
        end

        function $(stepfrangelen_hp)(
            ::Type{Float64},
            ref::Base.F_or_FF,
            step::Base.F_or_FF,
            nb::Integer,
            len::Integer,
            offset::Integer
           )
            return $(SRL)(Base.TwicePrecision(ref...), twiceprecision(Base.TwicePrecision(step...), nb), Int(len), offset)
        end

        function $(stepfrangelen_hp)(
            ::Type{T}, ref::Base.F_or_FF,
            step::Base.F_or_FF, nb::Integer,
            len::Integer,
            offset::Integer
           ) where {T<:IEEEFloat}
            return $(SRL){T}(Base.asF64(ref), Base.asF64(step), Int(len), offset)
        end
        function $(floatfrange)(::Type{T}, start_n::Integer, step_n::Integer, len::Integer, den::Integer) where T
            if len < 2 || step_n == 0
                return $(stepfrangelen_hp)(T, (start_n, den), (step_n, den), 0, Int(len), 1)
            end
            # index of smallest-magnitude value
            imin = clamp(round(Int, -start_n/step_n+1), 1, Int(len))
            # Compute smallest-magnitude element to 2x precision
            ref_n = start_n+(imin-1)*step_n  # this shouldn't overflow, so don't check
            nb = nbitslen(T, len, imin)
            return $(stepfrangelen_hp)(T, (ref_n, den), (step_n, den), nb, Int(len), imin)
        end

        function $(floatfrange)(a::AbstractFloat, st::AbstractFloat, len::Real, divisor::AbstractFloat)
            T = promote_type(typeof(a), typeof(st), typeof(divisor))
            m = maxintfloat(T, Int)
            if abs(a) <= m && abs(st) <= m && abs(divisor) <= m
                ia, ist, idivisor = round(Int, a), round(Int, st), round(Int, divisor)
                if ia == a && ist == st && idivisor == divisor
                    # We can return the high-precision range
                    return $(floatfrange)(T, ia, ist, Int(len), idivisor)
                end
            end
            # Fallback (misses the opportunity to set offset different from 1,
            # but otherwise this is still high-precision)
            return $(stepfrangelen_hp)(T, (a,divisor), (st,divisor), Base.nbitslen(T, len, 1), Int(len), 1)
        end
        function $(flinspace)(start::T, stop::T, len::Integer) where {T<:IEEEFloat}
            (isfinite(start) && isfinite(stop)) || throw(ArgumentError("start and stop must be finite, got $start and $stop"))
            # Find the index that returns the smallest-magnitude element
            Δ, Δfac = stop-start, 1
            if !isfinite(Δ)   # handle overflow for large endpoints
                Δ, Δfac = stop/len - start/len, Int(len)
            end
            tmin = -(start/Δ)/Δfac            # t such that (1-t)*start + t*stop == 0
            imin = round(Int, tmin*(len-1)+1) # index approximately corresponding to t
            if 1 < imin < len
                # The smallest-magnitude element is in the interior
                t = (imin-1)/(len-1)
                ref = T((1-t)*start + t*stop)
                step = imin-1 < len-imin ? (ref-start)/(imin-1) : (stop-ref)/(len-imin)
            elseif imin <= 1
                imin = 1
                ref = start
                step = (Δ/(len-1))*Δfac
            else
                imin = Int(len)
                ref = stop
                step = (Δ/(len-1))*Δfac
            end
            if len == 2 && !isfinite(step)
                # For very large endpoints where step overflows, exploit the
                # split-representation to handle the overflow
                return $(stepfrangelen_hp)(T, start, (-start, stop), 0, 2, 1)
            end
            # 2x calculations to get high precision endpoint matching while also
            # preventing overflow in ref_hi+(i-offset)*step_hi
            m, k = prevfloat(floatmax(T)), max(imin-1, len-imin)
            step_hi_pre = clamp(step, max(-(m+ref)/k, (-m+ref)/k), min((m-ref)/k, (m+ref)/k))
            nb = nbitslen(T, len, imin)
            step_hi = truncbits(step_hi_pre, nb)
            x1_hi, x1_lo = add12((1-imin)*step_hi, ref)
            x2_hi, x2_lo = add12((len-imin)*step_hi, ref)
            a, b = (start - x1_hi) - x1_lo, (stop - x2_hi) - x2_lo
            step_lo = (b - a)/(len - 1)
            ref_lo = a - (1 - imin)*step_lo
            return $(stepfrangelen_hp)(T, (ref, ref_lo), (step_hi, step_lo), 0, Int(len), imin)
        end
    end
end

