
Base.show(io::IO, r::OneToSRange) = print(io, "OneToSRange($(last(r)))")

Base.show(io::IO, r::OneToMRange) = print(io, "OneToMRange($(last(r)))")

function Base.show(io::IO, r::StepMRangeLen)
    print(io, "StepMRangeLen(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepSRangeLen)
    print(io, "StepSRangeLen(", first(r), ":", step(r), ":", last(r), ")")
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
    if can_change_size(r)
        print(io, "LinMRange(")
    else
        print(io, "LinSRange(")
    end
    show(io, first(r))
    print(io, ", stop=")
    show(io, last(r))
    print(io, ", length=")
    show(io, length(r))
    print(io, ')')
end

