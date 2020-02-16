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
        "Axis Interface" => [
            "Introduction" => "axis_intro.md",
            "Types" => "axis_types.md",
            "Combining Axes" => "combine_axes.md",
            "Concatenating Axes" => "concat_axes.md",
            "Appending Axes" => "append_axes.md",
            "Reindexing Axes" => "reindex_axes.md",
            "Resizing Axes" => "resize_axes.md",
            "Axes to Arrays" => "axes_to_arrays.md",
        ],
        "Internals" => [
            "Twice Precision" => "twice_precision.md",
            "Order Functions" => "order_functions.md",
            "Traits" => "traits.md",
        ]
    ],
    repo="https://github.com/Tokazma/StaticRanges.jl/blob/{commit}{path}#L{line}",
    sitename="StaticRanges.jl",
    authors="Zachary P. Christensen",
)

deploydocs(
    repo = "github.com/Tokazama/StaticRanges.jl.git",
)


