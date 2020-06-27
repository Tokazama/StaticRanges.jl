# GapRange
unsafe_index_first(gr::GapRange, i) = @inbounds(getindex(first_range(gr), i))
function unsafe_index_last(gr::GapRange, i)
    return @inbounds(getindex(last_range(gr), i .- first_length(gr)))
end

function Base.getindex(gr::GapRange, i::Integer)
    @boundscheck checkbounds(gr, i)
    return i <= first_length(gr) ? unsafe_index_first(gr, i) : unsafe_index_last(gr, i)
end

@propagate_inbounds function  Base.getindex(x::AbstractArray, gr::GapRange)
    @boundscheck checkbounds(x, gr)
    return vcat(
        @inbounds(getindex(x, first_range(gr))),
        @inbounds(getindex(x, last_range(gr)))
    )
end

@propagate_inbounds function Base.getindex(gr::GapRange, v::AbstractRange)
    @boundscheck checkbounds(gr, v)
    fr = first_range(gr)
    lr = last_range(gr)
    if checkindexhi(fr, minimum(v))
        if checkindexlo(lr, maximum(v))
            return unsafe_spanning_getindex(gr, v)
        else
            # largest value of `v` is not found in last segment so only index first segment
            return unsafe_index_first(gr, v)
        end
    else
        # smallest value of `v` is not found in first segment so only index last segment
        return unsafe_index_last(gr, v)
    end
end

# these get rid of ambiguites from `detect_ambiguities`
@propagate_inbounds function Base.getindex(x::SparseArrays.AbstractSparseArray{Tv,Ti,1}, I::GapRange) where {Tv, Ti}
    return vcat(getindex(x, first_range(gr)), getindex(x, last_range(gr)))
end

@propagate_inbounds function Base.getindex(A::SparseArrays.AbstractSparseMatrixCSC, I::GapRange{Bool})
    return vcat(getindex(x, first_range(gr)), getindex(x, last_range(gr)))
end

@propagate_inbounds function Base.getindex(A::SparseArrays.AbstractSparseMatrixCSC{Tv,Ti}, I::GapRange) where {Tv,Ti}
    return vcat(getindex(x, first_range(gr)), getindex(x, last_range(gr)))
end

function unsafe_spanning_getindex(gr, v)
    ltfli = find_all(<=(first_lastindex(gr)), v)
    gtlfi = find_all(>=(last_firstindex(gr)), v)
    if is_forward(v)
        return _unsafe_gaprange(
            unsafe_index_first(gr, @inbounds(v[ltfli])),
            unsafe_index_last(gr, @inbounds(v[gtlfi]))
           )
    else  # is_reverse(v)
        return _unsafe_gaprange(
            unsafe_index_last(gr, @inbounds(v[gtlfi])),
            unsafe_index_first(gr, @inbounds(v[ltfli]))
           )
    end
end
