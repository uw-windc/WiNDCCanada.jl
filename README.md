# WiNDC Canada

This package provides tools to load and manipulate Supply and Use Tables (SUTs) for Canadian provinces using the WiNDC framework.

Download the XLSX data files from [Statistics Canada](https://www150.statcan.gc.ca/n1/pub/15-602-x/15-602-x2017001-eng.htm) and extract them. 

## Usage

```julia
using WiNDCCanada

X = build_canada_table("path/to/extracted/data")
```
