# Ladda ner PlumX-data varje månad
source('/home/shub/assets/cred.R')
key = plu.mx.auth

# Om vi kör som shub så skriver vi till vårt gemensamma bibliotek
if (Sys.info()['user'] == 'shub') {
  px.filename = "/home/shub/assets/plumx.JSON"  
} else {
  # Annars till lokal plats
  px.filename = "plumx.JSON"
}

if (is.na(file.info(px.filename)$mtime) ||
    file.info(px.filename)$mtime < Sys.time()-(60*60*24*30)) {
  library(httr)
  r <- GET("https://api.plu.mx/g/sh-se/_artifacts", query = list(auth=key, size=25000))
  writeBin(content(r, 'raw'), px.filename)
}
