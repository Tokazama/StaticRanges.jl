struct NamedSRange{T,names,I<:AbstractRange{T}} <: AbstractRange{T}

    function NamedSRange(names::NTuple{N,Symbol}, index::AbstractRange{T}) where {N,T}
        if N != length(index)
            throw()  # TODO
        end
        new{T,names,typeof(index)}(index)
    end
end
Base.propertynames(::NamedRange{T,names}) where {T,names} = names
@inline Base.getproperty(x::NamedRange, s::Symbol) = __getindex(x, Val(s))
@inline Base.getindex(x::NamedRange, s::Symbol) = __getindex(x, Val(s))

 @inline @generated function __getindex(x::NamedRange{T,names}, ::Val{s}) where {T,names,s}
    idx = findfirst(y -> y==s, names)
    # if idx does not throw error then it must be inbounds b/c it should be check at time
    # of construction
    :((@inbounds x[idx]))
end

 @inline function getindex(x::NamedRange, i::Int) where {T,names,Ax}
    @boundscheck checkbounds(x, i) # TODO: checkbounds for NamedRange
    @inbounds x
end






function getindex()
end


mutable struct NamedFlexRange{T,I}
    I::
end
