# Get external links from a ServCat reference

Get external links from a ServCat reference

## Usage

``` r
get_external_links(reference_id, secure = FALSE, api_key = NULL)
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

A tibble of external links.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve external links for a public reference
get_external_links(140411)

# Retrieve external links using the secure API
get_external_links(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
