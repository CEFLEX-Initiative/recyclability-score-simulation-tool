# This file contains 'getter' routines, which extract certain outcomes from the data frame containing
# all assessed structures.
# These routines should not have more logic than to prevent undefined outcomes or R execution errors, 
# i.e., deal with missing or malformed values and create sums, averages etc. 
# They should not carry any other 'inner logic'



count_green_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }
    nrow(filter(design, green == TRUE))
}

count_yellow_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }
    nrow(filter(design, yellow == TRUE))
}

count_red_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }
    nrow(filter(design, red == TRUE))
}

count_removed_elements <- function(sys, table, design, componentsonly = FALSE) {
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }
    if (componentsonly) {
        nrow(filter(design, removed == TRUE & type == "Component"))
    } else {
        nrow(filter(design, removed == TRUE))
    }
}

count_tests_needed <- function(sys, tablefile, design) {
    # if no DfR table can be found for the design
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }

    # what needs to be tested are the design elements that are not in green, nor in yellow nor in red
    nrow(filter(design, !red & !yellow & !green))
}

list_green_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return("N/A, no DfR table found")
    }

    formatmatches(filter(design, green == TRUE))
}

list_yellow_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return("N/A, no DfR table found")
    }

    formatmatches(filter(design, yellow == TRUE))
}

list_red_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return("N/A, no DfR table found")
    }

    formatmatches(filter(design, red == TRUE))
}

list_removed_elements <- function(sys, design, componentsonly = FALSE) {
    if (!DfR_table_available(tablefile, design)) {
        return("N/A, no DfR table found")
    }
    if (componentsonly) {
        formatmatches(filter(design, removed == TRUE & type == "Component"))
    } else {
        formatmatches(filter(design, removed == TRUE))
    }
}

list_tests_needed <- function(tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return("N/A, no DfR table found")
    }
    formatmatches(filter(design, !red & !yellow & !green))
}

weight_green_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }
    green_elements <- filter(design, green == TRUE)
    sum(green_elements$weightpercent)
}

weight_yellow_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }
    yellow_elements <- filter(design, yellow == TRUE)
    sum(yellow_elements$weightpercent)
}

weight_red_elements <- function(sys, tablefile, design) {
    if (!DfR_table_available(tablefile, design)) {
        return(NA)
    }
    red_elements <- filter(design, red == TRUE)
    sum(red_elements$weightpercent)
}

weight_removed_elements <- function(design, componentsonly = FALSE) {
    if (componentsonly) {
        sum(design$weightpercent[design$removed == TRUE & design$type == "Component"])
    } else {
        sum(design$weightpercent[design$removed == TRUE])
    }
}

weight_total <- function(design) {
    sum(constituent$weight * constituent$materialshare / 100)
}


model_uses_DfR <- function(sys, tablefile, design) {
    pull(scoringsystems[scoringsystems$ID == sys, "usesdfr"])
}


# Describes whether a DfR table exists that this design can be checked against (i.e., a DfR table for the material)
DfR_table_available <- function(tablefile, design) {
    design[1, ]$hasdfr
}

dominantmaterial <- function(design) {
    pull(design[which.max(design$weightpercent), "material"])
}

assigned_stream <- function(sys, tablefile, design) {
    design[1, ]$stream
}

dominantmaterial_percent <- function(design, skipremoved = FALSE) {
    dominantmaterialcontent <- filter(design, dominantmaterial == TRUE)
    if (skipremoved) {
        dominantmaterialcontent <- filter(dominantmaterialcontent, removed == FALSE)
    }

    round(sum(dominantmaterialcontent$weightpercent), 1)
}
