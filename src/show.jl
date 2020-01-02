Base.show(io::IO, r::OneToRange) = print(io, typeof(r).name, "(", last(r), ")")

function Base.show(io::IO, r::AbstractStepRangeLen)
    print(io, typeof(r).name, "(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepMRange)
    print(io, "StepMRange(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepSRange)
    print(io, "StepSRange(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::UnitSRange)
    print(io, "UnitSRange(", repr(first(r)), ':', repr(last(r)), ")")
end

function Base.show(io::IO, r::UnitMRange)
    print(io, "UnitMRange(", repr(first(r)), ':', repr(last(r)), ")")
end

function Base.show(io::IO, r::AbstractLinRange)
    if is_static(r)
        print(io, "LinSRange(")
    else
        print(io, "LinMRange(")
    end
    show(io, first(r))
    print(io, ", stop=")
    show(io, last(r))
    print(io, ", length=")
    show(io, length(r))
    print(io, ')')
end

function Base.show(io::IO, a::A) where {A<:AbstractAxis}
    if isnothing(dimnames(a))
        print(io, "$(Symbol(A))($(keys(a)) => $(values(a)))")
    else
        print(io, "$(Symbol(A)){$(dimnames(a))}($(keys(a)) => $(values(a)))")
    end
end

function Base.show(io::IO, a::SimpleAxis)
    if isnothing(dimnames(a))
        print(io, "SimpleAxis($(keys(a)))")
    else
        print(io, "SimpleAxis{$(dimnames(a))}($(keys(a)))")
    end
end
