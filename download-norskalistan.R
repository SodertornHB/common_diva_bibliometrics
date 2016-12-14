# Ladda ner Norska listan varje månad
source('/home/shub/assets/cred.R')
nsd.filename = "/home/shub/assets/nsd.list-approved.csv"
if (is.na(file.info(nsd.filename)$mtime) ||
    file.info(nsd.filename)$mtime < Sys.time()-(60*60*24*30)) {
  library(httr)
  r <- POST("https://dbh.nsd.uib.no/publiseringskanaler/BrukerLoggpaSjekk.action",
            body = list(skjemaPassord = nsd.password,
                        BrukerLoggpaSjekk_0 = 'Logg+inn',
                        skjemaEpost = nsd.username))
  r <- GET("https://dbh.nsd.uib.no/publiseringskanaler/AlltidFerskListeTidsskriftSomCsv")
  writeBin(content(r, 'raw'), nsd.filename)
}
