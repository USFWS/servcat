# List valid ServCat file processing tags

Retrieves the fixed list of tags used when designating certain digital
file types for offline processing.

## Usage

``` r
list_file_tags(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble with file processing tag choices.

## Examples

``` r
if (FALSE) { # \dontrun{
# List public file processing tags
list_file_tags()

# List file processing tags from the secure API
list_file_tags(secure = TRUE)
} # }
```
