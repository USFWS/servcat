# Build a ServCat request

Build a ServCat request

## Usage

``` r
servcat_request(secure = FALSE, suppress_errors = TRUE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- suppress_errors:

  Logical. Suppress HTTP errors so they can be handled by
  [`validate_response()`](https://ideal-adventure-2qyoqkw.pages.github.io/reference/validate_response.md).

- api_key:

  Optional API key. If omitted for secure requests, the value is read
  from `SERVCAT_API_KEY`.

## Value

An `httr2_request` object.
