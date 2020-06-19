
for R in (OneToSRange,OneToMRange)
    eval(:(Base.similar(r::$R, ::Type{T}) where {T} = $R(T(last(r)))))
end

for R in (UnitMRange,UnitSRange)
    eval(:(Base.similar(r::$R, ::Type{T}) where {T} = $R(T(first(r)), T(last(r)))))
end

for R in (StepMRange,StepSRange)
    eval(:(Base.similar(r::$R, ::Type{T}) where {T} = $R(T(first(r)), T(step(r)), T(last(r)))))
end

for R in (StepMRangeLen,StepSRangeLen)
    @eval begin
        function Base.similar(r::$R, ::Type{T}) where {T}
            return $R(T(r.ref), T(r.step), r.len, r.offset)
        end
    end
end

