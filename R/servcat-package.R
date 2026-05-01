#' servcat: Access the ServCat REST API
#'
#' Provides R functions for querying the U.S. Fish and Wildlife Service
#' ServCat REST API. The package includes helpers for searching references,
#' retrieving reference records and reference-associated metadata, downloading
#' digital files, retrieving saved-collection contents, and accessing ServCat
#' fixed-list lookup values.
#'
#' @details
#' The package uses the public ServCat API by default. Functions that support
#' secured services include `secure` and `api_key` arguments. If `secure = TRUE`
#' and `api_key` is omitted, the package attempts to read an API key from the
#' `SERVCAT_API_KEY` environment variable.
#'
#' Most metadata functions return tibbles. Detailed reference profile requests
#' return named lists because the ServCat API response contains nested metadata.
#' Nested API fields, such as linked resources or associated units in composite
#' search results, may be returned as list-columns.
#'
#' Search functions return one page of results by default. `search_references()`
#' can retrieve all pages with `all_pages = TRUE`, and stores ServCat paging
#' metadata in the `"page_detail"` attribute of the returned tibble.
#'
#' File downloads are performed by `download_files()`, which returns a tibble
#' reporting the local file path, download status, and any per-file error
#' message.
#'
#' @section Main functions:
#' \itemize{
#'   \item `get_references()` retrieves detailed ServCat reference profiles by
#'     reference ID.
#'   \item `get_reference_summaries()` retrieves summary metadata for one or
#'     more ServCat reference IDs.
#'   \item `search_references()` executes ServCat Advanced Search requests,
#'     including optional composite results and all-page retrieval.
#'   \item `get_collection_references()` retrieves references in a saved
#'     collection.
#'   \item `download_files()` downloads one or more ServCat digital files from a
#'     reference.
#'   \item `service_version()` returns the ServCat service version.
#' }
#'
#' @section Reference metadata functions:
#' \itemize{
#'   \item `get_owners()` retrieves owners associated with a reference.
#'   \item `get_keywords()` retrieves keywords associated with a reference.
#'   \item `get_links()` retrieves external links associated with a reference.
#'   \item `get_files()` retrieves digital file metadata associated with a
#'     reference.
#'   \item `get_bibliography()` retrieves bibliography metadata for a reference.
#'   \item `get_lifecycle()` retrieves lifecycle metadata for a reference.
#'   \item `get_units()` retrieves units associated with a reference.
#'   \item `get_bboxes()` retrieves geographic bounding boxes associated with a
#'     reference.
#'   \item `get_subjects()` retrieves subject categories associated with a
#'     reference.
#'   \item `get_taxa()` retrieves taxa associated with a reference.
#' }
#'
#' @section Lookup-list functions:
#' \itemize{
#'   \item `list_access_constraints()` lists access constraint values.
#'   \item `list_date_precisions()` lists date precision values.
#'   \item `list_file_tags()` lists file tag values.
#'   \item `list_reference_type_groups()` lists reference type groups.
#'   \item `list_reference_types()` lists reference types.
#'   \item `list_subject_categories()` lists subject category values.
#'   \item `list_web_service_types()` lists web service type values.
#' }
#'
#' @section Internal helpers:
#' Internal helper functions support request construction, retry and timeout
#' behavior, response validation, fixed-list lookup retrieval, JSON conversion,
#' file-download path construction, and input validation.
#'
#' @importFrom rlang .data
"_PACKAGE"