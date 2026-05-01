# Validate a TRUE/FALSE argument

Validate a TRUE/FALSE argument

## Usage

``` r
validate_flag(x, arg = rlang::caller_arg(x), call = rlang::caller_env())
```

## Arguments

- x:

  Value to validate.

- arg:

  Used to generate helpful error messages.

- call:

  Calling environment.

## Value

`NULL`, invisibly.
