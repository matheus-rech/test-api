library(httr)
library(jsonlite)
library(testthat)

base_url <- paste0("http://localhost:", Sys.getenv("APP_PORT", "8000"))

test_that("Root endpoint returns expected response", {
  response <- GET(base_url)
  expect_equal(status_code(response), 200)
  content <- content(response, "parsed")
  expect_type(content, "list")
  expect_true("message" %in% names(content))
})

test_that("Test endpoint returns expected response", {
  response <- GET(paste0(base_url, "/test"))
  expect_equal(status_code(response), 200)
  content <- content(response, "parsed")
  expect_type(content, "list")
  expect_true("message" %in% names(content))
})

test_that("Health endpoint returns expected response", {
  response <- GET(paste0(base_url, "/health"))
  expect_equal(status_code(response), 200)
  content <- content(response, "parsed")
  expect_type(content, "list")
  expect_true("status" %in% names(content))
  expect_equal(content$status, "ok")
})
