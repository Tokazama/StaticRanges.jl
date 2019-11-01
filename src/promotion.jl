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

lower_rangetype(::Type{<:OneToSRange{T,E}}) where {T,E} = OneTo{T}
lower_rangetype(::Type{OneTo{T}}) where {T} = OneToMRange{T}
lower_rangetype(::Type{OneToMRange{T}}) where {T} = OneToMRange{T}

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

lower_rangetype(::Type{<:UnitSRange{T}}) where {T} = UnitRange{T}
lower_rangetype(::Type{UnitRange{T}}) where {T} = UnitMRange{T}
lower_rangetype(::Type{UnitMRange{T}}) where {T} = UnitMRange{T}

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

lower_rangetype(::Type{<:LinSRange{T}}) where {T} = LinRange{T}
lower_rangetype(::Type{LinRange{T}}) where {T} = LinMRange{T}
lower_rangetype(::Type{LinMRange{T}}) where {T} = LinMRange{T}

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

lower_rangetype(::Type{<:StepSRangeLen{T,R,S}}) where {T,R,S} = StepRangeLen{T,R,S}
lower_rangetype(::Type{StepRangeLen{T,R,S}}) where {T,R,S} = StepMRangeLen{T,R,S}
lower_rangetype(::Type{StepMRangeLen{T,R,S}}) where {T,R,S} = StepMRangeLen{T,R,S}

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

lower_rangetype(::Type{<:StepSRange{T,S}}) where {T,S} = StepRange{T,S}
lower_rangetype(::Type{StepRange{T,S}}) where {T,S} = StepMRange{T,S}
lower_rangetype(::Type{StepMRange{T,S}}) where {T,S} = StepMRange{T,S}

#(:OneToSRange,:UnitSRange,:StepSRange,:LinSRange,:StepSRangeLen)
#(:OneToMRange,:UnitMRange,:StepMRange,:LinMRange,:StepMRangeLen)
#(:OneToRange,:UnitRange,:StepRange,:LinRange,:StepRangeLen)


for S in (:OneToSRange,:UnitSRange,:StepSRange,:LinSRange,:StepSRangeLen)
    for M in (:OneToMRange,:UnitMRange,:StepMRange,:LinMRange,:StepMRangeLen)
        @eval begin
            function Base.promote_rule(a::Type{A}, b::Type{B}) where {A<:$S,B<:$M}
                return promote_rule(lower_rangetype(a), b)
            end

            function Base.promote_rule(b::Type{B}, a::Type{A}) where {A<:$S,B<:$M}
                return promote_rule(lower_rangetype(a), b)
            end
        end
    end
end

# FIXME for some reason this never actually gets called
for S in (:OneToSRange,:UnitSRange,:StepSRange,:LinSRange,:StepSRangeLen)
    for M in (:OneTo,:UnitRange,:StepRange,:LinRange,:StepRangeLen)
        @eval begin
            function Base.promote_rule(a::Type{A}, b::Type{B}) where {A<:$S,B<:$M}
                return promote_rule(lower_rangetype(a), b)
            end

            function Base.promote_rule(b::Type{B}, a::Type{A}) where {A<:$S,B<:$M}
                return promote_rule(lower_rangetype(a), b)
            end
        end
    end
end

for S in (:OneTo,:UnitRange,:StepRange,:LinRange,:StepRangeLen)
    for M in (:OneToMRange,:UnitMRange,:StepMRange,:LinMRange,:StepMRangeLen)
        @eval begin
            function Base.promote_rule(a::Type{A}, b::Type{B}) where {A<:$S,B<:$M}
                return promote_rule(lower_rangetype(a), b)
            end

            function Base.promote_rule(b::Type{B}, a::Type{A}) where {A<:$S,B<:$M}
                return promote_rule(lower_rangetype(a), b)
            end
        end
    end
end

function Base.promote_rule(a::Type{StepRangeLen{T,R,S}}, b::Type{StepMRangeLen{T,R,S}}) where {T,R,S}
    return StepMRangeLen{T,R,S}
end

#const StepRangeLenUnion{T,R,S} = Union{StepRangeLen{T,R,S},StepMRangeLen{T,R,S},<:StepSRangeLen{T,R,S}}

