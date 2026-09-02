#!usr/bin/env Rscript

test_that("Auth does not store a password.", {
  auth <- mnmdbAuth(
    user = "guest",
    password = "abc123",
    database = "sandbox",
    connect_passwordless = TRUE
  )
  expect_null(auth@password)
})
