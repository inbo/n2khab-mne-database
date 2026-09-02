#!usr/bin/env Rscript

is.scalar.na <- function(checkvar) {
  return(
    is.atomic(checkvar) &&
    (length(checkvar) == 1) &&
    is.na(checkvar)
  )
}

