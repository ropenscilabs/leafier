# load in packages
library(shiny)
library(leaflet)
library(BrisbaneBikeways)
library(plyr)
library(dplyr)
library(sp)
library(rgdal)
library(rgeos)
library('testthat')

# define functions
geom.subset <- function(spgeom, top, left, bottom, right ){
  coords <- data.frame(y = c(left, right, right, left ), x =c(top, top, bottom, bottom) )
  poly <-  sp::Polygon(coords)
  polys <- sp::Polygons( list(poly) , ID =0)
  polys.spatial <- SpatialPolygons(list(polys), proj4string =  spgeom@proj4string)
  inter <- rgeos::gIntersection(spgeom, polys.spatial, byid =TRUE)
} 

#new function for simplification
## LINES
geom.simplify <- function(x, zoom.level = c(1:20), tolerance = seq(1, 0.0001, length.out=20)){
  #defenses
  expect_true(min(zoom.level)>=1)
  expect_true(max(zoom.level)<=20)
  expect_equal(length(zoom.level),length(tolerance))
  #expect_equal(length(zoom.level),20)
  expect_is(zoom.level, 'integer')
  expect_is(tolerance, c('numeric', 'integer'))
  # main processing
  tolerance = as.numeric(tolerance)
  message('simplifying objects')
  s=llply(tolerance, gSimplify, spgeom=x, .progress='text')
  message('disaggregating objects')
  d=llply(s, disaggregate, .progress='text')
  return(d)
}

# define variables
tols = seq(5e-3, 1e-10, length.out=18)

# prepare data for plotting
bikeways_original <- bikeways2015#[grepl('BRISBANE', bikeways2015$suburb),]
bikeways <- gLineMerge(bikeways_original)
bikeways_simple <- geom.simplify(bikeways, zoom.level=seq_along(tols), tol=tols)



