# Get digital file information from a ServCat reference

Get digital file information from a ServCat reference

## Usage

``` r
get_files(reference_id, file_id = NULL, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- file_id:

  Optional ServCat file ID. If supplied, only that file is returned.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble of file information. The API field `fileSize` is preserved.
When available, an additional `fileSize_kb` column is added by dividing
`fileSize` by 1024.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve information for all files attached to a reference
get_files(140411)

# Retrieve information for a single file attached to a reference
files <- get_files(140411)
get_files(
  reference_id = 140411,
  file_id = files$resourceId[[1]]
)

# Retrieve file information using the secure API
get_files(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
