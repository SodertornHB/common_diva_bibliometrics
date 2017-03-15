# Ladda ner Norska listan varje månad
source('/home/shub/assets/cred.R')

# Om vi kör som shub så skriver vi till vårt gemensamma bibliotek
if (Sys.info()['user'] == 'shub') {
  nsd.issn = "/home/shub/assets/nsd.issn.csv"
  nsd.forlag = "/home/shub/assets/nsd.forlag.csv"
} else {
  # Annars till lokal plats
  nsd.issn = "nsd.issn.csv"
  nsd.forlag = "nsd.forlag.csv"
}

#issn-listan
if (is.na(file.info(nsd.issn)$mtime) ||
    file.info(nsd.issn)$mtime < Sys.time()-(60*60*24*30)) {
  library(httr)
  r <- POST("https://dbh.nsd.uib.no/publiseringskanaler/BrukerLoggpaSjekk.action",
            body = list(skjemaPassord = nsd.password,
                        BrukerLoggpaSjekk_0 = 'Logg+inn',
                        skjemaEpost = nsd.username))
  r <- GET("https://dbh.nsd.uib.no/publiseringskanaler/AlltidFerskListeTidsskriftSomCsv")
  writeBin(content(r, 'raw'), nsd.issn)
  #writeBin(content(r, 'text', fileEncoding = 'ANSI_X3.4-1986'), nsd.issn) 
}

#forlagslistan
if (is.na(file.info(nsd.forlag)$mtime) ||
    file.info(nsd.forlag)$mtime < Sys.time()-(60*60*24*30)) {
  library(httr)
  r <- POST("https://dbh.nsd.uib.no/publiseringskanaler/BrukerLoggpaSjekk.action",
            body = list(skjemaPassord = nsd.password,
                        BrukerLoggpaSjekk_0 = 'Logg+inn',
                        skjemaEpost = nsd.username))
  r <- GET("https://dbh.nsd.uib.no/publiseringskanaler/AlltidFerskListeForlagSomCsv")
  writeBin(content(r, 'raw'), nsd.forlag)
}
