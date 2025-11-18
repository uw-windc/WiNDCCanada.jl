using WiNDCContainer
using WiNDCCanada

using DataFrames, CSV, XLSX




file_path = raw"data\xlsx\AB_SUT_C2022_S.xlsx"

X = build_canada_province_table(file_path, :AB)



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