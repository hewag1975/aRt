library(mapview)
library(mdseo)
library(sf)

source("R/satellite_images_funs.R")

## AOI definition and preparation ----
aoi_name = "putre"
# aoi_name = "karijini"
# aoi_name = "eastern_alps"
# aoi_name = "zugspitze"

# aoi = mapedit::editMap()
# st_write(
#     aoi
#     , dsn = paste0("aoi/aoi_", aoi_name, ".geojson")
#     , delete_dsn = TRUE
# )

aoi = st_read(paste0("aoi/aoi_", aoi_name, ".geojson"))
utm = st_centroid(aoi) |>
    st_coordinates() |>
    lonlat2UTM()

aoi = prepAOI(aoi, crs_cube = utm)
readr::write_rds(
    aoi
    , file = paste0("aoi/aoi_", aoi_name, ".rds")
    , compress = "gz"
)

