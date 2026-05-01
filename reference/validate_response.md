# Validate a ServCat API response

Validate a ServCat API response

## Usage

``` r
validate_response(resp, nice_msg_400, nice_msg_500, call = rlang::caller_env())
```

## Arguments

- resp:

  An `httr2_response`.

- nice_msg_400:

  Optional message for 4xx errors.

- nice_msg_500:

  Optional message for 5xx errors.

- call:

  Calling environment.

## Value

`NULL`, invisibly.
