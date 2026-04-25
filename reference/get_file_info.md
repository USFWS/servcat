# Get digital file metadata from a ServCat reference

Get digital file metadata from a ServCat reference

## Usage

``` r
get_file_info(reference_id, file_id, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- file_id:

  Optional ServCat file ID.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble of file metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve metadata for all digital files attached to a reference
get_file_info(140411)

# Retrieve metadata for a single file attached to a reference
files <- get_file_info(140411)
get_file_info(
  reference_id = 140411,
  file_id = files$resourceId[[1]]
)

# Retrieve file metadata using the secure API
get_file_info(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
