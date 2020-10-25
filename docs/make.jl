using TenX
using Documenter

makedocs(;
    modules=[TenX],
    authors="Matt Karikomi <mattkarikomi@gmail.com> and contributors",
    repo="https://github.com/mkarikom/TenX.jl/blob/{commit}{path}#L{line}",
    sitename="TenX.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkarikom.github.io/TenX.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkarikom/TenX.jl",
)
