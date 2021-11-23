## reference ----
# http://joshuamccrain.com/tutorials/maps/streets_tutorial.html


## setup ----
library(osmdata)
library(showtext)
library(ggplot2)
library(ggmap)


## data extractio ----
bbox = getbb("Nuremberg")

# available_tags("highway")

major = opq(bbox) |>
    add_osm_feature(
        key = "highway"
        , value = c("motorway", "primary", "motorway_link", "primary_link")
    ) |>
    osmdata_sf()

minor = opq(bbox) |>
    add_osm_feature(
        key = "highway"
        , value = c("secondary", "tertiary", "secondary_link", "tertiary_link")) |>
    osmdata_sf()

small = opq(bbox) |>
    add_osm_feature(
        key = "highway"
        , value = c("residential", "living_street", "unclassified", "service", "footway")) |>
    osmdata_sf()

river = opq(bbox) |>
    add_osm_feature(key = "waterway", value = "river") |>
    osmdata_sf()

railway = opq(bbox) |>
    add_osm_feature(key = "railway", value="rail") |>
    osmdata_sf()


## plotting ----
font_add_google(name = "Lato", family = "lato")
showtext_auto()

p = ggplot() +
    geom_sf(
        data = river$osm_lines
        , inherit.aes = FALSE
        , color = "steelblue"
        , size = 5
        , alpha = .3
    ) +
    geom_sf(
        data = railway$osm_lines
        , inherit.aes = FALSE
        , color = "black"
        , size = 1.5
        , linetype="dotdash"
        , alpha = .5
    ) +
    geom_sf(
        data = small$osm_lines
        , inherit.aes = FALSE
        , color = "#666666"
        , size = 1
        , alpha = .3
    ) +
    geom_sf(
        data = minor$osm_lines
        , inherit.aes = FALSE
        , color = "black"
        , size = 1.5
        , alpha = .5
    ) +
    geom_sf(
        data = major$osm_lines
        , inherit.aes = FALSE
        , color = "black"
        , size = 2
        , alpha = .6
    ) +
    coord_sf(
        xlim = bbox[1,]
        , ylim = bbox[2,]
        , expand = TRUE
    ) +
    theme_void() +
    theme(
        plot.title = element_text(
            size = 80
            , family = "lato"
            , face = "bold"
            , hjust = .5
        )
        , plot.subtitle = element_text(
            family = "lato"
            , size = 40
            , hjust = .5
            , margin = margin(2, 0, 5, 0)
        )
    ) +
    labs(title = "Nürnberg"
         , subtitle = paste0(
             round(mean(bbox[2,]), 3), "°N / ",
             round(mean(bbox[1,]), 3), "°E"
         )
    )

ggsave(
    "img/nuernberg.pdf"
    , plot = p
    , width = 600
    , height = 600
    , units = "mm"
    , dpi = "print"
    , bg = "white"
)

