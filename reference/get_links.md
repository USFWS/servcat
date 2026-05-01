# Get links from a ServCat reference

Get links from a ServCat reference

## Usage

``` r
get_links(reference_id, secure = FALSE, api_key = NULL)
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

A tibble of links.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve links for a public reference
get_links(140411)

# Retrieve links using the secure API
get_links(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
