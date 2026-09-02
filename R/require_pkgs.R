#!usr/bin/env Rscript

#' Check availability of required packages
#'
#' Takes a vector of package names and passes each name to
#' \code{\link[base:ns-load]{requireNamespace()}};
#' if package(s) are missing, returns an error message providing the basic
#' \code{install.packages()} command to install them.
#'
#' @param pkgs A character vector of package names.
#' @param ... more parameters for base::requireNamespace
#'        (e.g. `quietly` for non-verbose check for requirements)
#'
#' @examples
#' \dontrun{
#'   require_pkgs(c("a", "base", "b", "magrittr"))
#'   # not_attached <- any(devtools::loaded_packages() == "magrittr") == FALSE
#' }
#'
#' @keywords internal
require_pkgs <- function(pkgs, ...) {

  # verify user input
  assertthat::assert_that(is.character(pkgs))

  the_loading_function <- \(pkg) requireNamespace(
    pkg,
    ...
  )

  # check availability of the package
  available <- vapply(pkgs, the_loading_function, FUN.VALUE = TRUE)

  # feedback availability
  if (!all(available)) {
    multiple <- sum(!available) > 1
    stop(ifelse(multiple, "Multiple", "A"),
         " package",
         ifelse(multiple, "s", ""),
         " needed for this function ",
         ifelse(multiple, "are", "is"),
         " missing.\nPlease install as follows: install.packages(",
         deparse(pkgs[!available]),
         ")",
         call. = FALSE
    )
  }

} # /require_pkgs
