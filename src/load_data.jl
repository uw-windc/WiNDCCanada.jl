
struct ExcelRange
    start::Tuple{String, Int}
    stop::Tuple{String, Int}
    function ExcelRange(range::String)
        if !occursin(":", range)
            range = "$range:$range"
        end
        (a1, a2, a3, a4) = match(r"^([a-zA-Z]+)(\d+):([a-zA-Z]+)(\d+)$", range)

        start = (a1, parse(Int, a2))
        stop = (a3, parse(Int, a4))
        return new(start, stop)
    end
end

function excel_intersection(range1::ExcelRange, range2::ExcelRange)
    r1_c1_row, r1_c1_col = range1.start
    r1_c2_row, r1_c2_col = range1.stop
    r2_c1_row, r2_c1_col = range2.start
    r2_c2_row, r2_c2_col = range2.stop

    return "$r2_c1_row$r1_c1_col:$r2_c2_row$r1_c2_col"
end


function excel_intersection(range1::String, range2::String)
    return excel_intersection(ExcelRange(range1), ExcelRange(range2))
end

function parse_excel_set_elements(data::Matrix{Any})
    1∈size(data) || error("Must be either a column or row vector")
    return vec(data)
end

function parse_excel_set_elements(data::String)
    return [data]
end

function load_set(data::XLSX.XLSXFile, sheet::String, elements::String, description::String, name::Symbol)
    return (parse_excel_set_elements(data[sheet][elements]), parse_excel_set_elements(data[sheet][description])) |>
        x -> DataFrame(name = x[1], description = x[2]) |>
        x -> transform(x, 
            :name => ByRow(Symbol) => :name,
            :name => ByRow(y -> name) => :set
        )
end

function load_data(
    data::XLSX.XLSXFile,
    table::String,
    rows::String,
    columns::String,
    parameter::Symbol;
    use = false
    )


    row_labels = Symbol.(parse_excel_set_elements(data[table][rows]))
    column_labels = Symbol.(parse_excel_set_elements(data[table][columns]))
    intersect = excel_intersection(rows, columns)
    return DataFrame(
        [row_labels data[table][intersect]], 
        vec([:row; column_labels])
    ) |>
    x -> stack(x, Not(:row), variable_name = :column, value_name = :value) |>
    x -> subset(x, :value => ByRow(!=(0))) |>
    x -> transform(x,
        :row => ByRow(y -> parameter) => :parameter,
        :row => ByRow(y -> 2022) => :year,
        :value => ByRow(y -> use ? -y : y) => :value,
        :column => ByRow(Symbol) => :column,
    )

end


function build_canada_sets()
    sets = DataFrame([
        (name = :commodity, description = "Commodities", domain = :row),
        (name = :product_tax, description = "Product Taxes", domain = :row),
        (name = :product_subsidy, description = "Product Subsidies", domain = :row),
        (name = :production_subsidy, description = "Production Subsidies", domain = :row),
        (name = :production_tax, description = "Production Taxes", domain = :row),
        (name = :labor, description = "Labor", domain = :row),
        (name = :social_contribution, description = "Social Contributions", domain = :row),
        (name = :mixed_income, description = "Mixed Income", domain = :row),
        (name = :surplus, description = "Surplus", domain = :row),

        (name = :sector, description = "Industries/Sectors", domain = :column),
        (name = :import, description = "Imports", domain = :column),
        (name = :province, description = "Provinces/Territories", domain = :province),
        (name = :trade_province, description = "Trade Provinces/Territories", domain = :column),
        (name = :margins, description = "Margins", domain = :column),
        (name = :taxes, description = "Taxes", domain = :column),
        (name = :pce, description = "Personal Consumption Expenditures", domain = :column),
        (name = :government, description = "Government Consumption Expenditures", domain = :column),
        (name = :investment, description = "Investment", domain = :column),
        (name = :inventory_change, description = "Inventory Change", domain = :column),
        (name = :export, description = "Exports", domain = :column),
        (name = :reexport, description = "Re-exports", domain = :column),
        (name = :year, description = "Year", domain = :year),
        (name = :Intermediate_Supply, description = "Intermediate Supply", domain = :parameter),
        (name = :Intermediate_Demand, description = "Intermediate Demand", domain = :parameter),
        (name = :Import, description = "Imports", domain = :parameter),
        (name = :Export, description = "Exports", domain = :parameter),
        (name = :ReExport, description = "Re-exports", domain = :parameter),
        (name = :Interprovincial_Import, description = "Interprovincial Imports", domain = :parameter),
        (name = :Interprovincial_Export, description = "Interprovincial Exports", domain = :parameter),
        (name = :Margins, description = "Margins", domain = :parameter),
        (name = :Taxes, description = "Taxes", domain = :parameter),
        (name = :PCE, description = "Personal Consumption Expenditures", domain = :parameter),
        (name = :Government, description = "Government Consumption Expenditures", domain = :parameter),
        (name = :Investment, description = "Investment", domain = :parameter),
        (name = :Inventory_Change, description = "Inventory Change", domain = :parameter),
        (name = :Product_Tax, description = "Product Taxes", domain = :parameter),
        (name = :Product_Subsidy, description = "Product Subsidies", domain = :parameter),
        (name = :Production_Subsidy, description = "Production Subsidies", domain = :parameter),
        (name = :Production_Tax, description = "Production Taxes", domain = :parameter),
        (name = :Labor, description = "Labor", domain = :parameter),
        (name = :Social_Contribution, description = "Social Contributions", domain = :parameter),
        (name = :Mixed_Income, description = "Mixed Income", domain = :parameter),
        (name = :Surplus, description = "Surplus", domain = :parameter),
        (name = :Value_Added, description = "Value Added", domain = :parameter),
        (name = :Final_Demand, description = "Final Demand", domain = :parameter),
    ])
