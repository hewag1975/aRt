gdalcubes::gdalcubes_options(threads = parallel::detectCores() - 1)

# devtools::install_github("r-spatial/stars")
library(stars)
library(mapview)
library(ggplot2)
library(mdseo)
library(tmap)
library(sf)

source("R/satellite_images_funs.R")

## AOI import ----
aoi_name = "putre"
date = "2021-10-28" # Putre

# aoi_name = "karijini"
# aoi_name = "eastern_alps"
# aoi_name = "zugspitze"

fls = list.files(
    "aoi"
    , pattern = "\\.geojson"
    , full.names = TRUE
)
aoi = st_read(fls[4])

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

plot(rc_b2d)
st_get_dimension_values(rc_b2d, which = 3)[30]
plot(rc_b2d[,,,4], rgb = 4:2)


## AOI image ----
rc = aoi_explore_images(
    aoi
    , period = c("2021-10-28", "2021-10-28")
    , dx = 10
    , dt = "P1D"
)

readr::write_rds(
    rc
    , file = paste0("data/rc_", aoi_name, "_", date, ".rds")
    , compress = "gz"
)


## AOI plot ----
### tmap ----
rc = readr::read_rds(paste0("data/rc_", aoi_name, "_", date, ".rds"))
rc$SCL = NULL

dim(rc)
rc = rc[,,500:6300]

# st_get_dimension_values(rc, which = 3)
# plot(rc)

rc_tmap = rc |>
    merge() |>
    setNames(nm = "value") |>
    abind::adrop()

rc_tmap = st_apply(
    rc_tmap
    , MARGIN = 3
    , FUN = \(i) ifelse(i > 8000, 8000, i)
    # , log
)

rc_tmap = st_apply(
    rc_tmap
    , MARGIN = 3
    , scales::rescale
    , to = c(0, 255)
)

tmap_options("max.raster" = c(plot = 1e+08))

tm = tm_shape(
    rc_tmap
    , raster.downsample = TRUE
) +
    # tm_rgb(r = 3, g = 2, b = 1) +
    tm_rgb(r = 4, g = 3, b = 2) +
    tm_grid(
        labels.rot = c(0, 90)
        , labels.col = "gray20"
        , labels.size = 1.25
        , n.x = 5
        , n.y = 3
    ) +
    tm_layout(
        title = "Sentinel-2 (ESA) image\nAcquisition: 2021-10-28"
        , title.size = 1
        , title.position = c("left", "bottom")
        , title.color = "gray80"
        , main.title = "Arica - Putre, Northern Chile"
        , main.title.color = "gray20"
        , main.title.position = c("right", "top")
        , main.title.size = 2
        , frame = "white"
        , frame.lwd = 2
        , outer.bg.color = "white"
    )

# tm

tmap_save(
    tm
    , filename = paste0("img/", aoi_name, "2.jpg")
    , width = 1200
    , height = 400
    , units = "mm"
    , dpi = 300
)


### ggplot ----
rc = readr::read_rds(paste0("data/rc_", aoi_name, "_", date, ".rds"))

rc_b2d = rc |>
    stars::st_as_stars() |>
    # bands to dimension
    merge() |>
    setNames(nm = "value") |>
    stars::st_set_dimensions(which = 3, names = "band")

rc_b2d_hex = rc_b2d[,,, 4:2] |>
    stars::st_rgb(dimension = 3
                  , maxColorValue = 65000
                  , probs = c(0.01, 0.99)
                  , stretch = TRUE)

p = ggplot() +
    stars::geom_stars(data = rc_b2d_hex) +
    scale_fill_identity() +
    coord_equal() +
    theme_void()

ggsave(
    paste0("img/", aoi_name, ".jpg")
    , plot = p
    , device = "jpeg"
    , width = 900
    , height = 600
    , units = "mm"
    , dpi = "print"
)
