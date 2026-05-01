# Get bibliography metadata for a ServCat reference

Retrieves bibliography metadata for a ServCat reference from the secure
ServCat API. This endpoint requires a valid `SERVCAT_API_KEY`
environment variable unless `api_key` is supplied directly.

## Usage

``` r
get_bibliography(reference_id, api_key = NULL)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used.

## Value

A named list. Field names returned by the API are preserved, including
`abstract` when present.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve bibliography metadata from the secure API
get_bibliography(140411)
} # }
```
