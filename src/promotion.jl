
similar_range(::X, ::Y) where {X,Y} = similar_range(X, Y)


similar_range(::Type{<:FRange}, ::Type{<:FRange}) = range

similar_range(::Type{<:MRange}, ::Type{<:FRange}) = mrange
similar_range(::Type{<:FRange}, ::Type{<:MRange}) = mrange
similar_range(::Type{<:MRange}, ::Type{<:MRange}) = mrange



###
### similar_type
###
similar_type(::R, args...) where {R<:AbstractArray} = similar_type(R, args...)
similar_type(::Type{OneTo{T}}, element_type=T) where {T} = OneTo{element_type}
similar_type(::Type{OneToMRange{T}}, element_type=T) where {T} = OneToMRange{element_type}

###
### lower_rangetype
###

lower_rangetype(::Type{OneTo{T}}) where {T} = OneToMRange{T}
lower_rangetype(::Type{OneToMRange{T}}) where {T} = OneToMRange{T}


###
### promot_rule
###


for S in (:OneTo,:UnitRange)
    for M in (:OneToMRange,:UnitMRange)
        @eval begin
            Base.promote_rule(a::Type{<:$S}, b::Type{<:$M}) = promote_rule(lower_rangetype(a), b)
            Base.promote_rule(b::Type{<:$M}, a::Type{<:$S}) = promote_rule(lower_rangetype(a), b)
        end
    end
end

# Necessary to avoid ambiguities
for R in (:OneToMRange,:UnitMRange)
    @eval begin
        Base.promote_rule(a::Type{StepRangeLen{T,R,S}}, b::Type{<:$R}) where {T,R,S} = promote_rule(lower_rangetype(a), b)
        Base.promote_rule(a::Type{<:$R}, b::Type{StepRangeLen{T,R,S}}) where {T,R,S} = promote_rule(a, lower_rangetype(b))
    end
end

for R in (:OneToMRange,:UnitMRange)
    @eval begin
        Base.promote_rule(a::Type{StepRange{T,S}}, b::Type{<:$R}) where {T,S} = promote_rule(lower_rangetype(a), b)
        Base.promote_rule(a::Type{<:$R}, b::Type{StepRange{T,S}}) where {T,S} = promote_rule(a, lower_rangetype(b))
    end
end
for R in (:OneToMRange,:UnitMRange)
    @eval begin
        Base.promote_rule(a::Type{LinRange{T}}, b::Type{<:$R}) where {T} = promote_rule(lower_rangetype(a), b)
        Base.promote_rule(a::Type{<:$R}, b::Type{LinRange{T}}) where {T} = promote_rule(a, lower_rangetype(b))
    end
end

###
### UnitRange
###

Base.promote_rule(a::Type{UnitMRange{T1}}, b::Type{UnitMRange{T2}}) where {T1,T2} = el_same(promote_type(T1,T2), a, b)


###
### OneToRange
###

Base.promote_rule(a::Type{OneToMRange{T1}}, b::Type{OneToMRange{T2}}) where {T1,T2} = OneToMRange{promote_type(T1,T2)}

Base.promote_rule(a::Type{UnitMRange{T1}}, b::Type{OneToMRange{T2}}) where {T1,T2} = UnitMRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{OneToMRange{T1}}, b::Type{UnitMRange{T2}}) where {T1,T2} = UnitMRange{promote_type(T1,T2)}

Base.promote_rule(::Type{OneToMRange{T1}}, ::Type{OneTo{T2}}) where {T1,T2} = promote_rule(OneToMRange{T1},OneToMRange{T2})
Base.promote_rule(::Type{OneTo{T2}}, ::Type{OneToMRange{T1}}) where {T1,T2} = promote_rule(OneToMRange{T1},OneToMRange{T2})

# TODO: needs to be in base
Base.promote_rule(a::Type{<:OneTo}, b::Type{<:UnitRange}) = UnitRange{promote_type(eltype(a), eltype(b))}
Base.promote_rule(a::Type{<:UnitRange}, b::Type{<:OneTo}) = UnitRange{promote_type(eltype(a), eltype(b))}

