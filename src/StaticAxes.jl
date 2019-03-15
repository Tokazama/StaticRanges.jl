struct StaticAxes{N,Ax<:Tuple} end
const StaticAxesUnion{Ax} = Union{StaticAxes{Ax},Type{<:StaticAxes{Ax}}}

for (F, Trait) in ((:first, :B), (:last, :E), (:step, :S), (:size, :L), (:offset, :F))
    @eval begin
        @pure function $F(inds::StaticAxesUnion{1,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1}}}, i::Int) where {T1,B1,E1,S1,F1,L1}
            if i == 1
                return $(Symbol(Trait, 1))
            else
                throw(BoundsError(inds, i))
            end
        end

        @pure $F(inds::StaticAxesUnion{1,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1}}}) where {T1,B1,E1,S1,F1,L1} = ($(Symbol(Trait, 1)),)

        @pure function $F(
            inds::StaticAxesUnion{2,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},<:StaticRange{T2,B2,E2,S2,F2,L2}}},
            i::Int) where {T1,B1,E1,S1,L1,F1,
                           T2,B2,E2,S2,L2,F2}
            if i == 1
                return $(Symbol(Trait, 1))
            elseif i == 2
                return $(Symbol(Trait, 2))
            else
                throw(BoundsError(inds, i))
            end
        end
        @pure function $F(
            inds::StaticAxesUnion{2,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                          <:StaticRange{T2,B2,E2,S2,F2,L2}}}
           ) where {T1,B1,E1,S1,L1,F1,
                    T2,B2,E2,S2,L2,F2}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)))
        end


        @pure function $F(
            inds::StaticAxesUnion{3,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                          <:StaticRange{T2,B2,E2,S2,F2,L2},
                                          <:StaticRange{T3,B3,E3,S3,F3,L3}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3}
            if i == 1
                return $(Symbol(Trait, 1))
            elseif i == 2
                return $(Symbol(Trait, 2))
            elseif i == 3
                return $(Symbol(Trait, 3))
            else
                throw(BoundsError(inds, i))
            end
        end
        @pure function $F(
            inds::StaticAxesUnion{3,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                          <:StaticRange{T2,B2,E2,S2,F2,L2},
                                          <:StaticRange{T3,B3,E3,S3,F3,L3}}},
            ) where {T1,B1,E1,S1,F1,L1,
                     T2,B2,E2,S2,F2,L2,
                     T3,B3,E3,S3,F3,L3}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),$(Symbol(Trait, 3)))
        end

        @pure function $F(
            inds::StaticAxesUnion{4,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                          <:StaticRange{T2,B2,E2,S2,F2,L2},
                                          <:StaticRange{T3,B3,E3,S3,F3,L3},
                                          <:StaticRange{T4,B4,E4,S4,F4,L4}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3,
                           T4,B4,E4,S4,F4,L4}
            if i == 1
                return $(Symbol(Trait, 1))
            elseif i == 2
                return $(Symbol(Trait, 2))
            elseif i == 3
                return $(Symbol(Trait, 3))
            elseif i == 4
                return $(Symbol(Trait, 4))
            else
                throw(BoundsError(inds, i))
            end
        end

        @pure function $F(
            inds::StaticAxesUnion{4,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
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
            inds::StaticAxesUnion{5,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                          <:StaticRange{T2,B2,E2,S2,F2,L2},
                                          <:StaticRange{T3,B3,E3,S3,F3,L3},
                                          <:StaticRange{T4,B4,E4,S4,F4,L4},
                                          <:StaticRange{T5,B5,E5,S5,F5,L5}}},
            i::Int) where {T1,B1,E1,S1,F1,L1,
                           T2,B2,E2,S2,F2,L2,
                           T3,B3,E3,S3,F3,L3,
                           T4,B4,E4,S4,F4,L4,
                           T5,B5,E5,S5,F5,L5}
            if i == 1
                return $(Symbol(Trait, 1))
            elseif i == 2
                return $(Symbol(Trait, 2))
            elseif i == 3
                return $(Symbol(Trait, 3))
            elseif i == 4
                return $(Symbol(Trait, 4))
            elseif i == 5
                return $(Symbol(Trait, 5))
            else
                throw(BoundsError(inds, i))
            end
        end

        @pure function $F(
            inds::StaticAxesUnion{5,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
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
            ::StaticAxesUnion{6,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
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
            if i == 1
                return $(Symbol(Trait, 1))
            elseif i == 2
                return $(Symbol(Trait, 2))
            elseif i == 3
                return $(Symbol(Trait, 3))
            elseif i == 4
                return $(Symbol(Trait, 4))
            elseif i == 5
                return $(Symbol(Trait, 5))
            elseif i == 6
                return $(Symbol(Trait, 6))
            else
                throw(BoundsError(inds, i))
            end
        end

        @pure function $F(
            ::StaticAxesUnion{6,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                      <:StaticRange{T2,B2,E2,S2,F2,L2},
                                      <:StaticRange{T3,B3,E3,S3,F3,L3},
                                      <:StaticRange{T4,B4,E4,S4,F4,L4},
                                      <:StaticRange{T5,B5,E5,S5,F5,L5},
                                      <:StaticRange{T5,B5,E5,S5,F5,L5}}},
            where {T1,B1,E1,S1,F1,L1,
                   T2,B2,E2,S2,F2,L2,
                   T3,B3,E3,S3,F3,L3,
                   T4,B4,E4,S4,F4,L4,
                   T5,B5,E5,S5,F5,L5,
                   T6,B6,E6,S6,F6,L6}
            ($(Symbol(Trait, 1)),$(Symbol(Trait, 2)),$(Symbol(Trait, 3)),$(Symbol(Trait, 4)),
             $(Symbol(Trait, 5)),$(Symbol(Trait, 6)))
        end


        @pure function $F(
            inds::StaticAxesUnion{7,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
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
            if i == 1
                return $(Symbol(Trait, 1))
            elseif i == 2
                return $(Symbol(Trait, 2))
            elseif i == 3
                return $(Symbol(Trait, 3))
            elseif i == 4
                return $(Symbol(Trait, 4))
            elseif i == 5
                return $(Symbol(Trait, 5))
            elseif i == 6
                return $(Symbol(Trait, 6))
            elseif i == 7
                return $(Symbol(Trait, 7))
            else
                throw(BoundsError(inds, i))
            end
        end
        @pure function $F(
            inds::StaticAxesUnion{7,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                          <:StaticRange{T2,B2,E2,S2,F2,L2},
                                          <:StaticRange{T3,B3,E3,S3,F3,L3},
                                          <:StaticRange{T4,B4,E4,S4,F4,L4},
                                          <:StaticRange{T5,B5,E5,S5,F5,L5},
                                          <:StaticRange{T6,B6,E6,S6,F6,L6},
                                          <:StaticRange{T7,B7,E7,S7,F7,L7}}},
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
            inds::StaticAxesUnion{8,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
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
            if i == 1
                return $(Symbol(Trait, 1))
            elseif i == 2
                return $(Symbol(Trait, 2))
            elseif i == 3
                return $(Symbol(Trait, 3))
            elseif i == 4
                return $(Symbol(Trait, 4))
            elseif i == 5
                return $(Symbol(Trait, 5))
            elseif i == 6
                return $(Symbol(Trait, 6))
            elseif i == 7
                return $(Symbol(Trait, 7))
            elseif i == 8
                return $(Symbol(Trait, 8))
            else
                throw(BoundsError(inds, i))
            end
        end
        @pure function $F(
            inds::StaticAxesUnion{8,Tuple{<:StaticRange{T1,B1,E1,S1,F1,L1},
                                          <:StaticRange{T2,B2,E2,S2,F2,L2},
                                          <:StaticRange{T3,B3,E3,S3,F3,L3},
                                          <:StaticRange{T4,B4,E4,S4,F4,L4},
                                          <:StaticRange{T5,B5,E5,S5,F5,L5},
                                          <:StaticRange{T6,B6,E6,S6,F6,L6},
                                          <:StaticRange{T7,B7,E7,S7,F7,L7},
                                          <:StaticRange{T8,B8,E8,S8,F8,L8}}},
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
