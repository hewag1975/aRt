library(rayshader)
library(stars)
library(mapview)
library(mdseo)
library(tmap)
library(sf)

# source("R/satellite_images_funs.R")

## AOI import ----
aoi_name = "putre"
aoi = readr::read_rds(paste0("aoi/aoi_", aoi_name, ".rds"))


## Elevation data ----
dem = mdseo::aoiDEM(aoi, zoom = 10)
dem = as(dem, Class = "Raster")

raster_to_matrix(dem) |>
    height_shade() |>
    plot_map()

options("cores" = parallel::detectCores() - 1)
raster_to_matrix(dem) |>
    ray_shade(
        anglebreaks = seq(80, 90, by = 0.5)
        , zscale = 1.25
        , multicore = TRUE
    ) |>
    plot_map()


