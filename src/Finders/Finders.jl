
using ChainedFixes
using IntervalSets
using OffsetArrays
using OffsetArrays: IdOffsetRange
using Base: OneTo, TwicePrecision, step_hp, @propagate_inbounds

export
    find_first,
    find_firsteq,
    find_firstgt,
    find_firstlt,
    find_firstgteq,
    find_firstlteq,
    find_last,
    find_lasteq,
    find_lastgt,
    find_lastlt,
    find_lastgteq,
    find_lastlteq,
    findin,
    find_all,
    find_alleq,
    find_allgt,
    find_alllt,
    find_allgteq,
    find_alllteq

zerounit(::T) where {T} = zerounit(T)
zerounit(::Type{T}) where {T} = oneunit(T) - oneunit(T)

include("combine.jl")
include("findin.jl")
include("findvalue.jl")
include("find_firsteq.jl")
include("find_firstgt.jl")
include("find_firstlt.jl")
include("find_firstgteq.jl")
include("find_firstlteq.jl")
include("find_lasteq.jl")
include("find_lastgt.jl")
include("find_lastlt.jl")
include("find_lastgteq.jl")
include("find_lastlteq.jl")
include("findall.jl")
include("findlast.jl")
include("findfirst.jl")
include("find_firstin.jl")
include("find_lastin.jl")

for (cmp,cmpfull) in (
    (:eq, "equal to"),
    (:lt, "less than"), 
    (:lteq, "less than or equal to"),
    (:gt, "greater than"), 
    (:gteq, "greater than or equal to"),
    (:in, "in"),)
    for start in (:first, :last)
        get_cmp = Symbol(:get_, start, cmp)
        find_cmp = Symbol(:find_, start, cmp)

        get_cmp_doc = """
            $get_cmp(val, collection)

        Find the $start value in `collection` that is $cmpfull.
        If no values is $cmpfull then `nothing` is returned.
        """ 

        @eval begin
            @doc $get_cmp_doc
            function $(get_cmp)(val, collection)
                i = $find_cmp(val, collection)
                if i isa Nothing
                    return i
                else
                    return @inbounds(getindex(collection, i))
                end
            end
        end

    end
end

for f in (:find_lasteq, :find_lastgt, :find_lastgteq, :find_lastlt, :find_lastlteq,
          :find_firsteq, :find_firstgt, :find_firstgteq, :find_firstlt, :find_firstlteq)
    @eval begin
        function $f(x, r::IdOffsetRange)
            idx = $f(x - r.offset, parent(r))
            if idx isa Nothing
                return idx
            else
                return idx + r.offset
            end
        end
    end
end
