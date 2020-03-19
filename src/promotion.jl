
similar_range(::X, ::Y) where {X,Y} = similar_range(X, Y)

similar_range(::Type{<:SRange}, ::Type{<:SRange}) = srange

similar_range(::Type{<:SRange}, ::Type{<:FRange}) = range
similar_range(::Type{<:FRange}, ::Type{<:SRange}) = range
similar_range(::Type{<:FRange}, ::Type{<:FRange}) = range

similar_range(::Type{<:MRange}, ::Type{<:FRange}) = mrange
similar_range(::Type{<:FRange}, ::Type{<:MRange}) = mrange
similar_range(::Type{<:SRange}, ::Type{<:MRange}) = mrange
similar_range(::Type{<:MRange}, ::Type{<:SRange}) = mrange
similar_range(::Type{<:MRange}, ::Type{<:MRange}) = mrange

###
### similar_type
###
for RANGE_TYPE in (:OneTo,:OneToMRange,:OneToSRange)
    @eval begin
        function StaticArrays.similar_type(
            ::$(RANGE_TYPE){T},
            element_type=T,
           ) where {T}
            return $(RANGE_TYPE){element_type}
        end
    end
end

for RANGE_TYPE in (:UnitRange,:UnitMRange,:UnitSRange)
    @eval begin
        function StaticArrays.similar_type(
            ::$(RANGE_TYPE){T},
            element_type=T,
           ) where {T}
            return $(RANGE_TYPE){element_type}
        end
    end
end

for RANGE_TYPE in (:LinRange,:LinMRange,:LinSRange)
    @eval begin
        function StaticArrays.similar_type(
            ::$(RANGE_TYPE){T},
            element_type=T,
           ) where {T}
            return $(RANGE_TYPE){element_type}
        end
    end
end

for RANGE_TYPE in (:StepRangeLen,:StepMRangeLen,:StepSRangeLen)
    @eval begin
        function StaticArrays.similar_type(
            ::$(RANGE_TYPE){T,R,S},
            element_type=T,
            reference_type=R,
            step_type=S
           ) where {T,R,S}
            return $(RANGE_TYPE){element_type,reference_type,step_type}
        end
    end
end

for RANGE_TYPE in (:StepRange,:StepMRange,:StepSRange)
    @eval begin
        function StaticArrays.similar_type(
            ::$(RANGE_TYPE){T,S},
            element_type=T,
            step_type=S
           ) where {T,R,S}
            return $(RANGE_TYPE){element_type,step_type}
        end
    end
end

###
### lower_rangetype
###

lower_rangetype(::Type{<:OneToSRange{T,E}}) where {T,E} = OneTo{T}
lower_rangetype(::Type{OneTo{T}}) where {T} = OneToMRange{T}
lower_rangetype(::Type{OneToMRange{T}}) where {T} = OneToMRange{T}

lower_rangetype(::Type{<:UnitSRange{T}}) where {T} = UnitRange{T}
lower_rangetype(::Type{UnitRange{T}}) where {T} = UnitMRange{T}
lower_rangetype(::Type{UnitMRange{T}}) where {T} = UnitMRange{T}

lower_rangetype(::Type{<:LinSRange{T}}) where {T} = LinRange{T}
lower_rangetype(::Type{LinRange{T}}) where {T} = LinMRange{T}
lower_rangetype(::Type{LinMRange{T}}) where {T} = LinMRange{T}

lower_rangetype(::Type{<:StepSRangeLen{T,R,S}}) where {T,R,S} = StepRangeLen{T,R,S}
lower_rangetype(::Type{StepRangeLen{T,R,S}}) where {T,R,S} = StepMRangeLen{T,R,S}
lower_rangetype(::Type{StepMRangeLen{T,R,S}}) where {T,R,S} = StepMRangeLen{T,R,S}

lower_rangetype(::Type{<:StepSRange{T,S}}) where {T,S} = StepRange{T,S}
lower_rangetype(::Type{StepRange{T,S}}) where {T,S} = StepMRange{T,S}
lower_rangetype(::Type{StepMRange{T,S}}) where {T,S} = StepMRange{T,S}


###
### promot_rule
###

#Base.promote_rule(::X, ::Y) where {X<:SRange,Y<:SRange} = promote_rule(X, Y)

for S in (:OneToSRange,:UnitSRange,:StepSRange,:LinSRange,:StepSRangeLen)
    for M in (:OneToMRange,:UnitMRange,:StepMRange,:LinMRange,:StepMRangeLen)
        @eval begin
            Base.promote_rule(a::Type{<:$S}, b::Type{<:$M}) = promote_rule(lower_rangetype(a), b)
            Base.promote_rule(b::Type{<:$M}, a::Type{<:$S}) = promote_rule(lower_rangetype(a), b)
        end
    end
end

for S in (:OneToSRange,:UnitSRange,:StepSRange,:LinSRange,:StepSRangeLen)
    for M in (:OneTo,:UnitRange,:StepRange,:LinRange,:StepRangeLen)
        @eval begin
            Base.promote_rule(a::Type{<:$S}, b::Type{<:$M}) = promote_rule(lower_rangetype(a), b)
            Base.promote_rule(b::Type{<:$M}, a::Type{<:$S}) = promote_rule(lower_rangetype(a), b)
        end
    end
