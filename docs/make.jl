using Documenter, StaticRanges

makedocs(;
    modules=[StaticRanges],
    format=Documenter.HTML(),
    pages=[
        "Introduction" => "index.md",
        "Range Types" => "range_types.md",
        "Indexing" => "indexing.md",
        "AbstractAxis" => "abstractaxis.md",
        "Order Functions" => "order_functions.md",
        "Traits" => "traits.md",
        "Internals" => [
            "Twice Precision" => "twice_precision.md",
        ]
    ],
    repo="https://github.com/Tokazma/StaticRanges.jl/blob/{commit}{path}#L{line}",
    sitename="StaticRanges.jl",
    authors="Zachary P. Christensen",
)

deploydocs(
    repo = "github.com/Tokazama/StaticRanges.jl.git",
)

