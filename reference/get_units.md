# Get units associated with a ServCat reference

Get units associated with a ServCat reference

## Usage

``` r
get_units(reference_id, secure = FALSE, api_key = NULL)
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

A tibble of units associated with the reference.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve units associated with a public reference
get_units(140411)

# Retrieve units using the secure API
get_units(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
