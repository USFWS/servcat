# Extract a useful error message from a ServCat API response

Attempts to extract a concise server-supplied error message from an
`httr2_response`. ServCat error responses may be JSON or plain text, so
this helper first looks for common JSON error fields and then falls back
to the response body as text.

## Usage

``` r
response_error_message(resp)
```

## Arguments

- resp:

  An `httr2_response` object.

## Value

A single character string, or `NULL` if no response message can be
extracted.
