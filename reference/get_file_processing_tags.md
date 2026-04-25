# Get valid ServCat file processing tags

Retrieves the fixed list of tags used when designating certain digital
file types for offline processing.

## Usage

``` r
get_file_processing_tags(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key.

## Value

A tibble with file processing tag choices.
