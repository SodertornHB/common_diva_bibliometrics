#
# Funktioner för att arkivera information relaterad till en rapport för spårbarhet.
# Funktionerna är inte ett separat bibliotek utan måste inkluderas i de program där
# man vill använda dem. Exempelvis genom:
#
#  source('/home/shub/src/common/lib/sh.archive.R')
#

#
# Initialiserar ett antal globala variabler för att hålla reda på och unikt identifiera denna
# rapport.
#
# Argument:
#     id: En identifierare för denna typ av rapport, utan mellanslag, exempelvis "arsrapport" eller
#         "validering-issn"
#
sh.archive.start <- function(id) {
  XSH.timestamp <<- format(Sys.time(), "%Y%m%d-%H%M%S")
  XSH.id <<- sprintf("%s-%s", id, Sys.getpid())
  XSH.dir <<- sprintf("/home/shub/reports/%s", XSH.id)
  dir.create(XSH.dir)
}

#
# Funktion för att lägga till en data.frame till ett rapport-arkiv. Denna skrivs ner som CSV.
#
# Argument:
#     df: Den data.frame som ska läggas till
#     id: En identifierare för denna data.frame, utan mellanslag, exempelvis "tabell", "original",
#         etc.
#
sh.archive.df <- function(df, id) {
  write.csv(df, sprintf("%s/%s.csv", XSH.dir, id))
}

#
# Funktion för att lägga till en resurs (en fil) till ett rapport-arkiv. Denna kopieras som den är till
# destinationen.
#
# Argument:
#     f: Den fil som ska kopieras
#
sh.archive.resource <- function(f) {
  file.copy(f, XSH.dir)
}

#
# Funktion för att avsluta arbetet med ett rapport-arkiv. Denna funktion gör inget mer än skapar
# ett manifest över alla ingående filer i arkivet.
#
sh.archive.end <- function() {
  write(list.files(path=XSH.dir), sprintf("%s/%s", XSH.dir, "manifest.txt"))
}