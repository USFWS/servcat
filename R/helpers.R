## package-level globals ----

.pkgglobalenv <- new.env(parent = emptyenv())

assign(
  "servcat_public_api",
  "https://iris.fws.gov/APPS/ServCatServices/servcat/v4/rest",
  envir = .pkgglobalenv
)

assign(
  "servcat_secure_api",
  "https://iris.fws.gov/APPS/ServCatServices/servcat-secure/v4/rest",
  envir = .pkgglobalenv
)

assign(
  "servcat_reference_url",
  "https://iris.fws.gov/APPS/ServCat/Reference/Profile",
  envir = .pkgglobalenv
)

utils::globalVariables(c(
  "public_refs",
  "internal_refs",
  "found",
  "key",
  "ref_group_code",
  "searchTerm",
  "userSort",
  "resourceId",
  "description",
  "fileName",
  "fileSize",
  "extension",
  "mimeType",
  "downloadLink",
  "fileSize_kb",
  "mail",
  "referenceId",
  "title"
))

#' Get the base URL for the ServCat API
#'
#' @param secure Logical. Use the secure ServCat API?
#'
#' @returns A length-1 character vector
#' @keywords internal
base_url <- function(secure = FALSE) {
  if (!is.logical(secure) || length(secure) != 1 || is.na(secure)) {
    cli::cli_abort("{.arg secure} must be `TRUE` or `FALSE`.")
  }

  dplyr::case_when(
    secure ~ get("servcat_secure_api", envir = .pkgglobalenv),
    !secure ~ get("servcat_public_api", envir = .pkgglobalenv)
  )
}

#' Retrieve secure ServCat API key
#'
#' @param env_var Environment variable name
#'
#' @returns A length-1 character vector
#' @keywords internal
api_key <- function(env_var = "SERVCAT_API_KEY") {
  key <- Sys.getenv(env_var, unset = "")

  if (identical(key, "")) {
    cli::cli_abort(
      "Environment variable {.val {env_var}} is not set."
    )
  }

  key
}

#' Build a ServCat request
#'
#' @param secure Logical. Use the secure API?
#' @param suppress_errors Logical. Suppress HTTP errors so they can be handled
#'   by `servcat_validate_response()`.
#' @param api_key Optional API key. If omitted for secure requests, the value is
#'   read from `SERVCAT_API_KEY`.
#'
#' @returns An `httr2_request` object.
#' @keywords internal
servcat_request <- function(
  secure = FALSE,
  suppress_errors = TRUE,
  api_key = NULL
) {
  req <- httr2::request(base_url(secure = secure)) |>
    httr2::req_user_agent("servcat")

  if (secure) {
    api_key <- rlang::`%||%`(api_key, api_key())
    req <- req |>
      httr2::req_headers(`X-API-KEY` = api_key)
  }

  if (suppress_errors) {
    req <- req |>
      httr2::req_error(is_error = \(resp) FALSE)
  }

  req
}

#' Validate a ServCat reference ID
#'
#' @param reference_id ServCat reference ID or IDs
#' @param multiple_ok Logical. Are multiple IDs allowed?
#' @param arg Used to generate helpful error messages
#' @param call Calling environment
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_reference_id <- function(
  reference_id,
  multiple_ok = FALSE,
  arg = rlang::caller_arg(reference_id),
  call = rlang::caller_env()
) {
  if (!multiple_ok && length(reference_id) > 1) {
    cli::cli_abort(
      "You may only provide one reference ID at a time.",
      call = call
    )
  }

  if (!is.numeric(reference_id)) {
    cli::cli_abort(
      "{.arg {arg}} is invalid. Reference IDs must be numeric.",
      call = call
    )
  }

  if (!all(reference_id == floor(reference_id))) {
    cli::cli_abort(
      "{.arg {arg}} is invalid. Reference IDs must be whole number(s).",
      call = call
    )
  }

  invisible(NULL)
}

#' Validate a TRUE/FALSE argument
#'
#' @param x Value to validate
#' @param arg Used to generate helpful error messages
#' @param call Calling environment
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_flag <- function(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be logical (`TRUE` or `FALSE`).",
      call = call
    )
  }

  invisible(NULL)
}