end

for S in (:OneTo,:UnitRange,:StepRange,:LinRange,:StepRangeLen)
    for M in (:OneToMRange,:UnitMRange,:StepMRange,:LinMRange,:StepMRangeLen)
        @eval begin
            Base.promote_rule(a::Type{<:$S}, b::Type{<:$M}) = promote_rule(lower_rangetype(a), b)
            Base.promote_rule(b::Type{<:$M}, a::Type{<:$S}) = promote_rule(lower_rangetype(a), b)
        end
    end
end

# Necessary to avoid ambiguities
Base.promote_rule(a::Type{StepRangeLen{T,R,S}}, b::Type{<:StepMRangeLen}) where {T,R,S} = promote_rule(lower_rangetype(a), b)

function Base.promote_rule(a::Type{StepRangeLen{T,R,S}}, b::Type{StepMRangeLen{T,R,S}}) where {T,R,S}
    return StepMRangeLen{T,R,S}
end

###
### AbstractStepRangeLen
###
function Base.promote_rule(
    ::Type{StepMRangeLen{T1,R1,S1}},
    ::Type{StepMRangeLen{T2,R2,S2}}
   ) where {T1,T2,R1,R2,S1,S2}
    return el_same(
        promote_type(T1,T2),
        StepMRangeLen{T1,promote_type(R1,R2),promote_type(S1,S2)},
        StepMRangeLen{T2,promote_type(R1,R2),promote_type(S1,S2)}
       )
end

function Base.promote_rule(
    ::Type{<:StepSRangeLen{T1,Tr1,Ts1}},
    ::Type{<:StepSRangeLen{T2,Tr2,Ts2}},
   ) where {T1,T2,Tr1,Tr2,Ts1,Ts2,R1,R2,S1,S2,L1,L2,F1,F2}
    return el_same(
        promote_type(T1,T2),
        StepSRangeLen{T1,promote_type(Tr1,Tr2),promote_type(Ts1,Ts2)},
        StepSRangeLen{T2,promote_type(Tr1,Tr2),promote_type(Ts1,Ts2)}
       )
end

# has to be included to avoid ambiguities
Base.promote_rule(a::Type{StepRangeLen{T,R,S}}, b::Type{A}) where {A<:StepSRangeLen,T,R,S} = promote_rule(a, lower_rangetype(b))

Base.promote_rule(a::Type{StepMRangeLen{T1,R,S}}, ::Type{LinMRange{T2}}) where {T1,R,S,T2} = promote_rule(a, StepMRangeLen{T2,T2,T2})

Base.promote_rule(a::Type{<:StepSRangeLen{T1,R,S}}, ::Type{<:LinSRange{T2}}) where {T1,R,S,T2} = promote_rule(StepSRangeLen{T2,T2,T2}, a)

###
### AbstractLinRange
###
Base.promote_rule(a::Type{LinMRange{T1}}, b::Type{LinMRange{T2}}) where {T1,T2} = LinMRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{<:LinSRange{T1}}, b::Type{<:LinSRange{T2}}) where {T1,T2} = LinSRange{promote_type(T1,T2)}

###
### AbstractStepRange
###
function Base.promote_rule(
    ::Type{StepMRange{T1a,T1b}},
    ::Type{StepMRange{T2a,T2b}}
   ) where {T1a,T1b,T2a,T2b}
    return Base.el_same(
        promote_type(T1a,T2a),
        # el_same only operates on array element type, so just promote
        # second type parameter
        StepMRange{T1a, promote_type(T1b,T2b)},
        StepMRange{T2a, promote_type(T1b,T2b)}
       )
end

function Base.promote_rule(
    ::Type{<:StepSRange{T1a,T1b}},
    ::Type{<:StepSRange{T2a,T2b}}
   ) where {T1a,T1b,T2a,T2b}
    return Base.el_same(
        promote_type(T1a,T2a),
        # el_same only operates on array element type, so just promote
        # second type parameter
        StepSRange{T1a, promote_type(T1b,T2b)},
        StepSRange{T2a, promote_type(T1b,T2b)}
       )
end

Base.promote_rule(a::Type{LinMRange{T1}}, ::Type{StepMRange{T2,Ts2}}) where {T1,T2,Ts2} = promote_rule(a, LinMRange{T2})

Base.promote_rule(a::Type{StepMRangeLen{T1,R,S1}}, ::Type{StepMRange{T2,S2}}) where {T1,T2,R,S1,S2} = promote_rule(a, StepMRangeLen{T2,T2,T2})
Base.promote_rule(a::Type{<:StepSRangeLen{T1,R,S1}}, ::Type{<:StepSRange{T2,S2}}) where {T1,T2,R,S1,S2} = promote_rule(a, StepMRangeLen{T2,T2,T2})
Base.promote_rule(a::Type{<:LinSRange{T1}}, ::Type{<:StepSRange{T2,Ts2}}) where {T1,T2,Ts2} = promote_rule(a, LinSRange{T2})

