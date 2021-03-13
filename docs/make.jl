using Documenter, StaticRanges

makedocs(;
    modules=[StaticRanges],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/Tokazma/StaticRanges.jl/blob/{commit}{path}#L{line}",
    sitename="StaticRanges.jl",
    authors="Zachary P. Christensen",
)

deploydocs(
    repo = "github.com/Tokazama/StaticRanges.jl.git",
)