#' Validate a ServCat API response
#'
#' @param resp An `httr2_response`
#' @param nice_msg_400 Optional message for 4xx errors
#' @param nice_msg_500 Optional message for 5xx errors
#' @param call Calling environment
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_response <- function(
  resp,
  nice_msg_400,
  nice_msg_500,
  call = rlang::caller_env()
) {
  if (httr2::resp_is_error(resp)) {
    if (missing(nice_msg_400)) {
      nice_msg_400 <- c(
        "i" = "There is a problem with the API request. Check reference IDs, search terms, and filters for typos.",
        "i" = "If you are using the secure API, verify that your API key is set and valid."
      )
    }

    if (missing(nice_msg_500)) {
      nice_msg_500 <- c(
        "i" = "The ServCat service returned a server error. Try again later or confirm the endpoint is available."
      )
    }

    status_num <- httr2::resp_status(resp)
    nice_msg <- if (floor(status_num / 100) == 5) nice_msg_500 else nice_msg_400
    http_err <- glue::glue("HTTP {status_num}: {httr2::resp_status_desc(resp)}")

    cli::cli_abort(c(http_err, nice_msg), call = call)
  }

  invisible(NULL)
}

#' Collapse reference IDs for the Profile endpoint
#'
#' @param reference_ids Numeric vector of reference IDs
#'
#' @returns A length-1 character vector
#' @keywords internal
collapse_reference_ids <- function(reference_ids) {
  paste(unique(reference_ids), collapse = ",")
}

#' Chunk reference IDs for Profile requests
#'
#' @param reference_ids Numeric vector of reference IDs
#' @param chunk_size Maximum number of IDs per request
#'
#' @returns A list of numeric vectors
#' @keywords internal
chunk_reference_ids <- function(reference_ids, chunk_size = 25) {
  split(reference_ids, ceiling(seq_along(reference_ids) / chunk_size))
}

#' Convert nested lists in a profile to vectors
#'
#' @param parent_list A ServCat profile record
#' @param child_list_names Element names to simplify
#'
#' @returns A modified list
#' @keywords internal
lists_to_vectors <- function(parent_list, child_list_names) {
  for (child_list in child_list_names) {
    if (!is.null(parent_list[[child_list]])) {
      parent_list[[child_list]] <- unlist(parent_list[[child_list]], use.names = FALSE)
    }
  }

  parent_list
}

#' Convert nested lists in a profile to tibbles
#'
#' @param parent_list A ServCat profile record
#' @param child_list_names Element names to convert
#'
#' @returns A modified list
#' @keywords internal
lists_to_tibbles <- function(parent_list, child_list_names) {
  for (child_list in child_list_names) {
    if (!is.null(parent_list[[child_list]])) {
      parent_list[[child_list]] <- dplyr::bind_rows(parent_list[[child_list]])
    }
  }

  parent_list
}

#' Retrieve a batch of ServCat reference profiles
#'
#' @param reference_ids Numeric vector of up to 25 ServCat reference IDs
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key
#'
#' @returns A named list of ServCat profile records
#' @keywords internal
get_reference_profiles_batch <- function(
  reference_ids,
  secure = FALSE,
  api_key = NULL
) {
  req <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Profile") |>
    httr2::req_url_query(q = collapse_reference_ids(reference_ids)) |>
    httr2::req_perform()

  validate_response(req)

  response <- httr2::resp_body_json(req, simplifyVector = FALSE)

  to_vectors <- c("keywords", "subjects")
  to_tibbles <- c("taxa", "units", "contentProducerUnits", "filesAndLinks")

  response <- lapply(response, function(ref) {
    ref <- lists_to_vectors(ref, to_vectors)
    ref <- lists_to_tibbles(ref, to_tibbles)

    if (!is.null(ref$bibliography)) {
      names(ref$bibliography) <- stringr::str_replace(
        names(ref$bibliography),
        pattern = "^abstract$",
        replacement = "description"
      )
    }

    ref
  })

  ids <- vapply(response, function(ref) rlang::`%||%`(ref$referenceId, NA_real_), numeric(1))
  names(response) <- as.character(ids)

  response
}
