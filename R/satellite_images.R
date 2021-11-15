gdalcubes::gdalcubes_options(threads = parallel::detectCores() - 1)

# devtools::install_github("r-spatial/stars")
library(stars)
library(mapedit)
library(mapview)
library(ggplot2)
library(mdseo)
library(tmap)
library(sf)

source("R/satellite_images_funs.R")

## AOI definition and preparation ----
aoi_name = "karijini"
aoi_name = "eastern_alps"
aoi_name = "zugspitze"
# aoi = mapedit::editMap()
# st_write(
#     aoi
#     , dsn = paste0("aoi/aoi_", aoi_name, ".geojson")
#     , delete_dsn = TRUE
# )

fls = list.files("aoi", pattern = "\\.geojson", full.names = TRUE)
aoi = st_read(fls[5])
utm = st_centroid(aoi) |>
    st_coordinates() |>
    lonlat2UTM()

aoi = prepAOI(aoi, crs_cube = utm)


## AOI assessment ----
rc = aoi_explore_images(
    aoi
    , period = c("2020-01-01", "2020-12-31")
    , dx = 50
    , dt = "P4D"
)

rc = cleanCube(rc, which = 3)
st_get_dimension_values(rc, which = 3)

readr::write_rds(
    rc
    , file = paste0("data/rc_", aoi_name, "_pre.rds")
    , compress = "gz"
)

rc = readr::read_rds(paste0("data/rc_", aoi_name, "_pre.rds"))

rc_b2d = rc |>
    stars::st_as_stars() |>
    # bands to dimension
    merge() |>
    setNames(nm = "value") |>
    stars::st_set_dimensions(which = 4, names = "band")

# plot(rc_b2d)
plot(rc_b2d[,,,6], rgb = 4:2)
plot(rc_b2d[,,,27], rgb = 3:1)


## AOI image ----
rc = aoi_explore_images(
    aoi
    , period = c("2020-01-01", "2020-12-31")
    , dx = 10
    , dt = "P1D"
)

readr::write_rds(
    rc
    , file = paste0("data/rc_", aoi_name, ".rds")
    , compress = "gz"
)

rc = readr::read_rds(paste0("data/rc_", aoi_name, ".rds"))

rc_b2d = rc |>
    stars::st_as_stars() |>
    # bands to dimension
    merge() |>
    setNames(nm = "value") |>
    stars::st_set_dimensions(which = 3, names = "band")

# true/false color image
# plot(rc_b2d, rgb = 4:2)

rc_b2d_hex = rc_b2d[,,, 4:2] |>
    stars::st_rgb(dimension = 3
                  , maxColorValue = 65000
                  , probs = c(0.01, 0.99)
                  , stretch = TRUE)

# rc_b2d_hex |>
#     tm_shape() +
#     tm_raster()
#
# rc[,,, 1] |>
#     tm_shape() +
#     tm_rgb(r = 4, g = 3, b = 2)

p = ggplot() +
    stars::geom_stars(data = rc_b2d_hex) +
    scale_fill_identity() +
    coord_equal() +
    theme_void()

ggsave(paste0("img/", aoi_name, ".jpg")
       , plot = p
       , device = "jpeg"
       , width = 600
       , height = 400
       , units = "mm"
       , dpi = "print")




