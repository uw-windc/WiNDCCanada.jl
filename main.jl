#using WiNDCContainer
using WiNDCCanada

using DataFrames, CSV, XLSX

X = build_canada_table("data/xlsx")


table(X, :commodity) |>
    x -> groupby(x, [:row, :year, :province]) |>
    x -> combine(x, :value => sum => :value) |>
    x -> sort(x, :value)


table(X, :sector) |>
    x -> groupby(x, [:column, :year, :province]) |>
    x -> combine(x, :value => sum => :value) |>
    x -> sort(x, :value)



table(X, :margins) |>
    x -> groupby(x, [:column, :year, :province]) |>
    x -> combine(x, :value => sum => :value) |>
    x -> sort(x, :value)


table(X, :Value_Added) |>
    x -> groupby(x, [:year]) |>
    x -> combine(x, :value => sum => :value) 

table(X, :Final_Demand, :Import) |> 
    x -> groupby(x, [:year]) |>
    x -> combine(x, :value => sum => :value)
    

outerjoin(
    table(X, :Interprovincial_Import) |> x -> select(x, :row, :column => :source, :province => :destination, :value => :import),
    table(X, :Interprovincial_Export) |> x -> select(x, :row, :column => :destination, :province => :source, :value => :export),
    on = [:row, :source, :destination],
) |>
x -> transform(x, 
    [:import, :export] => ByRow(+) => :diff
) |>
x -> sort(x, :diff) 


table(X, :Interprovincial_Import, :Interprovincial_Export) |>
    x -> groupby(x, [:row, :year, :column, :province]) |>
    x -> combine(x, :value => sum => :value) |>
    x -> sort(x, :value)


table(X, :Export)
table(X, :ReExport)
table(X, :Import)


table(X, 
    :Interprovincial_Export, 
    #:Interprovincial_Import, 
    :commodity => :M1140,
    #:trade_province => [:AB, :NL],
    #:province => [:AB, :NL]
    )


elements(X, :province)

table(X, :Intermediate_Demand, :Other_Final_Demand, :ReExport, :Import, :Interprovincial_Import) |>
    x -> groupby(x, [:row, :year, :province]) |>
    x -> combine(x, :value => sum => :value) |>
    x -> subset(x,
        :value => ByRow(>(1e-5)) 
    ) |>
    x -> leftjoin(
        x,
        elements(X, :commodity) |> y -> select(y, :name, :description),
        on = :row => :name
    )




table(X, :Interprovincial_Import) |>
    x -> sort(x, :value)

elements(X, :commodity)

table(X, :pce) |>
    x -> groupby(x, [:row, :province, :year, :parameter]) |>
    x -> combine(x, :value => sum => :value) #|>
    x -> subset(x, :value => ByRow(>(0)))  