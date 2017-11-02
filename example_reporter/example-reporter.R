#
# Exempelprogram för att demonstrera flödet vid rapportskapande på Högskolebiblioteket.
#
#
# [1] Läs in gemensamma funktioner
#
source('/home/shub/src/common/lib/sh.filter.R')
source('/home/shub/src/common/lib/sh.archive.R')

# 
# [2] Läs in eventuella bibliotek som krävs.
#
library(dplyr)
library(knitr)
library(rmarkdown)

#
# [3] Signalera till arkiv-funktionen att vi nu påbörjar ett arbete med en rapport.
#
sh.archive.start("example-reporter")

#
# [4] Hämta information från relevant dataset, exempelvis DiVA. Dessa uppdateras automatiskt dagligen
#     eller så ofta som är rimligt för datakällan. Gör samtidigt en notering i arkivet att det är denna
#     data vi använt som information.
#
diva <- read.csv(file="/home/shub/assets/diva/diva-csvall-latest.csv", header=TRUE)
sh.archive.df(diva, "input.data")

#
# [5] Hantera data, exempelvis genom att filtrera och sammanställe. Arkivera tabellen efter att vi
#     filtrerat den.
#
diva <- sh.filter(diva, Year %in% seq.int(2007,2017))
diva <- sh.filter(diva, Status!="aheadofprint")
diva <- sh.filter(diva, Status!="accepted")
diva <- sh.filter(diva, Status!="submitted")

sh.archive.df(diva, "filtered.data")

#
# [6] Efter att vi hanterat datat så plockar vi ut endast det som inte blivit bortfiltrerat
#     och tar bort eventuella levels i faktorer som inte är relevanta längre, annars får vi
#     en massa rader/kolumner utan information. Arkivera även denna filtrerade data.frame.
#
diva.results <- sh.filter.result(diva)

diva.results$Year <- droplevels(diva.results$Year)
diva.results$PublicationType <- droplevels(diva.results$PublicationType)

sh.archive.df(diva.results, "output.data")

#
# [7] Skapa en tabell med publikationstyper och år, arkivera denna.
#
diva.table <- table(diva.results$PublicationType, diva.results$Year)
sh.archive.df(diva.table, "output.table")

# 
# [8] Rendrera den slutliga tabellen till en PDF. Arkivera PDF-filen som blir resultatet.
# 
render("report.Rmd", pdf_document())

sh.archive.resource("report.pdf")

#
# [9] Stäng arkivet (gör i praktiken inte så mycket i dagsläget, men är bra att ha med ifall vi gör
#     mer i den funktionen senare)
#
sh.archive.end()