#const StepRangeUnion{T,S} = Union{StepRange{T,S},StepMRange{T,S},<:StepSRange{T,S}}

#const OneToRangeUnion{T} = Union{OneTo{T},OneToMRange{T},<:OneToSRange{T}}

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
Base.promote_rule(b::Type{A}, a::Type{StepRangeLen{T,R,S}}) where {A<:StepSRangeLen,T,R,S} = promote_rule(a, lower_rangetype(b))

#=
function Base.promote_rule(
    a::Type{StepMRangeLen{T,R,S}},
    ::Type{OR}
   ) where {T,R,S,OR<:Union{OneToMRange,UnitMRange,StepMRange,LinMRange}}
    return Base.promote_rule(a, StepMRangeLen{eltype(OR), eltype(OR), eltype(OR)})
end

function Base.promote_rule(
    a::Type{<:StepSRangeLen{T,Tr,Ts,R,S,L,F}},
    ::Type{<:LinSRange{T2,B2,E2,L2,D2}}
   ) where {T,Tr,Ts,R,S,L,F,T2,B2,E2,L2,D2}
    return promote_rule(a, StepSRangeLen{T2, T2, T2})
end

function Base.promote_rule(
    ::Type{<:LinSRange{T2,B2,E2,L2,D2}},
    a::Type{<:StepSRangeLen{T,Tr,Ts,R,S,L,F}}
   ) where {T,Tr,Ts,R,S,L,F,T2,B2,E2,L2,D2}
    return promote_rule(a, StepSRangeLen{T2, T2, T2})
end

function Base.promote_rule(
    ::Type{<:StepSRange{T2,Ts2,B2,S2,E2}},
    a::Type{<:StepSRangeLen{T1,Tr,Ts1,R,S1,L,F}}
   ) where {T1,Tr,Ts1,Ts2,R,S1,L,F,T2,B2,S2,E2}
    return promote_rule(a, StepSRangeLen{T2, T2, T2})
end

function Base.promote_rule(
    a::Type{<:StepSRangeLen{T1,Tr,Ts1,R,S1,L,F}},
    ::Type{<:StepSRange{T2,Ts2,B2,S2,E2}}
   ) where {T1,Tr,Ts1,Ts2,R,S1,L,F,T2,B2,S2,E2}
    return promote_rule(a, StepSRangeLen{T2, T2, T2})
end

function Base.promote_rule(
    ::Type{<:UnitSRange{T2,B,E}},
    a::Type{<:StepSRangeLen{T,Tr,Ts,R,S,L,F}}
   ) where {T,Tr,Ts,R,S,L,F,T2,B,E}
    return promote_rule(a, StepSRangeLen{T2, T2, T2})
end

function Base.promote_rule(
    a::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}},
    ::Type{UnitSRange{T2,B,E}}
   ) where {T,Tr,Ts,R,S,L,F,T2,B,E}
    return promote_rule(a, StepSRangeLen{T2, T2, T2})
end

function Base.promote_rule(
    ::Type{OneToSRange{T2,E}},
    a::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}}
   ) where {T,Tr,Ts,R,S,L,F,T2,E}
    return Base.promote_rule(a, StepSRangeLen{T2, T2, T2})
end
function Base.promote_rule(
    a::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}},
    ::Type{OneToSRange{T2,E}}
   ) where {T,Tr,Ts,R,S,L,F,T2,E}
    return Base.promote_rule(a, StepSRangeLen{T2, T2, T2})
end
=#

###
### AbstractLinRange
###
Base.promote_rule(a::Type{LinMRange{T1}}, b::Type{LinMRange{T2}}) where {T1,T2} = LinMRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{<:LinSRange{T1}}, b::Type{<:LinSRange{T2}}) where {T1,T2} = LinSRange{promote_type(T1,T2)}

#=
function Base.promote_rule(
    b::Type{<:LinRange{T2}},
    a::Type{<:LinSRange{T1,B1,E1,L1,D1}}
   ) where {T1,T2,B1,E1,L1,D1}
    return promote_rule(LinRange{T1}, LinRange{T2})
end

