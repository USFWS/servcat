# Get geographic bounding boxes from a ServCat reference

Get geographic bounding boxes from a ServCat reference

## Usage

``` r
get_bounding_boxes(reference_id, secure = FALSE, api_key = NULL)
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

A tibble of bounding box coordinates associated with the reference.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve geographic bounding boxes for a public reference
get_bounding_boxes(140411)

# Retrieve geographic bounding boxes using the secure API
get_bounding_boxes(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
