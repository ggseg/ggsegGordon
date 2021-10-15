library(ggseg)
library(ggseg3d)
library(ggplot2)

# ggseg ----
context("test-palettes")
test_that("check new palettes work", {
  expect_equal(length(brain_pal("gordon", package = "ggsegGordon")), 332)

  expect_error(brain_pal("gordon"), "not a valid")

  expect_true(all(brain_regions(gordon) %in% names(brain_pal("gordon", package = "ggsegGordon"))))
})

context("test-ggseg-atlas")
test_that("atlases are true ggseg atlases", {

  expect_true(is_brain_atlas(gordon))

})

context("test-ggseg")
test_that("Check that polygon atlases are working", {
  expect_is(ggseg(atlas = gordon),c("gg","ggplot"))

  expect_is(ggseg(atlas = gordon, mapping = aes(fill = region)),
            c("gg","ggplot"))

  expect_is(ggseg(atlas = gordon, mapping = aes(fill = region)) +
              scale_fill_brain("gordon", package = "ggsegGordon"),
            c("gg","ggplot"))

  expect_is(ggseg(atlas = gordon, mapping = aes(fill = region)) +
              scale_fill_brain("gordon", package = "ggsegGordon"),
            c("gg","ggplot"))

  expect_is(ggseg(atlas = gordon, mapping=aes(fill=region), adapt_scales = FALSE ),c("gg","ggplot"))

})


# ggseg3d ----
context("test-ggseg3d")
test_that("Check that mesh atlases are working", {
  expect_is(
    ggseg3d(atlas=gordon_3d),
    c("plotly", "htmlwidget")
  )
})



context("test-ggseg3d-atlas")
test_that("atlases are true ggseg3d atlases", {

  expect_true(is_ggseg3d_atlas(gordon_3d))

})
