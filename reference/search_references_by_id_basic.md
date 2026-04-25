# Search ServCat references by ID and return basic fields

Search ServCat references by ID and return basic fields

## Usage

``` r
search_references_by_id_basic(reference_ids, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_ids:

  Numeric vector of ServCat reference IDs.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble containing basic information about each reference.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve basic fields for one reference
search_references_by_id_basic(140411)

# Retrieve basic fields for multiple references
search_references_by_id_basic(c(140411, 140412))

# Use the secure API
search_references_by_id_basic(
  reference_ids = 140411,
  secure = TRUE
)
} # }
```
