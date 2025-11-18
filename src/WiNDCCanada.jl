module WiNDCCanada

    using WiNDCContainer, DataFrames, CSV, XLSX

    abstract type AbstractCanadaTable <: WiNDCtable end;

    struct CanadaTable <: AbstractCanadaTable
        data::DataFrame
        sets::DataFrame
        elements::DataFrame
    end

    WiNDCContainer.domain(::CanadaTable) = [:row, :column, :year, :province]
    WiNDCContainer.base_table(data::CanadaTable) = data.data
    WiNDCContainer.sets(data::CanadaTable) = data.sets
    WiNDCContainer.elements(data::CanadaTable) = data.elements


    export CanadaTable, base_table, table, sets, elements, domain

    include("load_data.jl")

    export build_canada_province_table, build_canada_table

end # module WiNDCCanada
