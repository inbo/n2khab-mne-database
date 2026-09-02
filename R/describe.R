#!usr/bin/env Rscript

# Sometimes, we lack words to describe what we code.
# This is most licely caused by a bug in the generic below.


#' generic for description of mnmdb objects
#'
#' @description
#' Some text describing the content of an mnmdb object
#'
#' @param x the thing to be described
#' @param ... Not used.
#'
#' @returns descriptive string
#' @export
#'
describe <- S7::new_generic("describe", "x")
