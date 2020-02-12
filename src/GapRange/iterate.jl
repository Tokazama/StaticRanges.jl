Base.firstindex(gr::GapRange) = firstindex(first_range(gr))

first_lastindex(gr) = lastindex(first_range(gr))

Base.lastindex(gr::GapRange) = length(gr)

last_firstindex(gr::GapRange) = lastindex(first_range(gr)) + 1

Base.iterate(gr::GapRange) = first(gr), 1

function Base.iterate(gr::GapRange, i::Integer)
    fl = first_length(gr)
    if i > fl
        if i >= last_length(gr)
            return nothing
        else
            inext = i + 1
            return unsafe_index_last(gr, inext), inext
        end
    elseif i == fl
        return first(last_range(gr)), i + 1
    else
        inext = i + 1
        return unsafe_index_first(gr, inext), inext
    end
end
