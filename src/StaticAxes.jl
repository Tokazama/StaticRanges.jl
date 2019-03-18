"""
    StaticAxes

Provides formal axis type for AbsractArrays.

```jldoctest
julia> inds = (srange(2:3), srange(2:3), srange(1:3), srange(1:2), srange(1:2))

```
"""

for (F, Trait) in ((:_first, :B), (:_last, :E), (:_step, :S), (:_size, :L), (:_offset, :F), (:_eltype, :T))
    @eval begin
        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1}}},
            i::Int) where {T1,B1,E1,S1,F1,L1}
            if i == 1
                return $(Symbol(Trait, 1))
            end
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1}}}
           ) where {T1,B1,E1,S1,F1,L1}
            ($(Symbol(Trait, 1)),)
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2}}},
            i::Int) where {T1,B1,E1,S1,L1,F1,
                           T2,B2,E2,S2,L2,F2}
            if i == 1
                return $(Symbol(Trait, 1))
            else i == 2
                return $(Symbol(Trait, 2))
            end
        end
        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2}}}
           ) where {T1,B1,E1,S1,L1,F1,
                    T2,B2,E2,S2,L2,F2}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)))
        end


        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3}
            if i < 3
                if i == 1
                    return $(Symbol(Trait, 1))
                else
                    return $(Symbol(Trait, 2))
                end
            else i == 3
                return $(Symbol(Trait, 3))
            end
        end
        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3}}},
            ) where {T1,B1,E1,S1,F1,L1,
                     T2,B2,E2,S2,F2,L2,
                     T3,B3,E3,S3,F3,L3}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),$(Symbol(Trait, 3)))
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3,
                           T4,B4,E4,S4,F4,L4}
            if i < 3
                if i == 1
                    return $(Symbol(Trait, 1))
                else
                    return $(Symbol(Trait, 2))
                end
            else
                if i == 3
                    return $(Symbol(Trait, 3))
                else
                    return $(Symbol(Trait, 4))
                end
            end
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4}}},
            ) where {T1,B1,E1,S1,F1,L1,
                     T2,B2,E2,S2,F2,L2,
                     T3,B3,E3,S3,F3,L3,
                     T4,B4,E4,S4,F4,L4}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),
             $(Symbol(Trait, 3)),$(Symbol(Trait, 4)))
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4},
                         <:StaticRange{T5,B5,E5,S5,F5,L5}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3,
                           T4,B4,E4,S4,F4,L4,
                           T5,B5,E5,S5,F5,L5}
            if i < 3
                if i == 1
                    return $(Symbol(Trait, 1))
                else
                    return $(Symbol(Trait, 2))
                end
            elseif i < 5
                if i == 3
                    return $(Symbol(Trait, 3))
                else
                    return $(Symbol(Trait, 4))
                end
            else
                return $(Symbol(Trait, 5))
            end
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                        <:StaticRange{T2,B2,E2,S2,F2,L2},
                                        <:StaticRange{T3,B3,E3,S3,F3,L3},
                                        <:StaticRange{T4,B4,E4,S4,F4,L4},
                                        <:StaticRange{T5,B5,E5,S5,F5,L5}}},
            ) where {T1,B1,E1,S1,F1,L1,
                     T2,B2,E2,S2,F2,L2,
                     T3,B3,E3,S3,F3,L3,
                     T4,B4,E4,S4,F4,L4,
                     T5,B5,E5,S5,F5,L5}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),$(Symbol(Trait, 3)),
             $(Symbol(Trait, 4)),$(Symbol(Trait, 5)))
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4},
                         <:StaticRange{T5,B5,E5,S5,F5,L5},
                         <:StaticRange{T5,B5,E5,S5,F5,L5}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3,
                           T4,B4,E4,S4,F4,L4,
                           T5,B5,E5,S5,F5,L5,
                           T6,B6,E6,S6,F6,L6}
            if i < 3
                if i == 1
                    return $(Symbol(Trait, 1))
                else
                    return $(Symbol(Trait, 2))
                end
            elseif i < 5
                if i == 3
                    return $(Symbol(Trait, 3))
                else
                    return $(Symbol(Trait, 4))
                end
            else
                if i == 5
                    return $(Symbol(Trait, 5))
                else
                    return $(Symbol(Trait, 6))
                end
            end
        end

        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4},
                         <:StaticRange{T5,B5,E5,S5,F5,L5},
                         <:StaticRange{T5,B5,E5,S5,F5,L5}}}
            ) where {T1,B1,E1,S1,F1,L1,
                     T2,B2,E2,S2,F2,L2,
                     T3,B3,E3,S3,F3,L3,
                     T4,B4,E4,S4,F4,L4,
                     T5,B5,E5,S5,F5,L5,
                     T6,B6,E6,S6,F6,L6}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),$(Symbol(Trait, 3)),$(Symbol(Trait, 4)),
             $(Symbol(Trait, 5)),$(Symbol(Trait, 6)))
        end


        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4},
                         <:StaticRange{T5,B5,E5,S5,F5,L5},
                         <:StaticRange{T6,B6,E6,S6,F6,L6},
                         <:StaticRange{T7,B7,E7,S7,F7,L7}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3,
                           T4,B4,E4,S4,F4,L4,
                           T5,B5,E5,S5,F5,L5,
                           T6,B6,E6,S6,F6,L6,
                           T7,B7,E7,S7,F7,L7}
            if i < 5
                if i < 3
                    if i == 1
                        return $(Symbol(Trait, 1))
                    else
                        return $(Symbol(Trait, 2))
                    end
                else
                    if i == 3
                        return $(Symbol(Trait, 3))
                    else
                        return $(Symbol(Trait, 4))
                    end
                end
            else
                if i < 7
                    if i == 5
                        return $(Symbol(Trait, 5))
                    else
                        return $(Symbol(Trait, 6))
                    end
                else
                    return $(Symbol(Trait, 7))
                end
            end
        end
        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4},
                         <:StaticRange{T5,B5,E5,S5,F5,L5},
                         <:StaticRange{T6,B6,E6,S6,F6,L6},
                         <:StaticRange{T7,B7,E7,S7,F7,L7}}}
            ) where {T1,B1,E1,S1,F1,L1,
                     T2,B2,E2,S2,F2,L2,
                     T3,B3,E3,S3,F3,L3,
                     T4,B4,E4,S4,F4,L4,
                     T5,B5,E5,S5,F5,L5,
                     T6,B6,E6,S6,F6,L6,
                     T7,B7,E7,S7,F7,L7}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),$(Symbol(Trait, 3)),$(Symbol(Trait, 4)),
             $(Symbol(Trait, 5)),$(Symbol(Trait, 6)),$(Symbol(Trait, 7)))
        end


        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4},
                         <:StaticRange{T5,B5,E5,S5,F5,L5},
                         <:StaticRange{T6,B6,E6,S6,F6,L6},
                         <:StaticRange{T7,B7,E7,S7,F7,L7},
                         <:StaticRange{T8,B8,E8,S8,F8,L8}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3,
                           T4,B4,E4,S4,F4,L4,
                           T5,B5,E5,S5,F5,L5,
                           T6,B6,E6,S6,F6,L6,
                           T7,B7,E7,S7,F7,L7,
                           T8,B8,E8,S8,F8,L8}
            if i < 5
                if i < 3
                    if i == 1
                        return $(Symbol(Trait, 1))
                    else
                        return $(Symbol(Trait, 2))
                    end
                else
                    if i == 3
                        return $(Symbol(Trait, 3))
                    else
                        return $(Symbol(Trait, 4))
                    end
                end
            else
                if i < 7
                    if i == 5
                        return $(Symbol(Trait, 5))
                    else
                        return $(Symbol(Trait, 6))
                    end
                else
                    if i == 7
                        return $(Symbol(Trait, 7))
                    else
                        return $(Symbol(Trait, 8))
                    end
                end
            end

        end
        @pure function $F(
            ::Type{Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                         <:StaticRange{T2,B2,E2,S2,F2,L2},
                         <:StaticRange{T3,B3,E3,S3,F3,L3},
                         <:StaticRange{T4,B4,E4,S4,F4,L4},
                         <:StaticRange{T5,B5,E5,S5,F5,L5},
                         <:StaticRange{T6,B6,E6,S6,F6,L6},
                         <:StaticRange{T7,B7,E7,S7,F7,L7},
                         <:StaticRange{T8,B8,E8,S8,F8,L8}}}
            ) where {T1,B1,E1,S1,F1,L1,
                     T2,B2,E2,S2,F2,L2,
                     T3,B3,E3,S3,F3,L3,
                     T4,B4,E4,S4,F4,L4,
                     T5,B5,E5,S5,F5,L5,
                     T6,B6,E6,S6,F6,L6,
                     T7,B7,E7,S7,F7,L7,
                     T8,B8,E8,S8,F8,L8}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),$(Symbol(Trait, 3)),$(Symbol(Trait, 4)),
             $(Symbol(Trait, 5)),$(Symbol(Trait, 6)),$(Symbol(Trait, 7)),$(Symbol(Trait, 8)))
        end

    end
end
