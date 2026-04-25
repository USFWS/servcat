# Get lifecycle information from the secure ServCat API

Get lifecycle information from the secure ServCat API

## Usage

``` r
get_lifecycle_info(reference_id, api_key = NULL)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used.

## Value

A named list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve lifecycle information from the secure API
get_lifecycle_info(140411)
} # }
```
