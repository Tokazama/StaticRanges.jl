
include("type.jl")

# GapRange
unsafe_index_first(gr::GapRange, i) = @inbounds(getindex(first_range(gr), i))
function unsafe_index_last(gr::GapRange, i)
    return @inbounds(getindex(last_range(gr), i .- first_length(gr)))
end

function Base.getindex(gr::GapRange, i::Integer)
    @boundscheck checkbounds(gr, i)
    return i <= first_length(gr) ? unsafe_index_first(gr, i) : unsafe_index_last(gr, i)
end

@propagate_inbounds function Base.getindex(r::AbstractRange, gr::GapRange)
    fr = r[gr.first_range]
    lr = r[gr.last_range]
    return GapRange{eltype(r),typeof(fr),typeof(lr)}(fr, lr)
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

Base.checkbounds(::Type{Bool}, gr::GapRange, i::Integer) = checkindex(Bool, gr, i)

function Base.checkindex(::Type{Bool}, gr::GapRange, i::Integer)
    return checkindexlo(gr, i) & checkindexhi(gr, i)
end

