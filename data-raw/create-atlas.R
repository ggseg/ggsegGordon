library(ggsegExtra)
library(ggseg)
library(ggseg3d)
library(dplyr) # for cleaning the atlas data efficiently
library(tidyr) # for cleaning the atlas data efficiently
devtools::load_all(".")
devtools::load_all("../ggsegExtra/")

# The unique name of the atlas annot, without hemisphere in filename
annot_name <- "gordon333dil"

# You might need to convert the annotation file
# convert atlas to fsaverage5
lapply(c("lh", "rh"),
       function(x){
         mri_surf2surf_rereg(subject = "fsaverage",
                             annot = annot_name,
                             hemi = x,
                             output_dir = here::here("data-raw/fsaverage5/"))
       })


# Make  3d ----
gordon_3d <- make_aparc_2_3datlas(
  annot = annot_name,
  annot_dir = here::here("data-raw/fsaverage5/"),
  output_dir = here::here("data-raw/")
)
ggseg3d(atlas  = gordon_3d)

## fix atlas ----
# you might need to do some alteration of the atlas data,
# like cleaning up the region names so they do not contain
# hemisphere information, and any unknown region should be NA
gordon_n <- gordon_3d
gordon_n <- unnest(gordon_n, ggseg_3d)
gordon_n <- mutate(gordon_n,
                    region = gsub("^L_|^R_", "", region),
                    region = ifelse(grepl("Unknown|\\?", region, ignore.case = TRUE), 
                                    NA, region),
                    atlas = "gordon_3d"
)
gordon_3d <- as_ggseg3d_atlas(gordon_n)
ggseg3d(atlas  = gordon_3d)


# Make palette ----
brain_pals <- make_palette_ggseg(gordon_3d)
usethis::use_data(brain_pals, internal = TRUE, overwrite = TRUE)
devtools::load_all(".")


# Make 2d polygon ----
gordon <- make_ggseg3d_2_ggseg(gordon_3d,
                               steps = 6:7,
                               tolerance = .5, 
                               output_dir = here::here("data-raw/"))

plot(gordon, show.legend = FALSE)

gordon %>%
  ggseg(atlas = ., show.legend = FALSE,
        colour = "black",
        mapping = aes(fill=region)) +
  scale_fill_brain("gordon", package = "ggsegGordon", na.value = "black")


usethis::use_data(gordon, gordon_3d,
                  internal = FALSE,
                  overwrite = TRUE,
                  compress="xz")


# make hex ----
atlas <- gordon

p <- ggseg(atlas = atlas,
           hemi = "left",
           view = "lateral",
           show.legend = FALSE,
           colour = "grey30",
           size = .2,
           mapping = aes(fill =  region)) +
  scale_fill_brain2(palette = atlas$palette) +
  theme_void() +
  hexSticker::theme_transparent()

lapply(c("png", "svg"), function(x){
  hexSticker::sticker(p,
                      package = "ggsegGordon",
                      filename = sprintf("man/figures/logo.%s", x),
                      s_y = 1.2,
                      s_x = 1,
                      s_width = 1.5,
                      s_height = 1.5,
                      p_family = "mono",
                      p_size = 10,
                      p_color = "grey30",
                      p_y = .6,
                      h_fill = "white",
                      h_color = "grey30"
  )
  
})

pkgdown::build_favicons(overwrite = TRUE)
