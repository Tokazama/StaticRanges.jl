# ensure that sub range is integer (indexing) rane
#function show_mimic_range(io::IO, ::SubRange{Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T}) where {Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T}
#    showmimicrange(io, SRange{Bp,Ep,Sp,Lp,T}())
#    print(io, "[")
#    showmimicrange(io, SRange{Bi,Ei,Si,Li,Int}())
#    print(io, "]")
#end
#
#Base.show(io::IO, r::SubRange) = showrange(io, r)
#Base.show(io::IO, ::MIME"text/plain", r::SubRange) = showrange(io, r)
#
#function showrange(io::IO,
#    ::WindowRange{SubRange{Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T},SRange{Bs,Es,Ss,Ls,Int}}) where {Bi,Ei,Si,Li,Bp,Ep,Sp,Lp,T,Bs,Es,Ss,Ls}
#    print(io, "$T  WindowRange\n  ")
#
#    showmimicrange(io, SRange{Bp,Ep,Sp,Lp,T}())
#    print(io, "[")
#    showmimicrange(io, SRange{Bi,Ei,Si,Li,Int}())
#    print(io, "]")
#    print(io, " .+ $(Bs):$(Ss):$(Es)")
#end
#Base.show(io::IO, r::WindowRange) = showrange(io, r)
#Base.show(io::IO, ::MIME"text/plain", r::WindowRange) = showrange(io, r)

#
#
#function showsindices(io::IO, inds::StaticAxes{Ax,S,T,N,L}) where {Ax,S,T,N,L}
#    print(io, "$(join(size(inds), "x"))  $(typeof(inds).name){$N}")
#    showaxes(io, inds)
#end
#
#function showaxes(io::IO, inds::SubIndices{I,P,S,T,N,L}) where {I,P,S,T,N,L}
#    for i in OneToSRange(N)
#        print(io, "\n  ", fieldtype(I, i)())
#    end
#end
#
#function showaxes(io::IO, inds::StaticAxes{Ax,S,T,N,L}) where {Ax,S,T,N,L}
#    for i in OneToSRange(N)
#        print(io, "\n ", axes(inds, i))
#    end
#end
#
#
#Base.show(io::IO, inds::StaticAxes) = showsindices(io, inds)
#Base.show(io::IO, ::MIME"text/plain", inds::StaticAxes) = showsindices(io, inds)


@pure function _fieldtype(t::Type{Tuple{T1}}, i::Int) where {T1}
    if i == 1
        return T1
    else
        throw(BoundsError(t, i))
    end
end

@inline @pure function _fieldtype(t::Type{Tuple{T1,T2}}, i::Int) where {T1,T2}
    if i == 1
        return T1
    elseif i == 2
        return T2
    else
        throw(BoundsError(t, i))
    end
end

@inline @pure function _fieldtype(t::Type{Tuple{T1,T2,T3}}, i::Int) where {T1,T2,T3}
    if i < 3
        if i == 1
            return T1
        elseif i == 2
            return T2
        else
            throw(BoundsError(t, i))
        end
    else
        if i == 3
            return T3
        else
            throw(BoundsError(t, i))
        end
    end
end

@inline @pure function _fieldtype(t::Type{Tuple{T1,T2,T3,T4}}, i::Int) where {T1,T2,T3,T4}
    if i < 3
        if i == 1
            return T1
        else i == 2
            return T2
        end
    else i < 5
        if i == 3
            return T3
        else
            return T4
        end
    end
end

@pure function _fieldtype(t::Type{Tuple{T1,T2,T3,T4,T5}}, i::Int) where {T1,T2,T3,T4,T5}
    if i < 5
        if i < 3
            if i == 1
                return T1
            elseif i == 2
                return T2
            end
        else
            if i == 3
                return T3
            else
                return T4
            end
        end
    else
        return T5
    end
end

@pure function _fieldtype(t::Type{Tuple{T1,T2,T3,T4,T5,T6}}, i::Int) where {T1,T2,T3,T4,T5,T6}
    if i < 5
        if i < 3
            if i == 1
                return T1
            else i == 2
                return T2
            end
        else
            if i == 3
                return T3
            else
                return T4
            end
        end
    else
        if i == 5
            return T5
        else
            return T6
        end
    end
end

@pure function _fieldtype(t::Type{Tuple{T1,T2,T3,T4,T5,T6,T7}}, i::Int) where {T1,T2,T3,T4,T5,T6,T7}
    if i < 5
        if i < 3
            if i == 1
                return T1
            else i == 2
                return T2
            end
        else
            if i == 3
                return T3
            else
                return T4
            end
        end
    else
        if i < 7
            if i == 5
                return T5
            else
                return T6
            end
        else
            return T7
        end
    end
end

@pure function _fieldtype(t::Type{Tuple{T1,T2,T3,T4,T5,T6,T7,T8}}, i::Int) where {T1,T2,T3,T4,T5,T6,T7,T8}
    if i < 5
        if i < 3
            if i == 1
                return T1
            else i == 2
                return T2
            end
        else
            if i == 3
                return T3
            else
                return T4
            end
        end
    else
        if i < 7
            if i == 5
                return T5
            else
                return T6
            end
        else
            if i == 7
                return T7
            else i == 8
                return T8
            end
        end
    end
end

@pure function _fieldtype(t::Type{Tuple{T1,T2,T3,T4,T5,T6,T7,T8,T9}}, i::Int) where {T1,T2,T3,T4,T5,T6,T7,T8,T9}
    if i < 9
        if i < 5
            if i < 3
                if i == 1
                    return T1
                elseif i == 2
                    return T2
                else
                    throw(BoundsError(t, i))
                end
            else
                if i == 3
                    return T3
                else
                    return T4
                end
            end
        else
            if i < 7
                if i == 5
                    return T5
                else
                    return T6
                end
            else
                if i == 7
                    return T7
                elseif i == 8
                    return T8
                end
            end
        end
    else
        if i == 9
            return T9
        else
            throw(BoundsError(t, i))
        end
    end
end

@pure function _fieldtype(
    t::Type{Tuple{T1,T2,T3,T4,T5,T6,T7,T8,T9,T10}},
    i::Int) where {T1,T2,T3,T4,T5,T6,T7,T8,T9,T10}
    if i < 9
        if i < 5
            if i < 3
                if i == 1
                    return T1
                elseif i == 2
                    return T2
                else
                    throw(BoundsError(t, i))
                end
            else
                if i == 3
                    return T3
                else
                    return T4
                end
            end
        else
            if i < 7
                if i == 5
                    return T5
                else
                    return T6
                end
            else
                if i == 7
                    return T7
                elseif i == 8
                    return T8
                end
            end
        end
    else
        if i < 11
            if i == 9
                return T9
            else
                return T10
            end
        else
            throw(BoundsError(t, i))
        end
    end
end
