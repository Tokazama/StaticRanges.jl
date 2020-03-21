Base.firstindex(gr::GapRange) = firstindex(first_range(gr))

first_lastindex(gr) = lastindex(first_range(gr))

Base.lastindex(gr::GapRange) = length(gr)

last_firstindex(gr::GapRange) = lastindex(first_range(gr)) + 1

