# Download files from a ServCat reference

Download files from a ServCat reference

## Usage

``` r
download_files(
  reference_id,
  resource_ids = NULL,
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
  `NULL`, all files attached to the reference are downloaded.

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

A tibble with one row per requested file and the columns `referenceId`,
`resourceId`, `fileName`, `localPath`, `downloadLink`, `success`, and
`error`. Failed downloads are reported in the returned tibble rather
than aborting the entire batch.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download all public files attached to a reference
downloads <- download_files(
  reference_id = 140411,
  path = tempdir()
)

downloads

# Check whether each file downloaded successfully
downloads[, c("resourceId", "success", "error")]

# Download one or more specific files by resource ID
files <- get_files(140411)
download_files(
  reference_id = 140411,
  resource_ids = files$resourceId[1],
  path = tempdir()
)

# Overwrite existing files if they already exist
download_files(
  reference_id = 140411,
  path = tempdir(),
  overwrite = TRUE
)

# Download internal or restricted files using the secure API
download_files(
  reference_id = 140411,
  path = tempdir(),
  secure = TRUE
)
} # }
```