end

function build_canada_elements(file_path::String)
    data = XLSX.readxlsx(file_path)
    return build_canada_elements(data)
end

function build_canada_elements(data::XLSX.XLSXFile)
    elements = vcat(
        load_set(data, "Supply", "A7:A69", "B7:B69", :commodity),
        load_set(data, "Supply", "A70", "B70", :product_tax),
        load_set(data, "Supply", "A71", "B71", :product_subsidy),
        load_set(data, "Supply", "A73", "B73", :production_subsidy),
        load_set(data, "Supply", "A74", "B74", :production_tax),
        load_set(data, "Supply", "A75", "B75", :labor),
        load_set(data, "Supply", "A76", "B76", :social_contribution),
        load_set(data, "Supply", "A77", "B77", :mixed_income),
        load_set(data, "Supply", "A78", "B78", :surplus),
        load_set(data, "Supply", "C6:AH6", "C5:AH5", :sector),
        load_set(data, "Supply", "AJ6", "AJ5", :import),
        load_set(data, "Supply", "AK6:AX6", "AK5:AX5", :province),
        load_set(data, "Supply", "AK6:AX6", "AK5:AX5", :trade_province),
        load_set(data, "Supply", "BA6:BB6", "BA5:BB5", :margins),
        load_set(data, "Supply", "BC6:BC6", "BC5:BC5", :taxes),
        load_set(data, "Use_Purchaser", "AJ6:AN6", "AJ5:AN5", :pce),
        load_set(data, "Use_Purchaser", "AO6:AP6", "AO5:AP5", :government),
        load_set(data, "Use_Purchaser", "AQ6:AZ6", "AQ5:AZ5", :investment),
        load_set(data, "Use_Purchaser", "BA6", "BA5", :inventory_change),
        load_set(data, "Use_Purchaser", "BB6", "BB5", :export),
        load_set(data, "Use_Purchaser", "BC6", "BC5", :reexport),
        DataFrame([
            (name = 2022, description = "Year 2022", set = :year),
            (name = :intermediate_supply, description = "Intermediate Supply", set = :Intermediate_Supply),
            (name = :intermediate_demand, description = "Intermediate Demand", set = :Intermediate_Demand),
            (name = :import, description = "Imports", set = :Import),
            (name = :export, description = "Exports", set = :Export),
            (name = :reexport, description = "Re-exports", set = :ReExport),
            (name = :interprovincial_import, description = "Interprovincial Imports", set = :Interprovincial_Import),
            (name = :interprovincial_export, description = "Interprovincial Exports", set = :Interprovincial_Export),
            (name = :margins, description = "Margins", set = :Margins),
            (name = :taxes, description = "Taxes", set = :Taxes),
            (name = :pce, description = "Personal Consumption Expenditures", set = :PCE),
            (name = :government, description = "Government Consumption Expenditures", set = :Government),
            (name = :investment, description = "Investment", set = :Investment),
            (name = :inventory_change, description = "Inventory Change", set = :Inventory_Change),
            (name = :product_tax, description = "Product Taxes", set = :Product_Tax),
            (name = :product_subsidy, description = "Product Subsidies", set = :Product_Subsidy),
            (name = :production_subsidy, description = "Production Subsidies", set = :Production_Subsidy),
            (name = :production_tax, description = "Production Taxes", set = :Production_Tax),
            (name = :labor, description = "Labor", set = :Labor),
            (name = :social_contribution, description = "Social Contributions", set = :Social_Contribution),
            (name = :mixed_income, description = "Mixed Income", set = :Mixed_Income),
            (name = :surplus, description = "Surplus", set = :Surplus),

            #(name = :product_tax, description = "Product Taxes", set = :Value_Added),
            #(name = :product_subsidy, description = "Product Subsidies", set = :Value_Added),
            #(name = :production_subsidy, description = "Production Subsidies", set = :Value_Added),
            #(name = :production_tax, description = "Production Taxes", set = :Value_Added),
            (name = :labor, description = "Labor", set = :Value_Added),
            #(name = :social_contribution, description = "Social Contributions", set = :Value_Added),
            (name = :mixed_income, description = "Mixed Income", set = :Value_Added),
            (name = :surplus, description = "Surplus", set = :Value_Added),


            (name = :pce, description = "Personal Consumption Expenditures", set = :Final_Demand),
            (name = :government, description = "Government Consumption Expenditures", set = :Final_Demand),
            (name = :investment, description = "Investment", set = :Final_Demand),
            (name = :inventory_change, description = "Inventory Change", set = :Final_Demand),
            (name = :export, description = "Exports", set = :Final_Demand),
            (name = :reexport, description = "Re-exports", set = :Final_Demand),
            (name = :interprovincial_export, description = "Interprovincial Exports", set = :Final_Demand),

        ]),
    )

