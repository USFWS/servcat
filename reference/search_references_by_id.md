# Search ServCat references by ID

Search ServCat references by ID

## Usage

``` r
search_references_by_id(reference_ids, secure = FALSE, api_key = NULL)
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

A named list containing detailed information about each reference.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve detailed information for one reference
search_references_by_id(140411)

# Retrieve detailed information for multiple references
search_references_by_id(c(140411, 140412))

# Use the secure API
search_references_by_id(
  reference_ids = 140411,
  secure = TRUE
)
} # }
```
