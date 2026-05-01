# Get bounding boxes from a ServCat reference

Get bounding boxes from a ServCat reference

## Usage

``` r
get_bboxes(reference_id, secure = FALSE, api_key = NULL)
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
# Retrieve bounding boxes for a public reference
get_bboxes(140411)

# Retrieve bounding boxes using the secure API
get_bboxes(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
