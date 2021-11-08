#
#
#
#nedladdning norska listan
#171002 JÖ
#loggar in på nsd:s webbplats (Gretas creds) och laddar ner de två csv-filerna: en för issn och en för förlag.
#
#
#

#ladda alltid in tidyverse:
suppressMessages(library(tidyverse))

#för lösenord/username
source('/home/shub/assets/cred.R')

#Den här koden får stå kvar, bra exempel
# Om vi kör som shub så skriver vi till vårt gemensamma bibliotek
if (Sys.info()['user'] == 'shub') {
  nsd.issn = "/home/shub/assets/nsd.issn.csv"
  nsd.forlag = "/home/shub/assets/nsd.forlag.csv"
} else {
  # Annars till lokal plats
  nsd.issn = "nsd.issn.csv"
  nsd.forlag = "nsd.forlag.csv"
}

#laddar ner issn-listan med 30 dagars mellanrum
if (is.na(file.info(nsd.issn)$mtime) ||
    file.info(nsd.issn)$mtime < Sys.time()-(60*60*24*30)) {
  library(httr)
  r <- POST("https://dbh.nsd.uib.no/publiseringskanaler/BrukerLoggpaSjekk.action", config(ssl_verifypeer=0),
            body = list(skjemaPassord = nsd.password,
                        BrukerLoggpaSjekk_0 = 'Logg+inn',
                        skjemaEpost = nsd.username))
  r <- GET("https://dbh.nsd.uib.no/publiseringskanaler/AlltidFerskListeTidsskriftSomCsv", config(ssl_verifypeer=0))
  writeBin(content(r, 'raw'), nsd.issn)
  #writeBin istället för write_csv (no tidyverse-parsing). encoding = "ISO-8859-1"
}

#laddar ner forlagslistan med 30 dagars mellanrum
if (is.na(file.info(nsd.forlag)$mtime) ||
    file.info(nsd.forlag)$mtime < Sys.time()-(60*60*24*30)) {
  library(httr)
  r <- POST("https://dbh.nsd.uib.no/publiseringskanaler/BrukerLoggpaSjekk.action", config(ssl_verifypeer=0),
            body = list(skjemaPassord = nsd.password,
                        BrukerLoggpaSjekk_0 = 'Logg+inn',
                        skjemaEpost = nsd.username))
  r <- GET("https://dbh.nsd.uib.no/publiseringskanaler/AlltidFerskListeForlagSomCsv", config(ssl_verifypeer=0))
  writeBin(content(r, 'raw'), nsd.forlag)
  #writeBin istället för write_csv (no tidyverse-parsing). encoding = "ISO-8859-1"
}




#städning av de norska filerna

#viktigt med encoding = latin1 och tomma celler till NA
n_issn <- read.csv(file="/home/shub/assets/nsd.issn.csv",
                   header=TRUE,
                   sep=";",
                   na.strings = c("", "NA"),
                   stringsAsFactors = FALSE,
                   encoding = "latin1")

n_forlag <- read.csv(file="/home/shub/assets/nsd.forlag.csv",
                   header=TRUE,
                   sep=";",
                   na.strings = c("", "NA"),
                   stringsAsFactors = FALSE,
                   encoding = "latin1")

#urval av endast de kolumner som används
n_issn <- n_issn %>%
  select(-matches("Nivå.idag"))

#skapa kolumnindex för n_issn tibble
current_year <- as.integer(format(Sys.time(), "%Y"))
nr_of_years <- current_year - 2004 + 1
col_names_issn <- names(n_issn)
kol_index <- vector("integer", nr_of_years)
for (i in seq_along(kol_index)) {
  names(kol_index)[[i]] <- current_year + 1 - i
  year <- names(kol_index)[[i]]
  kol_index[[i]] <- grep(year, col_names_issn)
  }
