# https://github.com/Nowosad/supercells
# https://nowosad.github.io/supercells/
# remotes::install_github("Nowosad/supercells")
library(supercells)
library(ggplot2)
library(stars)
library(sf)

ifl = "img/fichtel.jpg"
img = read_stars(ifl)
img = setNames(img, nm = "value")
st_crs(img) = 3035

sc = supercells(img, k = 5000, compactness = 10)

# plot(img, rgb = 1:3)
# plot(st_geometry(sc), add = TRUE)

rgb_to_hex = function(x){
    apply(
        x
        , MARGIN = 1
        , \(x) rgb(x[1], x[2], x[3], maxColorValue = 255)
    )
}

avg_colors = rgb_to_hex(st_drop_geometry(sc[4:6]))

jpeg(
    "img/fichtel_sc.jpg"
    , width = dim(img)[1]
    , height = dim(img)[2]
    , units = "px"
)
plot(
    st_geometry(sc)
    , border = NA
    , col = avg_colors
)
dev.off()
