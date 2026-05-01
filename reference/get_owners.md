# Get owners for a ServCat reference

Retrieves owners for a ServCat reference from the secure ServCat API.
This endpoint requires a valid `SERVCAT_API_KEY` environment variable
unless `api_key` is supplied directly.

## Usage

``` r
get_owners(reference_id, api_key = NULL)
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
get_owners(140411)
} # }
```
