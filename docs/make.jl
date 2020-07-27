using Documenter, StaticRanges

makedocs(;
    modules=[StaticRanges],
    format=Documenter.HTML(),
    pages=[
        "Introduction" => "index.md",
        "Ranges" => [
            "Quick Start" => "quick_start.md",
            "Range Types" => "range_types.md",
            "Manipulating Ranges" => "manipulating_ranges.md",
        ],
        "Internals" => [
            "Twice Precision" => "twice_precision.md",
            "Order Functions" => "order_functions.md",
            "Traits" => "traits.md",
        ],
    ],
    repo="https://github.com/Tokazma/StaticRanges.jl/blob/{commit}{path}#L{line}",
    sitename="StaticRanges.jl",
    authors="Zachary P. Christensen",
)

deploydocs(
    repo = "github.com/Tokazama/StaticRanges.jl.git",
)


