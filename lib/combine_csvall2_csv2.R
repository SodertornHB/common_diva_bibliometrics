#
#170508 CHL
#
#Funktion för att kombinera csvall2 och csv2

#Funktionen är inte ett separat bibliotek utan måste inkluderas i de program där
#man vill använda dem. Exempelvis genom:
#
# source('/home/shub/src/common/lib/FUNKTION.R')
#
#Funktionen delar upp data enligt författare/rad (csv2). I csvall2 är data ordnat enligt publikation/rad.
#Möjliggör fraktionering.
#Hämtar csv-filer från shub/assets

sh_combine_csv <- function() {
  library(dplyr)
  
  csvall2 <- read.csv("/home/shub/assets/diva/diva-csvall2-latest.csv",
                      header=TRUE,
                      sep=",",
                      encoding="UTF-8",
                      na.strings=c("","NA"),
                      stringsAsFactors = FALSE
  )
  
  csv2 <- read.csv("/home/shub/assets/diva/diva-csv2-latest.csv",
                   header=TRUE,
                   sep=",",
                   encoding="UTF-8",
                   na.strings=c("","NA"),
                   stringsAsFactors = FALSE
  )
  row_per_author <- left_join(csv2, csvall2, by = "PID")
  
  return(row_per_author)
}