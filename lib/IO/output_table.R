output_table_int <- function(source, dfrtable) {
    formattedtable <- tribble(~Group, ~Green, ~Yellow, ~Red)

    my_greenlist <- filter(dfrtablescontents, sourcefile == source & table == dfrtable & column == "GREEN")
    my_yellowlist <- filter(dfrtablescontents, sourcefile == source & table == dfrtable & column == "YELLOW")
    my_redlist <- filter(dfrtablescontents, sourcefile == source & table == dfrtable & column == "RED")

    my_alllist <- rbind(my_greenlist, my_yellowlist, my_redlist)


    for (gr in unique(my_alllist$group)) {
        green <- c()
        yellow <- c()
        red <- c()

        redtable <- filter(my_redlist, group == gr & !is.na(`lowerthreshold`))
        redtable <- arrange(redtable, material)

        yellowtable <- filter(my_yellowlist, group == gr & (!is.na(`upperthreshold`) | !is.na(`lowerthreshold`)))
        yellowtable <- arrange(yellowtable, material)

        greentable <- filter(my_greenlist, group == gr & !is.na(`upperthreshold`))
        greentable <- arrange(greentable, material)


        if (nrow(redtable)) {
            for (i in 1:nrow(redtable)) {
                row <- redtable[i, ]
                # do stuff with row
                if (row$`lowerthreshold` == 0) {
                    red <- append(red, row$material)
                } else {
                    red <- append(red, paste(">", row$`lowerthreshold`, "wt%", row$material))
                }
            }
        }

        if (nrow(greentable)) {
            for (i in 1:nrow(greentable)) {
                row <- greentable[i, ]

                if (!is.na(row$removed) & row$removed == TRUE) {
                    row$material <- paste(row$material, "*", sep = "")
                }

                # do stuff with row
                if (row$`upperthreshold` == 100) {
                    green <- append(green, row$material)
                } else {
                    green <- append(green, paste("≤", row$`upperthreshold`, "wt%", row$material))
                }
            }
        }



        if (nrow(yellowtable)) {
            for (i in 1:nrow(yellowtable)) {
                row <- yellowtable[i, ]
                if (!is.na(row$removed) & row$removed == TRUE) {
                    row$material <- paste(row$material, "*", sep = "")
                }


                # do stuff with row
                if (!is.na(row$`upperthreshold`)) {
                    if (row$`upperthreshold` == 100 & (is.na(row$`lowerthreshold`) | row$`lowerthreshold` == 0)) {
                        yellow <- append(yellow, row$material)
                    } else {
                        if (is.na(row$`lowerthreshold`) | row$`lowerthreshold` == 0) {
                            yellow <- append(yellow, paste("≤", row$`upperthreshold`, "wt%", row$material))
                        } else {
                            if (is.na(row$`lowerthreshold`) | row$`upperthreshold` == 100) {
                                yellow <- append(yellow, paste(">", row$`lowerthreshold`, row$material))
                            } else {
                                yellow <- append(yellow, paste(">", row$`lowerthreshold`, "to", row$`upperthreshold`, "wt%", row$material))
                            }
                        }
                    }
                } else {
                    if (is.na(row$`lowerthreshold`) | row$`lowerthreshold` == 0) {
                        yellow <- append(yellow, row$material)
                    } else {
                        yellow <- append(yellow, paste(">", row$`lowerthreshold`, "wt%", row$material))
                    }
                }
            }
        }


        greentext <- paste(green, collapse = ";\n")
        yellowtext <- paste(yellow, collapse = ";\n")
        redtext <- paste(red, collapse = ";\n")

        newrow <- data.frame(Group = gr, Green = greentext, Yellow = yellowtext, Red = redtext)

        formattedtable <- rbind(formattedtable, newrow)
    }


    formattedtable
}

output_table <- function(source) {
    temp <- filter(dfrtablescontents, sourcefile == source)
    listoftables <- list()
    for (tabl in unique(temp$table)) {
        formattedtable <- output_table_int(source, tabl)
        listoftables[[tabl]] <- formattedtable
    }
    write_xlsx(listoftables, paste("output/Formatted table ", toupper(source), " (for verification of the input file).xlsx", sep = ""))
}
