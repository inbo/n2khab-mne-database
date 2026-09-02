test_that("Keyring can be accessed.", {
  # this test will use some of the `keyring` package functions we depend on

  if (isFALSE(keyring::has_keyring_support())) return(FALSE)

  keyring_label <- "mnmdb_test"
  keyring_service <- "mnmdb_package_test"
  keyring_user <- "mnmdb_package_tester"
  test_password <- "test1234"
  keyring_password <- "4321tset"

  # part 1: testing with env backend

  env <- keyring::backend_env$new()
  env$set_with_value(
    service = keyring_service,
    username = keyring_user,
    password = test_password
  )
  confirm_password_env <- env$get(
    service = keyring_service,
    username = keyring_user
  )

  return(expect_equal(confirm_password_env, test_password))

  # part 2: test with the actual system backend
  # this is left here for documentation:
  # the system keyring prompts user input, which is not useful in tests.

  # skip if the keyring is not available
  keyring_available <- keyring_label %in% keyring::keyring_list()$keyring
  if (isFALSE(keyring_available)) {
    keyring::keyring_create(keyring_label, password = keyring_password)
  }

  if (keyring::keyring_is_locked(keyring_label)) {
    suppressWarnings(unlock_keyring(keyring_label, password = keyring_password))
  }

  # store a test password
  store_db_password(
    keyring_label = keyring_label,
    service = keyring_service,
    username = keyring_user,
    password = test_password
  )

  # test locking
  keyring::keyring_lock(keyring_label)
  suppressWarnings(unlock_keyring(keyring_label, password = keyring_password))

  confirm_password <- keyring::key_get(
    keyring = keyring_label,
    service = keyring_service,
    username = keyring_user
  )

  keyring::key_delete(
    keyring = keyring_label,
    service = keyring_service,
    username = keyring_user
  )

  terminate_keyring(keyring = keyring_label)

  expect_equal(confirm_password, test_password)
})
