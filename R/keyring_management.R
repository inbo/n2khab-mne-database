#!usr/bin/env Rscript

#' terminate and clean up a given keyring
#'
#' This function will loop through all labels in a given keyring,
#' deleting all keys it encounters.
#' The purpose is to leave no passwords in store after a session ends.
#' Tip: the `seahorse` util can be used to browse the system keyring.
#'
#' @param keyring keyring label to empty (do not use `Login`!)
#'
terminate_keyring <- function(keyring_label = "mnmdb_temp") {

  require_pkgs(c("glue", "keyring"), quietly = TRUE)

  if (keyring_label == "Login") {
    stop("The `Login` keyring should not be deleted or emptied.")
  }

  # repeatedly execute
  while (keyring_label %in% keyring::keyring_list()$keyring) {
    # find all keys
    keys <- keyring::key_list(keyring = keyring_label)

    if (nrow(keys) > 0) {
      # ... and delete them
      for (k in nrow(keys)) {
        # k <- 1
        keyring::key_delete(
          service = keys[[k, "service"]],
          username = keys[[k, "username"]],
          keyring = keyring_label
        )
      }
    }

    # finally, delete the keyring
    keyring::keyring_delete(keyring = keyring_label)
  }

  return(invisible(NULL))

} # /terminate_keyring


#' Lock the keyring after a delay. (only on Linux)
#'
#' This function will launch a background process via `system`
#' to wait for a given time before locking a keyring.
#'
#' @param keyring label of the keyring to lock
#' @param delay wait time (in seconds)
#'
lock_keyring_delayed <- function(keyring_label = "mnmdb_temp", delay = 3600) {

  require_pkgs(c("glue", "keyring"), quietly = TRUE)

  # string building blocks
  l <- glue::glue('\"{keyring_label}\"')
  k <- 'keyring::keyring_'
  x <- glue::glue('({l} %in% keyring::keyring_list()$keyring)')

  # this only works on linux
  if (isFALSE(.Platform$OS.type == "unix")) {
    message(glue::glue("(keyring will not lock with delay; invoke 'keyring::keyring_lock({l})')"))
    return(invisible(NULL))
  }

  # build the core script
  cmd <- glue::glue(
    "Rscript -e 'if ({x} && isFALSE({k}is_locked({l}))) {k}lock({l})'" #  && echo 'slam!'
  )

  # background-execute the script with a delay
  system(glue::glue("sleep {delay} && {cmd} &", wait = FALSE))
  # TODO might this work better with processx?

} # /lock_keyring_delayed


#' Unlock a keyring, and schedule locking for when the R session ends.
#'
#' This function will unlock a given keyring, but immediately schedule
#' locking for later.
#'
#' @param keyring label of the keyring to lock
#' @param ... additional parameters for `keyring::keyring_unlock()`
#'
unlock_keyring <- function(keyring_label = "mnmdb_temp", ...) {

  require_pkgs(c("keyring"), quietly = TRUE)

  # unlock the keyring
  keyring::keyring_unlock(keyring = keyring_label, ...)

  # launch a process to lock it after a delay
  lock_keyring_delayed(keyring_label, delay = 3600)

  return(invisible(NULL))
} # /keyring_unlock


#' Initialize keyring to store mnmdb credentials.
#'
#' This function will initialize a keyring (unless it already exists)
#' and unlock it for temporary use.
#'
#' @param keyring label of the keyring to lock; default is "mnmdb_temp"
#'
init_keyring <- function(keyring_label = "mnmdb_temp") {

  require_pkgs(c("glue", "keyring"), quietly = TRUE)

  # note that you can create two keyrings of the same name! (shadowing)
  # avoid stacking keyrings with the same name
  if (keyring_label %in% keyring::keyring_list()$keyring) {
    stop(glue::glue("Keyring Conflict: `{keyring_label}` already exists."))
  }

  # silent, single-prompt creation
  suppressWarnings(keyring::keyring_create(keyring_label, password = ""))

  # unlock it to schedule lock
  unlock_keyring(keyring_label = keyring_label)


  # ("Jedem Ende wohnt ein Anfang inne, oder so.")
  # This will launch a scheduled process to empty the keyring upon session end.
  reg.finalizer(
    .GlobalEnv,
    function(e) terminate_keyring(keyring = keyring_label),
    onexit = TRUE
  )

  return(invisible(NULL))

} # /init_keyring


