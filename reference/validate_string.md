# Validate a single non-empty character argument

Validate a single non-empty character argument

## Usage

``` r
validate_string(x, arg = rlang::caller_arg(x), call = rlang::caller_env())
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
