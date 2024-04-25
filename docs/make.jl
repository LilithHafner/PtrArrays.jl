using MallocArrays
using Documenter

DocMeta.setdocmeta!(MallocArrays, :DocTestSetup, :(using MallocArrays); recursive=true)

makedocs(;
    modules=[MallocArrays],
    authors="Lilith Orion Hafner <lilithhafner@gmail.com> and contributors",
    sitename="MallocArrays.jl",
    format=Documenter.HTML(;
        canonical="https://LilithHafner.github.io/MallocArrays.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LilithHafner/MallocArrays.jl",
    devbranch="main",
)
