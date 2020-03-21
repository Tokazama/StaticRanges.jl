# Notes on implementation:
# Currently Base Julia reutrns an empty vector on empty(::AbstractRange)
# We want the appropriate variant of the range that returns true when isempty(::AbstractRange)
# We index by OneToSRange(0) in order to force this.
# Using the static version also ensures that it doesn't accidently "promote down" the type


# FIXME specify Bit operator filters here to <,<=,>=,>,==,isequal,isless
# Currently will return incorrect order or repeated results otherwise
@propagate_inbounds function Base.filter(f::Function, r::UnionRange)
    if isempty(r)
        return r[OneToSRange(0)]
    else
        return @inbounds(r[find_all(f, r)])
    end
end

@propagate_inbounds Base.filter(f::ChainedFix, r::UnionRange) = r[findall(f, r)]


