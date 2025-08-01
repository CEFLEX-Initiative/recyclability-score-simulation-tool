# Read design tables from excel

recycling_streams <- NULL

dfrtablescontents <- NULL

dfrtables <- NULL

fils <- list.files("tables/", pattern = "*.xlsx", full.names = TRUE)
for (fil in fils) {
    tables <- excel_sheets(fil)
    inp <- data.frame()
    for (table in tables) {
        inp <- rbind(inp, read_xlsx(fil, sheet = table, skip = 1))
    }


    inp <- cSplit(inp, "Stream", ",", direction = "long")

    nam <- file_path_sans_ext(basename(fil))

    dfrtables <- append(dfrtables, nam)

    # an assumption is made here that red listed elements are considered to be 'only red' and it is not relevant whether they are also removed or not (i.e., removed but non-disturbing elements would be in green or yellow, red means that there is no effective removal) 
    dfrtablescontents <- rbind(dfrtablescontents, data.frame(sourcefile = nam, table = inp$Stream, material = inp$Material, lowerthreshold = inp$`RED Lower threshold`, upperthreshold = NA, group = inp$Group, removed = FALSE, column = "RED"))

    dfrtablescontents <- rbind(dfrtablescontents, data.frame(sourcefile = nam, table = inp$Stream, material = inp$Material, lowerthreshold = inp$`YELLOW Lower threshold`, upperthreshold = inp$`YELLOW Upper threshold`, group = inp$Group, removed = inp$Removed, column = "YELLOW"))
    dfrtablescontents <- rbind(dfrtablescontents, data.frame(sourcefile = nam, table = inp$Stream, material = inp$Material, upperthreshold = inp$`GREEN Upper threshold`, lowerthreshold = NA, group = inp$Group, removed = inp$Removed, column = "GREEN"))

    # needed because empty (spacer) rows in the input excel file will create all-NA rows
    dfrtablescontents <- filter(dfrtablescontents, !is.na(table))

    recycling_streams <- rbind(recycling_streams, data.frame(sourcefile = nam, stream = unique(inp$Stream)))
}
