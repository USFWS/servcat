# servcat: Access the ServCat REST API

Provides R functions for querying the U.S. Fish and Wildlife Service
ServCat REST API. The package includes helpers for searching references,
retrieving reference records and reference-associated metadata,
downloading digital files, retrieving saved-collection contents, and
accessing ServCat fixed-list lookup values.

## Details

The package uses the public ServCat API by default. Functions that
support secured services include `secure` and `api_key` arguments. If
`secure = TRUE` and `api_key` is omitted, the package attempts to read
an API key from the `SERVCAT_API_KEY` environment variable.

Most metadata functions return tibbles. Detailed reference profile
requests return named lists because the ServCat API response contains
nested metadata. Nested API fields, such as linked resources or
associated units in composite search results, may be returned as
list-columns.

Search functions return one page of results by default.
[`search_references()`](https://usfws.github.io/servcat/reference/search_references.md)
can retrieve all pages with `all_pages = TRUE`, and stores ServCat
paging metadata in the `"page_detail"` attribute of the returned tibble.

File downloads are performed by
[`download_files()`](https://usfws.github.io/servcat/reference/download_files.md),
which returns a tibble reporting the local file path, download status,
and any per-file error message.

## Main functions

- [`get_references()`](https://usfws.github.io/servcat/reference/get_references.md)
  retrieves detailed ServCat reference profiles by reference ID.

- [`get_reference_summaries()`](https://usfws.github.io/servcat/reference/get_reference_summaries.md)
  retrieves summary metadata for one or more ServCat reference IDs.

- [`search_references()`](https://usfws.github.io/servcat/reference/search_references.md)
  executes ServCat Advanced Search requests, including optional
  composite results and all-page retrieval.

- [`get_collection_references()`](https://usfws.github.io/servcat/reference/get_collection_references.md)
  retrieves references in a saved collection.

- [`download_files()`](https://usfws.github.io/servcat/reference/download_files.md)
  downloads one or more ServCat digital files from a reference.

- [`service_version()`](https://usfws.github.io/servcat/reference/service_version.md)
  returns the ServCat service version.

## Reference metadata functions

- [`get_owners()`](https://usfws.github.io/servcat/reference/get_owners.md)
  retrieves owners associated with a reference.

- [`get_keywords()`](https://usfws.github.io/servcat/reference/get_keywords.md)
  retrieves keywords associated with a reference.

- [`get_links()`](https://usfws.github.io/servcat/reference/get_links.md)
  retrieves external links associated with a reference.

- [`get_files()`](https://usfws.github.io/servcat/reference/get_files.md)
  retrieves digital file metadata associated with a reference.

- [`get_bibliography()`](https://usfws.github.io/servcat/reference/get_bibliography.md)
  retrieves bibliography metadata for a reference.

- [`get_lifecycle()`](https://usfws.github.io/servcat/reference/get_lifecycle.md)
  retrieves lifecycle metadata for a reference.

- [`get_units()`](https://usfws.github.io/servcat/reference/get_units.md)
  retrieves units associated with a reference.

- [`get_bboxes()`](https://usfws.github.io/servcat/reference/get_bboxes.md)
  retrieves geographic bounding boxes associated with a reference.

- [`get_subjects()`](https://usfws.github.io/servcat/reference/get_subjects.md)
  retrieves subject categories associated with a reference.

- [`get_taxa()`](https://usfws.github.io/servcat/reference/get_taxa.md)
  retrieves taxa associated with a reference.

## Lookup-list functions

- [`list_access_constraints()`](https://usfws.github.io/servcat/reference/list_access_constraints.md)
  lists access constraint values.

- [`list_date_precisions()`](https://usfws.github.io/servcat/reference/list_date_precisions.md)
  lists date precision values.

- [`list_file_tags()`](https://usfws.github.io/servcat/reference/list_file_tags.md)
  lists file tag values.

- [`list_reference_type_groups()`](https://usfws.github.io/servcat/reference/list_reference_type_groups.md)
  lists reference type groups.

- [`list_reference_types()`](https://usfws.github.io/servcat/reference/list_reference_types.md)
  lists reference types.

- [`list_subject_categories()`](https://usfws.github.io/servcat/reference/list_subject_categories.md)
  lists subject category values.

- [`list_web_service_types()`](https://usfws.github.io/servcat/reference/list_web_service_types.md)
  lists web service type values.

## Internal helpers

Internal helper functions support request construction, retry and
timeout behavior, response validation, fixed-list lookup retrieval, JSON
conversion, file-download path construction, and input validation.

## See also

Useful links:

- <https://USFWS.github.io/servcat/>

- <https://github.com/USFWS/servcat>

- <https://usfws.github.io/servcat/>

- Report bugs at <https://github.com/USFWS/servcat/issues>

## Author

**Maintainer**: McCrea Cobb <mccrea_cobb@fws.gov>
([ORCID](https://orcid.org/0000-0001-9412-1468))
