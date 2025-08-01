printf <- function(...) cat(sprintf(...))

format_structure <- function(design) {
    ret <- ""

    for (layer in unique(design$sequence)) {
        lay <- filter(design, sequence == layer)
        laytext <- paste(unique(lay$material), collapse = " + ")
        if (layer == 1) {
            ret <- paste(ret, laytext, sep = "")
        } else {
            ret <- paste(ret, laytext, sep = " // ")
        }
    }

    ret
}


vecprintf <- function(buffer, fmt, ...) {
    append(buffer, sprintf(fmt, ...))
}

output_text <- function(resultset) {
    output <- c()

    output <- vecprintf(output, "---------------------------------------------------------------------------------")
    output <- vecprintf(output, "Assessment results for ID \"%s\" (%s) according to DfR table \"%s\" and scoring system \"%s\"", resultset$ID, resultset$`Packaging name`, resultset$`DfR table`, resultset$`Scoring system`)
    output <- vecprintf(output, "---------------------------------------------------------------------------------")


    samp <- filter(package_designs, ID == resultset$ID)

    output <- vecprintf(output, "Packaging structure: %s", format_structure(samp))

    output <- vecprintf(output, "Dominant material: %s", resultset$Dominantmaterial)
    output <- vecprintf(output, "Assigned to stream / predominant material / DfR table: %s", resultset$Stream)
    output <- vecprintf(output, "Predominant material content: %s wt%%", resultset$Dominantmaterialshare)
    output <- vecprintf(output, "")

    output <- vecprintf(output, "Components / constituents in green: %s", resultset$Greens)

    output <- vecprintf(output, "Components / constituents in yellow: %s", resultset$Yellows)
    output <- vecprintf(output, "Components / constituents in red: %s", resultset$Reds)

    output <- vecprintf(output, "Components / constituents not listed: %s", resultset$`Required tests`)

    
    if (str_length(resultset$`Removed constituents/components`) > 0) {
        output <- vecprintf(output, "Components / constituents removed and not recycled: %s", resultset$`Removed constituents/components`)
    }

    if (str_length(resultset$`Removed components`) > 0) {
        output <- vecprintf(output, "Thereof components removed and not recycled: %s", resultset$`Removed components`)
    }


    

    # TODO: this can be confusing in the output, depending on the text logged, as it will not appear in order of logging anymore but in alphabetical order
    ml <- paste(sort(unique(modellog)), collapse = "")

    output <- vecprintf(output, "")
    output <- vecprintf(output, "%s", ml)

    output <- vecprintf(output, "")
    output <- vecprintf(output, "PPWR score: %s", resultset$Score)
    output <- vecprintf(output, "Grade: %s", resultset$`Grade`)
    if (resultset$`Needs testing`) {
        output <- vecprintf(output, "Tests required to assess: %s", resultset$`Required tests`)
    }

    output <- vecprintf(output, "---------------------------------------------------------------------------------")

    return(output)
}
