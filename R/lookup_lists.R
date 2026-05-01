#' List valid ServCat access constraint text
#'
#' Retrieves the fixed list of access constraint text used when setting
#' permissions and constraints for a ServCat reference.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble with access constraint metadata.
#'
#' @examples
#' \dontrun{
#' # List public access constraint choices
#' list_access_constraints()
#'
#' # List access constraint choices from the secure API
#' list_access_constraints(secure = TRUE)
#' }
#'
#' @export
list_access_constraints <- function(secure = FALSE, api_key = NULL) {
  get_fixed_list("AccessConstraints", secure = secure, api_key = api_key)
}


#' List valid ServCat date precision choices
#'
#' Retrieves the fixed list of DatePrecision choices used for issued dates and
#' content begin/end dates.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble with date precision choices.
#'
#' @examples
#' \dontrun{
#' # List public date precision choices
#' list_date_precisions()
#'
#' # List date precision choices from the secure API
#' list_date_precisions(secure = TRUE)
#' }
#'
#' @export
list_date_precisions <- function(secure = FALSE, api_key = NULL) {
  get_fixed_list("DatePrecisions", secure = secure, api_key = api_key)
}


#' List valid ServCat file processing tags
#'
#' Retrieves the fixed list of tags used when designating certain digital file
#' types for offline processing.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble with file processing tag choices.
#'
#' @examples
#' \dontrun{
#' # List public file processing tags
#' list_file_tags()
#'
#' # List file processing tags from the secure API
#' list_file_tags(secure = TRUE)
#' }
#'
#' @export
list_file_tags <- function(secure = FALSE, api_key = NULL) {
  get_fixed_list("FileProcessingTags", secure = secure, api_key = api_key)
}


#' List valid ServCat reference type groups
#'
#' Retrieves the fixed list of Reference Type Groups used as an Advanced Search
#' option in ServCat.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble with reference type group choices.
#'
#' @examples
#' \dontrun{
#' # List public reference type groups
#' list_reference_type_groups()
#'
#' # List reference type groups from the secure API
#' list_reference_type_groups(secure = TRUE)
#' }
#'
#' @export
list_reference_type_groups <- function(secure = FALSE, api_key = NULL) {
  get_fixed_list("ReferenceTypeGroups", secure = secure, api_key = api_key)
}


#' List valid ServCat reference types
#'
#' Retrieves the fixed list of Reference Types and adds `ref_group_code` by
#' parsing the comma-delimited type codes in the Reference Type Groups
#' description field. This join is included for convenience when building
#' Advanced Search criteria.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble with ServCat reference type metadata. The `code` column
#'   contains the reference type code. The `ref_group_code` column contains the
#'   inferred reference type group code when one can be matched.
#'
#' @examples
#' \dontrun{
#' # List public reference types
#' list_reference_types()
#'
#' # List reference types from the secure API
#' list_reference_types(secure = TRUE)
#' }
#'
#' @export
list_reference_types <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)

  ref_types <- get_fixed_list(
    "ReferenceTypes",
    secure = secure,
    api_key = api_key
  )

  ref_groups <- get_fixed_list(
    "ReferenceTypeGroups",
    secure = secure,
    api_key = api_key
  )

  if (nrow(ref_types) == 0 || nrow(ref_groups) == 0) {
    return(ref_types)
  }

  ref_group_map <- purrr::map_dfr(seq_len(nrow(ref_groups)), function(i) {
    group_code <- ref_groups$code[[i]]
    group_description <- rlang::`%||%`(ref_groups$description[[i]], "")

    tibble::tibble(
      ref_group_code = group_code,
      code = stringr::str_split(group_description, ",\\s*")[[1]]
    )
  }) |>
    dplyr::filter(.data$code != "")

  ref_types |>
    dplyr::left_join(ref_group_map, by = "code") |>
    dplyr::relocate(.data$ref_group_code, .after = .data$code) |>
    dplyr::arrange(.data$ref_group_code, .data$code) |>
    tibble::as_tibble()
}


#' List valid ServCat subject categories
#'
#' Retrieves the fixed list of Subject Categories used on the Keywords and
#' Category tab in ServCat.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble with subject category choices.
#'
#' @examples
#' \dontrun{
#' # List public subject category choices
#' list_subject_categories()
#'
#' # List subject category choices from the secure API
#' list_subject_categories(secure = TRUE)
#' }
#'
#' @export
list_subject_categories <- function(secure = FALSE, api_key = NULL) {
  get_fixed_list("SubjectCategories", secure = secure, api_key = api_key)
}


#' List valid ServCat web service types
#'
#' Retrieves the fixed list of Web Service, or Linked Resource, types used by
#' ServCat.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble with web service type choices.
#'
#' @examples
#' \dontrun{
#' # List public web service type choices
#' list_web_service_types()
#'
#' # List web service type choices from the secure API
#' list_web_service_types(secure = TRUE)
#' }
#'
#' @export
list_web_service_types <- function(secure = FALSE, api_key = NULL) {
  get_fixed_list("WebServiceTypes", secure = secure, api_key = api_key)
}
