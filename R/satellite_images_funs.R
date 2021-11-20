lonlat2UTM = \(lonlat) {
    utm = (floor((lonlat[1] + 180) / 6) %% 60) + 1
    if(lonlat[2] > 0) {
        utm + 32600
    } else{
        utm + 32700
    }
}

aoi_explore_images = \(
    aoi
    , period
    , dx
    , dt
){
    rc = defineCube(
        aoi
        , cube_opts = cubeOpts(
            dx = dx
            , dt = dt
            , period = period
        )
    ) |>
        listCollections() |>
        rasterCube() |>
        st_as_stars()

    setNames(rc, nm = c("B02", "B03", "B04", "B08", "SCL"))
}
