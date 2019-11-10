using Documenter, Bench

makedocs(;
    modules=[Bench],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/kolia/Bench.jl/blob/{commit}{path}#L{line}",
    sitename="Bench.jl",
    authors="Kolia Sadeghi <ksadeghi@princeton.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/kolia/Bench.jl",
)
