# Validate a positive whole-number argument

Validate a positive whole-number argument

## Usage

``` r
validate_whole_number(
  x,
  arg = rlang::caller_arg(x),
  multiple_ok = FALSE,
  min = 1,
  call = rlang::caller_env()
)
```

## Arguments

- x:

  Value to validate.

- arg:

  Used to generate helpful error messages.

- multiple_ok:

  Logical. Are multiple values allowed?

- min:

  Minimum allowed value.

- call:

  Calling environment.

## Value

`NULL`, invisibly.
