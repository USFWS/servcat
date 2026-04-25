# Get taxa associated with a ServCat reference

Get taxa associated with a ServCat reference

## Usage

``` r
get_taxa(reference_id, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble of taxa associated with the reference.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve taxa associated with a public reference
get_taxa(140411)

# Retrieve taxa using the secure API
get_taxa(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