###
### UnitRange
###

Base.promote_rule(a::Type{UnitMRange{T1}}, b::Type{UnitMRange{T2}}) where {T1,T2} = el_same(promote_type(T1,T2), a, b)
function Base.promote_rule(a::Type{<:UnitSRange{T1}}, b::Type{<:UnitSRange{T2}}) where {T1,T2}
    return UnitSRange{promote_type(T1,T2)}
end

Base.promote_rule(::Type{LinMRange{T2}}, ::Type{UnitMRange{T1}}) where {T1,T2} = LinMRange{promote_type(T1,T2)}
Base.promote_rule(::Type{UnitMRange{T1}}, ::Type{LinMRange{T2}}) where {T1,T2} = LinMRange{promote_type(T1,T2)}

Base.promote_rule(::Type{StepMRange{T1,S1}}, ::Type{UnitMRange{T2}}) where {T1,S1,T2} = promote_rule(StepMRange{T1,S1}, StepMRange{T2,T2})
Base.promote_rule(::Type{<:StepSRange{T1,S1}}, ::Type{<:UnitSRange{T2}}) where {T1,S1,T2} = promote_rule(StepSRange{T1,S1}, StepSRange{T2,T2})

Base.promote_rule(::Type{<:LinSRange{T2}}, ::Type{<:UnitSRange{T1}}) where {T1,T2} = LinSRange{promote_type(T1,T2)}
Base.promote_rule(::Type{<:UnitSRange{T1}}, ::Type{<:LinSRange{T2}}) where {T1,T2} = LinSRange{promote_type(T1,T2)}

###
### OneToRange
###

Base.promote_rule(a::Type{LinRange{T}}, ::Type{OR}) where {T,OR<:OneToMRange} = promote_rule(LinMRange{T},LinMRange{eltype(OR)})
Base.promote_rule(a::Type{<:OneToSRange{T1,Any}}, b::Type{<:OneToSRange{T2,Any}}) where {T1,T2} = OneToSRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{OneToMRange{T1}}, b::Type{OneToMRange{T2}}) where {T1,T2} = OneToMRange{promote_type(T1,T2)}

Base.promote_rule(a::Type{<:UnitSRange{T1}}, b::Type{<:OneToSRange{T2}}) where {T1,T2} = UnitSRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{UnitMRange{T1}}, b::Type{OneToMRange{T2}}) where {T1,T2} = UnitMRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{OneToMRange{T1}}, b::Type{UnitMRange{T2}}) where {T1,T2} = UnitMRange{promote_type(T1,T2)}

Base.promote_rule(::Type{OneToMRange{T1}}, ::Type{OneTo{T2}}) where {T1,T2} = promote_rule(OneToMRange{T1},OneToMRange{T2})
Base.promote_rule(::Type{OneTo{T2}}, ::Type{OneToMRange{T1}}) where {T1,T2} = promote_rule(OneToMRange{T1},OneToMRange{T2})

Base.promote_rule(::Type{OneToMRange{T1}}, ::Type{LinMRange{T2}}) where {T1,T2} = promote_rule(LinMRange{T1},LinMRange{T2})
Base.promote_rule(::Type{LinMRange{T1}}, ::Type{OneToMRange{T2}}) where {T1,T2} = promote_rule(LinMRange{T1},LinMRange{T2})

Base.promote_rule(::Type{<:OneToSRange{T1}}, ::Type{<:LinSRange{T2}}) where {T1,T2} = promote_rule(LinSRange{T1},LinSRange{T2})
Base.promote_rule(::Type{<:LinSRange{T1}}, ::Type{<:OneToSRange{T2}}) where {T1,T2} = promote_rule(LinSRange{T1},LinSRange{T2})

# TODO: needs to be in base
Base.promote_rule(a::Type{<:OneTo}, b::Type{<:UnitRange}) = UnitRange{promote_type(eltype(a), eltype(b))}
Base.promote_rule(a::Type{<:UnitRange}, b::Type{<:OneTo}) = UnitRange{promote_type(eltype(a), eltype(b))}

# fixes ambiguity
function Base.promote_rule(a::Type{StepRangeLen{T,R,S}}, ::Type{OR}) where {T,R,S,OR<:OneToMRange}
    return StepMRangeLen{promote_type(T, eltype(OR)),promote_type(R, eltype(OR)),promote_type(S, eltype(OR))}
end

# helps with static types that can't be easily inferred as same parametrically
same_type(::X, ::Y) where {X,Y} =  same_type(X, Y)
same_type(::Type{X}, ::Type{Y}) where {X<:OneToSRange,Y<:OneToSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:UnitSRange,Y<:UnitSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:StepSRange,Y<:StepSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:LinSRange,Y<:LinSRange} = true
same_type(::Type{X}, ::Type{Y}) where {X<:StepSRangeLen,Y<:StepSRangeLen} = true
same_type(::Type{X}, ::Type{X}) where {X} = true
same_type(::Type{X}, ::Type{Y}) where {X,Y} = false

