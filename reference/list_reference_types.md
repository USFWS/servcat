# List valid ServCat reference types

Retrieves the fixed list of Reference Types and adds `ref_group_code` by
parsing the comma-delimited type codes in the Reference Type Groups
description field. This join is included for convenience when building
Advanced Search criteria.

## Usage

``` r
list_reference_types(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble with ServCat reference type metadata. The `code` column
contains the reference type code. The `ref_group_code` column contains
the inferred reference type group code when one can be matched.

## Examples

``` r
if (FALSE) { # \dontrun{
# List public reference types
list_reference_types()

# List reference types from the secure API
list_reference_types(secure = TRUE)
} # }
```