end

function build_canada_data(file_path::String, province::Symbol)
    data = XLSX.readxlsx(file_path)
    return build_canada_data(data, province)
end

function build_canada_data(data::XLSX.XLSXFile, province::Symbol)
    df = vcat(
        load_data(data, "Supply", "A7:A69", "C6:AH6", :intermediate_supply),
        load_data(data, "Supply", "A7:A69", "AJ6", :import),
        load_data(data, "Supply", "A7:A69", "AK6:AX6", :interprovincial_import),
        load_data(data, "Supply", "A7:A69", "BA6:BB6", :margins),
        load_data(data, "Supply", "A7:A69", "BC6", :taxes),
        load_data(data, "Use_Purchaser", "A7:A69", "C6:AH6", :intermediate_demand;use=true),
        load_data(data, "Use_Purchaser", "A7:A69", "AJ6:AN6", :pce;use=true),
        load_data(data, "Use_Purchaser", "A7:A69", "AO6:AP6", :government;use=true),
        load_data(data, "Use_Purchaser", "A7:A69", "AQ6:AZ6", :investment;use=true),
        load_data(data, "Use_Purchaser", "A7:A69", "BA6", :inventory_change;use=true),
        load_data(data, "Use_Purchaser", "A7:A69", "BB6", :export;use=true),
        load_data(data, "Use_Purchaser", "A7:A69", "BC6", :reexport;use=true),
        load_data(data, "Use_Purchaser", "A7:A69", "BD6:BQ6", :interprovincial_export;use=true),
        load_data(data, "Use_Purchaser", "A70", "C6:AH6", :product_tax;use=true),
        load_data(data, "Use_Purchaser", "A71", "C6:AH6", :product_subsidy;use=true),
        load_data(data, "Use_Purchaser", "A73", "C6:AH6", :production_subsidy;use=true),
        load_data(data, "Use_Purchaser", "A74", "C6:AH6", :production_tax;use=true),
        load_data(data, "Use_Purchaser", "A75", "C6:AH6", :labor;use=true),
        load_data(data, "Use_Purchaser", "A76", "C6:AH6", :social_contribution;use=true),
        load_data(data, "Use_Purchaser", "A77", "C6:AH6", :mixed_income;use=true),
        load_data(data, "Use_Purchaser", "A78", "C6:AH6", :surplus;use=true ),
    ) |>
    x -> transform(x,
        :parameter => ByRow(y -> province) => :province,
    ) |>
    x -> select(x,
        [:row, :column, :year, :province, :parameter, :value]
    )

end




function build_canada_province_table(path::String, province::Symbol)
        
    data = XLSX.readxlsx(path)


    sets = build_canada_sets()
    elements = build_canada_elements(data)
    df = build_canada_data(data, province)


    X = CanadaTable(df, sets, elements; regularity_check=true) 

    return X



end

function build_canada_table(base_directory::String)
    provinces = [
        :AB, :BC, :CE, :MB, :NB, :NL, :NS, :NT, :NU, :ON, :PE, :QC, :SK, :YT
    ]


    sets = build_canada_sets()
    elements = build_canada_elements(joinpath(base_directory, "$(provinces[1])_SUT_C2022_S.xlsx"))

    df = DataFrame(
        [:row => Symbol[], :column => Symbol[], :year => Int[], :province => Symbol[], :parameter => Symbol[], :value => Float64[]]
    )

    for province in provinces
        df_province = build_canada_data(
            joinpath(base_directory, "$(province)_SUT_C2022_S.xlsx"),
            province
        )
        df = vcat(df, df_province)
    end

    X = CanadaTable(df, sets, elements; regularity_check=true)
    return X

end