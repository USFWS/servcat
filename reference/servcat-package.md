# servcat: Access the ServCat REST API

Provides R functions for querying the U.S. Fish and Wildlife Service
ServCat REST API. The package includes helpers for retrieving reference
records, reference-associated metadata, fixed-list lookup values,
digital resources, saved collections, and Advanced Search results.

## Details

The package uses the public ServCat API by default. Functions that
support secured services include `secure` and `api_key` arguments.

Most functions return tibbles. Nested API fields, such as linked
resources or associated units in composite search results, may be
returned as list-columns.

## Main functions

- `get_reference()` retrieves a ServCat reference by ID.

- [`search_references_advanced()`](https://ideal-adventure-2qyoqkw.pages.github.io/reference/search_references_advanced.md)
  executes an Advanced Search.

- [`get_collection_references()`](https://ideal-adventure-2qyoqkw.pages.github.io/reference/get_collection_references.md)
  retrieves references in a saved collection.

- `download_files()` downloads one or more ServCat digital files.

## Internal helpers

Internal helper functions support request construction, response
validation, fixed-list lookup retrieval, and input validation.

## See also

Useful links:

- <https://USFWS.github.io/servcat/>

- <https://github.com/USFWS/servcat>

- <https://ideal-adventure-2qyoqkw.pages.github.io/>

- Report bugs at <https://github.com/USFWS/servcat/issues>

## Author

**Maintainer**: McCrea Cobb <mccrea_cobb@fws.gov>
([ORCID](https://orcid.org/0000-0001-9412-1468))
