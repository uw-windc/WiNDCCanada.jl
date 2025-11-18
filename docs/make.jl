using WiNDCCanada
using Documenter
#using Literate

DocMeta.setdocmeta!(WiNDCCanada, :DocTestSetup, :(using WiNDCCanada); recursive=true)


const _PAGES = [
    "Introduction" => ["index.md"],
    "API Reference" => ["docs.md"],
]


#literate_files = Dict(
#    "basic_rc" => ( 
#        input = "src/Tutorials/robinson_crusoe/basic_rc.jl",
#        output = "src/Tutorials/robinson_crusoe/"
#    ),
#    "first_example" => ( 
#        input = "src/Tutorials/getting_started/first_example.jl",
#        output = "src/Tutorials/getting_started/"
#    ),
#    "m22" => ( 
#        input = "src/Tutorials/intermediate_examples/M22.jl",
#        output = "src/Tutorials/intermediate_examples/"
#    )
#)
#
#
#for (name, paths) in literate_files
#    EXAMPLE = joinpath(@__DIR__, paths.input)
#    OUTPUT = joinpath(@__DIR__, paths.output)
#    Literate.markdown(EXAMPLE, 
#                      OUTPUT;
#                      name = name)
#end



makedocs(;
    modules=[WiNDCCanada],
    authors="Mitch Phillipson",
    sitename="WiNDCCanada.jl",
    format=Documenter.HTML(;
        canonical="https://github.com/uw-windc/WiNDCCanada.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=_PAGES
)

deploydocs(;
    repo = "https://github.com/uw-windc/WiNDCCanada.jl",
    devbranch = "main",
    branch = "gh-pages",
    push_preview = true
)