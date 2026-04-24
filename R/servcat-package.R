#' servcat: Access the ServCat REST API
#'
#' Provides R functions for querying the U.S. Fish and Wildlife Service
#' ServCat REST API. The package includes helpers for retrieving reference
#' records, reference-associated metadata, fixed-list lookup values, digital
#' resources, saved collections, and Advanced Search results.
#'
#' @details
#' The package uses the public ServCat API by default. Functions that support
#' secured services include `secure` and `api_key` arguments.
#'
#' Most functions return tibbles. Nested API fields, such as linked resources
#' or associated units in composite search results, may be returned as
#' list-columns.
#'
#' @section Main functions:
#' \itemize{
#'   \item `get_reference()` retrieves a ServCat reference by ID.
#'   \item `search_references_advanced()` executes an Advanced Search.
#'   \item `get_collection_references()` retrieves references in a saved
#'     collection.
#'   \item `download_files()` downloads one or more ServCat digital files.
#' }
#'
#' @section Internal helpers:
#' Internal helper functions support request construction, response validation,
#' fixed-list lookup retrieval, and input validation.
#'
#' @importFrom rlang .data
"_PACKAGE"