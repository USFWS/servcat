# Get reference owners from the secure ServCat API

Get reference owners from the secure ServCat API

## Usage

``` r
get_reference_owners(reference_id, api_key = NULL)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used.

## Value

A tibble of reference owners.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve owners for a reference from the secure API
get_reference_owners(140411)
} # }
```
