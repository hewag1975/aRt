## references ----
# osm extraction:
# - https://docs.ropensci.org/osmextract/
#
# map creation:
# - https://ggplot2tutor.com/tutorials/streetmaps
# - http://joshuamccrain.com/tutorials/maps/streets_tutorial.html
# - https://github.com/lina2497/Giftmap
#
# scaling and dimensions:
# - https://www.christophenicault.com/post/understand_size_dimension_ggplot2/
# - https://www.tidyverse.org/blog/2020/08/taking-control-of-plot-scaling/

## setup ----
library(osmdata)
library(showtext)
library(ggplot2)
library(ggmap)


## data extraction ----
bbox = getbb("Nuremberg")

# bbox = sf::st_bbox(
#     c(xmin = 11.01
#       , xmax = 11.05
#       , ymax = 49.52
#       , ymin = 49.54
#     )
# )

available_features()
available_tags("highway")

# tg = "water"
# tg = "waterway"
# tg = "natural"
# tg = "landuse"
# tg = "boundary"
#
# feat = opq(bbox) |>
#     add_osm_feature(
#         key = tg
#         , value = available_tags(tg)
#     ) |>
#     osmdata_sf()
#
# mapview::mapview(feat$osm_lines)
# mapview::mapview(feat$osm_polygons)

major = opq(bbox) |>
    add_osm_feature(
        key = "highway"
        , value = c(
            "motorway"
            , "motorway_link"
            , "motorway_junction"
            , "primary"
            , "primary_link"
            , "trunk"
        )
    ) |>
    osmdata_sf()

minor = opq(bbox) |>
    add_osm_feature(
        key = "highway"
        , value = c(
            "secondary"
            , "tertiary"
            , "secondary_link"
            , "tertiary_link"
        )
    ) |>
    osmdata_sf()

small = opq(bbox) |>
    add_osm_feature(
        key = "highway"
        , value = c(
            "residential"
            , "living_street"
            , "unclassified"
            , "service"
            , "footway"
            , "corridor"
            , "bridleway"
        )
    ) |>
    osmdata_sf()

river = opq(bbox) |>
    add_osm_feature(
        key = "waterway"
        , value = "river"
    ) |>
    osmdata_sf()

railway = opq(bbox) |>
    add_osm_feature(key = "railway", value="rail") |>
    osmdata_sf()


## plotting ----
font_add_google(name = "Lato", family = "lato")
showtext_opts(dpi = 300)
showtext_auto(enable = TRUE)

# bg = "white"
# col = "black"

bg = "black"
col = "white"

p = ggplot() +
    geom_sf(
        data = river$osm_lines
        , inherit.aes = FALSE
        , color = "steelblue"
        , size = 0.8
        , alpha = 0.6
    ) +
    geom_sf(
        data = railway$osm_lines
        , inherit.aes = FALSE
        , color = col
        , size = 0.5
        , linetype = "dotdash"
        , alpha = 0.8
    ) +
    geom_sf(
        data = small$osm_lines
        , inherit.aes = FALSE
        , color = col
        , size = 0.4
        , alpha = 0.5
    ) +
    geom_sf(
        data = minor$osm_lines
        , inherit.aes = FALSE
        , color = col
        , size = 0.4
        , alpha = 0.6
    ) +
    geom_sf(
        data = major$osm_lines
        , inherit.aes = FALSE
        , color = col
        , size = 0.4
        , alpha = 0.8
    ) +
    coord_sf(
        xlim = bbox[1,]
        , ylim = bbox[2,]
        , expand = TRUE
    ) +
    theme_void() +
    theme(
        plot.title = element_text(
            family = "lato"
            , size = 40
            , face = "bold"
            , hjust = .5
            , colour = col
            , margin = margin(10, r = 0, b = 0, l = 0, unit = "mm")
        )
        , plot.subtitle = element_text(
            family = "lato"
            , size = 24
            , hjust = .5
            , colour = col
        )
        , plot.caption = element_text(
            family = "lato"
            , size = 16
            , colour = col
            , margin = margin(0, r = 0, b = 10, l = 0, unit = "mm")
        )
    ) +
    labs(
        title = "Nürnberg"
        , subtitle = paste0(
            round(mean(bbox[2,]), 3), "°N / ",
            round(mean(bbox[1,]), 3), "°E"
        )
        , caption = "© OpenStreetMap contributors"
    )

ggsave(
    paste0("img/nuernberg_streets_", bg, ".jpg")
    , device = "jpeg"
    # , plot = p
    , width = 600
    , height = 600
    , units = "mm"
    , dpi = 300
    , bg = bg
)

# ggsave(
#     paste0("img/nuernberg_", bg, ".svg")
#     , device = "svg"
#     # , plot = p
#     , width = 600
#     , height = 600
#     , units = "mm"
#     , dpi = "print"
#     , bg = bg
# )

# pngfile = paste0("img/nuernberg_", bg, ".png")
# ragg::agg_png(
#     pngfile
#     , background = bg
#     , width = 60
#     , height = 60
#     , units = "cm"
#     , res = 300
#     , scaling = 1
# )
# plot(p)
# invisible(
#     dev.off()
# )

