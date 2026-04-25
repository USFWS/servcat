# Download files from a ServCat reference

Download files from a ServCat reference

## Usage

``` r
download_reference_files(
  reference_id,
  resource_ids,
  path = "downloads",
  secure = FALSE,
  api_key = NULL,
  overwrite = FALSE
)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- resource_ids:

  Optional numeric vector of ServCat resource IDs to download. If
  omitted, all files attached to the reference are downloaded.

- path:

  Directory where files should be saved. Defaults to `"downloads"`.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

- overwrite:

  Logical. Overwrite existing files if they already exist?

## Value

A tibble with one row per downloaded file.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download all files attached to a reference
download_reference_files(
  reference_id = 140411,
  path = tempdir()
)

# Download one or more specific files by resource ID
files <- get_file_info(140411)
download_reference_files(
  reference_id = 140411,
  resource_ids = files$resourceId[1],
  path = tempdir()
)

# Overwrite existing files if they already exist
download_reference_files(
  reference_id = 140411,
  path = tempdir(),
  overwrite = TRUE
)

# Download files using the secure API
download_reference_files(
  reference_id = 140411,
  path = tempdir(),
  secure = TRUE
)
} # }
```
