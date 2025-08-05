sanitize <- function(sampleset) {
  # harmonise the different types of PE and different orientations of films made from PE, PP, PA and PET into the base material
  sampleset <- mutate(sampleset, material = str_replace_all(
    material,
    c(
      "MDOPE" = "PE", "BOPE" = "PE", "LLDPE" = "PE", "HDPE" = "PE", "LDPE" = "PE",
      "BOPP" = "PP", "OPP voided" = "PP", "OPP" = "PP", "CPP" = "PP",
      "OPA" = "PA6 laminated", "CPA" = "PA6 laminated", "BOPA" = "PA6 laminated",
      "BOPET" = "PET", "OPET" = "PET"
    )
  ))

  # calculate weight from thickness, density and area, if not already defined
  sampleset <- mutate(sampleset, weight = ifelse(is.na(weight) & !is.na(thickness) & !is.na(density) & !is.na(area), thickness * density * area / 100, weight))

  # calculate thickness from weight, density and area, if not already defined
  sampleset <- mutate(sampleset, thickness = ifelse(is.na(thickness) & !is.na(weight) & !is.na(density) & !is.na(area), weight / density / area * 100, thickness))

  # Multiply weight with area and materialshare to get the 'real' weight of a constituent
  sampleset <- mutate(sampleset, weightmult = weight * area / 100 * materialshare / 100)

  # aggregate thicknesses and weights if a constituent material appears multiple times in a design (e.g., multiple layers of PE)
  sampleset <- sampleset %>%
    group_by(ID) %>%
    mutate(totalthick = sum(thickness), totalweight = sum(weightmult)) %>%
    ungroup()

  # convert absolute (aggregated) constituent weights to weight percentages
  sampleset <- mutate(sampleset, weightpercent = weightmult / totalweight * 100)

  sampleset
}



is_dominantmaterial <- function(constituent, stream) {
  if (constituent$material == stream) {
    return(TRUE)
  }


  # TODO: this is a tweak to also count the MAH in a PE-g-MAH or PP-g-MAH tie layer
  if (stream == "PE" & constituent$material == "MAH") {
    return(TRUE)
  }

  FALSE
}


needstest <- function(sys, tablefile, design) {
  #  no DfR table found for the design means no testing can be done
  if (!DfR_table_available(tablefile, design)) {
    return(FALSE)
  }

  reds <- count_red_elements(sys, tablefile, design)
  tests <- count_tests_needed(sys, tablefile, design)

  # if one red element, the outcome must be 'not recyclable', no test needed
  if (is.na(reds) | reds > 0) {
    return(FALSE)
  }

  if (tests > 0) {
    return(TRUE)
  }
  return(FALSE)
}

assess_removed <- function(tablefile, constituent, stream, list) {
  mat <- constituent$material
  if (length(list[list$material == mat, "material"]) == 0) {
    return(FALSE)
  }
  return(TRUE)
}

assess_dfr <- function(tablefile, constituent, stream, list) {
  mat <- constituent$material

  # the material is not listed at all in the table
  if (length(list[list$material == mat, "material"]) == 0) {
    return(FALSE)
  }

  lowerthreshold <- list[list$material == mat, "lowerthreshold"]
  upperthreshold <- list[list$material == mat, "upperthreshold"]

  weight <- constituent$weightpercent


  ### No thresholds at all, but material is mentioned in the list
  if (is.na(lowerthreshold[1]) & is.na(upperthreshold[1])) {
    return(FALSE)
  }

  ###  just an upper threshold; check if below
  if (is.na(lowerthreshold[1]) & !is.na(upperthreshold[1]) & weight <= upperthreshold[1]) {
    return(TRUE)
  }

  ###  just a lower threshold; check if above
  if (!is.na(lowerthreshold[1]) & is.na(upperthreshold[1]) & weight > lowerthreshold[1]) {
    return(TRUE)
  }

  ### two thresholds; check whether in between
  if (weight > lowerthreshold[1] & weight <= upperthreshold[1]) {
    return(TRUE)
  }

  ### no match, i.e., the list (greenlist, yellowlist, redlist) does not contain the material
  ### (means testing will be needed but this is determined elsewhere)
  return(FALSE)
}

# TODO: will in the future need to be able to do e.g., colored vs. natural
find_matching_stream <- function(sys, tablefile, design) {
  dom <- pull(design[1, "dominantmaterial"])

  # TODO: this assumes that there are no differentiated streams for these PE types
  if (dom == "LDPE" | dom == "HDPE" | dom == "LLDPE" | dom == "VLDPE") {
    dom <- "PE"
  }

  if (!assess_hasDfR(tablefile, dom)) {
    return(NA)
  }

  stream <- dom

  ## TODO: hardcoded mixedPO detection
  if (stream == "PE" & sum(sample$weightpercent[sample$material == "PP"]) > 10 & grepl("CEFLEX", dfrtable)) {
    stream <- "mixedPO"
  }


  stream
}

assess_design <- function(sys, tablefile, design, log) {
  dominant <- dominantmaterial(design)
  design <- mutate(design, dominantmaterial = dominant)

  design <- mutate(design, hasdfr = assess_hasDfR(tablefile, dominant))

  stream <- find_matching_stream(sys, tablefile, design)

  # combine identical materials at this stage, i.e. two identical layers should count jointly against the thresholds (weight & number of yellows)
  design <- aggregate(weightpercent ~ material + dominantmaterial + ID + Name + Group + Source + type + hasdfr, design, sum)


  if (is.na(stream)) {
    design %>%
      rowwise() %>%
      mutate(red = NA, yellow = NA, green = NA, dominantmaterial = NA)
  } else {
    greenlist <- filter(dfrtablescontents, dfrtablescontents$sourcefile == tablefile & dfrtablescontents$table == stream & dfrtablescontents$column == "GREEN")
    yellowlist <- filter(dfrtablescontents, dfrtablescontents$sourcefile == tablefile & dfrtablescontents$table == stream & dfrtablescontents$column == "YELLOW")
    redlist <- filter(dfrtablescontents, dfrtablescontents$sourcefile == tablefile & dfrtablescontents$table == stream & dfrtablescontents$column == "RED")

    removedlist <- filter(dfrtablescontents, dfrtablescontents$sourcefile == tablefile & dfrtablescontents$table == stream & dfrtablescontents$removed == TRUE)

    design %>%
      rowwise() %>%
      mutate(
        red = assess_dfr(tablefile, .data, stream, redlist),
        yellow = assess_dfr(tablefile, .data, stream, yellowlist),
        green = assess_dfr(tablefile, .data, stream, greenlist),
        removed = assess_removed(tablefile, .data, stream, removedlist),
        dominantmaterial = is_dominantmaterial(.data, stream), stream = stream
      )
  }
}


assess_hasDfR <- function(tablefile, dom) {
  if (dom %in% recycling_streams[recycling_streams$sourcefile == tablefile, "stream"]) {
    return(TRUE)
  }
  return(FALSE)
}
