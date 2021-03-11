
###
### promot_rule
###

#=

for S in (:OneTo,:UnitRange)
    for M in (:DynamicAxis,:UnitMRange)
        @eval begin
            Base.promote_rule(a::Type{<:$S}, b::Type{<:$M}) = promote_rule(lower_rangetype(a), b)
            Base.promote_rule(b::Type{<:$M}, a::Type{<:$S}) = promote_rule(lower_rangetype(a), b)
        end
    end
end
=#

#= Necessary to avoid ambiguities
for R in (:DynamicAxis,:UnitMRange)
    @eval begin
        Base.promote_rule(a::Type{StepRangeLen{T,R,S}}, b::Type{<:$R}) where {T,R,S} = promote_rule(lower_rangetype(a), b)
        Base.promote_rule(a::Type{<:$R}, b::Type{StepRangeLen{T,R,S}}) where {T,R,S} = promote_rule(a, lower_rangetype(b))
    end
end

for R in (:DynamicAxis,:UnitMRange)
    @eval begin
        Base.promote_rule(a::Type{StepRange{T,S}}, b::Type{<:$R}) where {T,S} = promote_rule(lower_rangetype(a), b)
        Base.promote_rule(a::Type{<:$R}, b::Type{StepRange{T,S}}) where {T,S} = promote_rule(a, lower_rangetype(b))
    end
end
for R in (:DynamicAxis,:UnitMRange)
    @eval begin
        Base.promote_rule(a::Type{LinRange{T}}, b::Type{<:$R}) where {T} = promote_rule(lower_rangetype(a), b)
        Base.promote_rule(a::Type{<:$R}, b::Type{LinRange{T}}) where {T} = promote_rule(a, lower_rangetype(b))
    end
end


=#

###
### OneToRange
###

#= TODO: needs to be in base
Base.promote_rule(a::Type{<:OneTo}, b::Type{<:UnitRange}) = UnitRange{promote_type(eltype(a), eltype(b))}
Base.promote_rule(a::Type{<:UnitRange}, b::Type{<:OneTo}) = UnitRange{promote_type(eltype(a), eltype(b))}
=#

