# Get bibliography metadata for a ServCat reference from the secure ServCat API

Get bibliography metadata for a ServCat reference from the secure
ServCat API

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

A named list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve bibliography metadata from the secure API
get_bibliography(140411)
} # }
```