function Base.promote_rule(
    a::Type{<:LinSRange{T1,B1,E1,L1,D1}},
    b::Type{<:LinRange{T2}}
   ) where {T1,T2,B1,E1,L1,D1}
    return promote_rule(LinRange{T1}, LinRange{T2})
end

#Base.promote_rule(a::Type{LinMRange{T}}, ::Type{OR}) where {T,OR<:Union{OneToMRange,UnitMRange,StepMRange}} = promote_rule(a, LinMRange{eltype(OR)})

Base.promote_rule(a::Type{LinMRange{T1}}, ::Type{UnitMRange{T2}}) where {T1,T2} = promote_rule(a, LinMRange{T2})
Base.promote_rule(::Type{UnitMRange{T2}}, a::Type{LinMRange{T1}}) where {T1,T2} = promote_rule(a, LinMRange{T2})

Base.promote_rule(::Type{OneToMRange{T2}}, a::Type{LinMRange{T1}}) where {T1,T2} = promote_rule(a, LinMRange{T2})
Base.promote_rule(a::Type{LinMRange{T1}}, ::Type{OneToMRange{T2}}) where {T1,T2} = promote_rule(a, LinMRange{T2})
#=
function Base.promote_rule(
    ::Type{<:StepSRange{T2,Ts2,B2,S2,E2}},
    a::Type{LinSRange{T1,B1,E1,L,D}}
   ) where {T1,B1,E1,L,D,T2,Ts2,B2,S2,E2}
    return promote_rule(a, LinSRange{T2})
end
=#

Base.promote_rule(a::Type{LinSRange{T1,B1,E1,L,D}}, ::Type{<:UnitSRange{T2,B2,E2}}) where {T1,B1,E1,L,D,T2,B2,E2} = promote_rule(a, LinSRange{T2})
Base.promote_rule(::Type{<:UnitSRange{T2,B2,E2}}, a::Type{LinSRange{T1,B1,E1,L,D}}) where {T1,B1,E1,L,D,T2,B2,E2} = promote_rule(a, LinSRange{T2})

=#

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
Base.promote_rule(::Type{StepMRange{T2,Ts2}}, a::Type{LinMRange{T1}}) where {T1,T2,Ts2} = promote_rule(a, LinMRange{T2})

Base.promote_rule(a::Type{<:LinSRange{T1}}, ::Type{<:StepSRange{T2,Ts2}}) where {T1,T2,Ts2} = promote_rule(a, LinSRange{T2})
Base.promote_rule(::Type{<:StepSRange{T2,Ts2}}, a::Type{<:LinSRange{T1}}) where {T1,T2,Ts2} = promote_rule(a, LinSRange{T2})

#=
function Base.promote_rule(
    ::Type{StepRange{T2a,T2b}},
    ::Type{StepSRange{T1a,T1b,B1,S1,E1}}
   ) where {T1a,T1b,T2a,T2b,B1,S1,E1}
    return promote_rule(StepRange{T1a,T1b}, StepRange{T2a,T2b})
end

function Base.promote_rule(
    ::Type{StepSRange{T1a,T1b,B1,S1,E1}},
    ::Type{StepRange{T2a,T2b}}
   ) where {T1a,T1b,T2a,T2b,B1,S1,E1}
    return promote_rule(StepRange{T1a,T1b}, StepRange{T2a,T2b})
end

function Base.promote_rule(
    a::Type{StepMRange{T1a,T1b}},
    ::Type{UR}
   ) where {T1a,T1b,UR<:AbstractUnitRange}
    return promote_rule(a, StepMRange{eltype(UR), eltype(UR)})
end

=#

#Base.promote_rule(::Type{<:UnitSRange{T2,B2,E2}}, a::Type{<:StepSRange{T1a,T1b,B1,S1,E1}}) where {T1a,T1b,B1,S1,E1,T2,B2,E2} = promote_rule(a, StepSRange{T2,T2})
#Base.promote_rule(a::Type{<:StepSRange{T1a,T1b,B1,S1,E1}}, ::Type{<:UnitSRange{T2,B2,E2}}) where {T1a,T1b,B1,S1,E1,T2,B2,E2} = promote_rule(a, StepSRange{T2,T2})

