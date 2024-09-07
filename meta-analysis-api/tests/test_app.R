# Test file for app.R
library(testthat)
library(plumber)

source("app.R")

test_that("API endpoints are defined", {
  pr <- plumb("app.R")
  expect_true("POST /upload" %in% pr$routes$path)
  expect_true("POST /analyze" %in% pr$routes$path)
  expect_true("GET /results" %in% pr$routes$path)
  expect_true("GET /visualize" %in% pr$routes$path)
  expect_true("POST /sensitivity" %in% pr$routes$path)
  expect_true("GET /health" %in% pr$routes$path)
})