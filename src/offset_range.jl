
function __init__()
    @require OffsetArrays="6fe1bfb0-de20-5000-8ca7-80f57d26f881" begin
        is_static(::Type{OffsetArrays.IdOffsetRange{T,P}}) where {T,P} = is_static(P)
        is_dynamic(::Type{OffsetArrays.IdOffsetRange{T,P}}) where {T,P} = is_dynamic(P)
        is_fixed(::Type{OffsetArrays.IdOffsetRange{T,P}}) where {T,P} = is_fixed(P)

        as_dynamic(x::OffsetArrays.IdOffsetRange) = OffsetArrays.IdOffsetRange(as_dynamic(parent(x)), x.offset)
        as_fixed(x::OffsetArrays.IdOffsetRange) = OffsetArrays.IdOffsetRange(as_fixed(parent(x)), x.offset)
        as_static(x::OffsetArrays.IdOffsetRange) = OffsetArrays.IdOffsetRange(as_static(parent(x)), x.offset)

        can_set_first(::Type{<:OffsetArrays.IdOffsetRange{T,P}}) where {T,P} = can_set_first(P)
        function set_first(r::OffsetArrays.IdOffsetRange{T}, val::T) where {T}
            return OffsetArrays.IdOffsetRange(set_first(parent(r), val), r.offset)
        end
        function set_first!(r::OffsetArrays.IdOffsetRange{T}, val::T) where {T}
            set_first!(parent(r), val)
            return r
        end

        can_set_last(::Type{<:OffsetArrays.IdOffsetRange{T,P}}) where {T,P} = can_set_last(P)
        function set_last(r::OffsetArrays.IdOffsetRange{T}, val::T) where {T}
            return OffsetArrays.IdOffsetRange(set_last(parent(r), val), r.offset)
        end
        function set_last!(r::OffsetArrays.IdOffsetRange{T}, val::T) where {T}
            set_last!(parent(r), val)
            return r
        end

        can_set_length(::Type{<:OffsetArrays.IdOffsetRange{T,P}}) where {T,P} = can_set_length(P)
        function set_length(r::OffsetArrays.IdOffsetRange{T}, len) where {T}
            return OffsetArrays.IdOffsetRange(set_length(parent(r), len), r.offset)
        end
        function set_length!(r::OffsetArrays.IdOffsetRange{T}, len) where {T}
            set_length!(parent(r), len)
            return r
        end

        function find_lasteq(x, r::OffsetArrays.IdOffsetRange)
            idx = find_lasteq(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end

        function find_lastgt(x, r::OffsetArrays.IdOffsetRange)
            idx = find_lastgt(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end
        function find_lastgteq(x, r::OffsetArrays.IdOffsetRange)
            idx = find_lastgteq(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end
        function find_lastlt(x, r::OffsetArrays.IdOffsetRange)
            idx = find_lastlt(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end
        function find_lastlteq(x, r::OffsetArrays.IdOffsetRange)
            idx = find_lastlteq(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end

        function find_firsteq(x, r::OffsetArrays.IdOffsetRange)
            idx = find_firsteq(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end

        function find_firstgt(x, r::OffsetArrays.IdOffsetRange)
            idx = find_firstgt(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end
        function find_firstgteq(x, r::OffsetArrays.IdOffsetRange)
            idx = find_firstgteq(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end
        function find_firstlt(x, r::OffsetArrays.IdOffsetRange)
            idx = find_firstlt(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end
        function find_firstlteq(x, r::OffsetArrays.IdOffsetRange)
            idx = find_firstlteq(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end

        axes_type(::Type{T}) where {T<:OffsetArrays.IdOffsetRange} = Tuple{T}

        has_offset_axes(::Type{<:OffsetArrays.IdOffsetRange}) = true
    end
end