#Base.promote_rule(a::Type{<:StepMRange{T1a,T1b}}, ::Type{<:OneToMRange{T2}}) where {T1a,T1b,T2} = promote_rule(a, StepMRange{T2,T2})
#Base.promote_rule(::Type{<:UnitMRange{T2}}, a::Type{<:StepMRange{T1a,T1b}}) where {T1a,T1b,T2} = promote_rule(a, StepMRange{T2,T2})

#Base.promote_rule(a::Type{<:StepMRange{T1a,T1b}}, ::Type{<:UnitSRange{T2}}) where {T1a,T1b,T2} = promote_rule(a, StepMRange{T2,T2})
#Base.promote_rule(::Type{<:UnitMRange{T2}}, a::Type{<:StepSRange{T1a,T1b}}) where {T1a,T1b,T2} = promote_rule(a, StepMRange{T2,T2})

###
### UnitRange
###
#Base.promote_rule(a::Type{UnitMRange{T1}}, ::Type{UR}) where {T1,UR<:AbstractUnitRange} = promote_rule(a, UnitMRange{eltype(UR)})

Base.promote_rule(a::Type{UnitMRange{T1}}, b::Type{UnitMRange{T2}}) where {T1,T2} = el_same(promote_type(T1,T2), a, b)
Base.promote_rule(a::Type{<:UnitSRange{T1}}, b::Type{<:UnitSRange{T2}}) where {T1,T2} = el_same(promote_type(T1,T2), a, b)

Base.promote_rule(::Type{LinMRange{T2}}, ::Type{UnitMRange{T1}}) where {T1,T2} = LinMRange{promote_type(T1,T2)}
Base.promote_rule(::Type{UnitMRange{T1}}, ::Type{LinMRange{T2}}) where {T1,T2} = LinMRange{promote_type(T1,T2)}

Base.promote_rule(::Type{<:LinSRange{T2}}, ::Type{<:UnitSRange{T1}}) where {T1,T2} = LinSRange{promote_type(T1,T2)}
Base.promote_rule(::Type{<:UnitSRange{T1}}, ::Type{<:LinSRange{T2}}) where {T1,T2} = LinSRange{promote_type(T1,T2)}

###
### OneToRange
###

Base.promote_rule(a::Type{<:OneToSRange{T1,Any}}, b::Type{<:OneToSRange{T2,Any}}) where {T1,T2} = OneToSRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{OneToMRange{T1}}, b::Type{OneToMRange{T2}}) where {T1,T2} = OneToMRange{promote_type(T1,T2)}
#Base.promote_rule(a::Type{}, 

Base.promote_rule(::Type{OneToMRange{T1}}, ::Type{OneTo{T2}}) where {T1,T2} = promote_rule(OneToMRange{T1},OneToMRange{T2})
Base.promote_rule(::Type{OneTo{T2}}, ::Type{OneToMRange{T1}}) where {T1,T2} = promote_rule(OneToMRange{T1},OneToMRange{T2})

Base.promote_rule(::Type{OneToMRange{T1}}, ::Type{LinMRange{T2}}) where {T1,T2} = promote_rule(LinMRange{T1},LinMRange{T2})
Base.promote_rule(::Type{LinMRange{T1}}, ::Type{OneToMRange{T2}}) where {T1,T2} = promote_rule(LinMRange{T1},LinMRange{T2})

Base.promote_rule(::Type{<:OneToSRange{T1}}, ::Type{<:LinSRange{T2}}) where {T1,T2} = promote_rule(LinSRange{T1},LinSRange{T2})
Base.promote_rule(::Type{<:LinSRange{T1}}, ::Type{<:OneToSRange{T2}}) where {T1,T2} = promote_rule(LinSRange{T1},LinSRange{T2})

#=
Base.promote_rule(::Type{A}, ::Type{B}) where {A<:OneToSRange,B<:OneTo} = promote_rule(OneTo{eltype(A)}, B)
Base.promote_rule(::Type{B}, ::Type{A}) where {A<:OneToSRange,B<:OneTo} = promote_rule(OneTo{eltype(A)}, B)
=#
