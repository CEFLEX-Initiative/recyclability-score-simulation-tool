library(officer)
library(tidyverse)
library(readxl)
library(writexl)
library(tibble)
library(splitstackshape)
library(tools)

logger <- function (text) {
  modellog <<- append(modellog, text)
}

formatmatches <- function(matches) {
  if (!nrow(matches)) {
    return("NONE")
  }
  paste(round(matches$weightpercent, 1), "wt%", matches$material)
}