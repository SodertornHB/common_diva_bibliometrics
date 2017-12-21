#
#
#
#download-plumx.R
#170921 CHL
#Laddar ner PlumX-data varje månad. Notera postgränsen för nedladdning (50 000 poster), kan behöva uppdateras. 
#API-nyckel hämtas från assets på servern.
#
#
#
#httr och jsonlite ingår inte i tidyversepaketet, men rekommenderas som komplement
library(tidyverse)
library(httr)
library(jsonlite)
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
  r <- GET("https://api.plu.mx/g/sh-se/_artifacts", query = list(auth=key, size=50000))
  #ska det verkligen vara writeBin här. påverkar det filstorleken?
  writeBin(content(r, 'raw'), px.filename)
}

#kombinera plumx-data med divadata
#diva-fil
d <- read_csv("/home/shub/assets/diva/diva_researchpubl_latest.csv", col_names = TRUE)
d <- separate(d, col = "NBN", into = c("url", "idnr"), sep = "-")

#plumdata
#kräver jsonlite och data.frame. Tar lång tid på sig, varför?
total_plumxdata <- data.frame(fromJSON(txt="/home/shub/assets/plumx.JSON")) 
#hämta upp nested data så att all data får egna kolumner
#flatten i jsonlite i konflikt med flatten i purrr. Stämmer det fortfarande?
total_plumxdata <- flatten(total_plumxdata, recursive = TRUE) 
#begränsa datamängden genom att endast arbeta med de kolumner som behövs
urval_plumxdata <- select(total_plumxdata, matches(".sortCount.|.repoUrl"))

urval_plumxdata <- total_plumxdata %>%
  select(matches(".sortCount.|.repoUrl")) %>%
  filter(!(document.identifier.repoUrl == "NULL" | grepl("^c", document.identifier.repoUrl))) %>%
  separate(document.identifier.repoUrl, into = c("url", "idnr"), sep = "-")

#gör om tomma Url-celler samt felformaterade Url:er till NAs
#NULL (353 st, dokument utanför DIVA)
#c("http://urn... (213 st, varför blir det så här?)
#dela på Url till förled och PID för att kunna matcha mot DiVA
#urval_plumxdata$idnr <- as.integer(urval_plumxdata$idnr) #behövs inte
urval_plumxdata$document.identifier.repoUrl = unlist(urval_plumxdata$document.identifier.repoUrl) #default är lista, vilket inte fungerar med sh.archive-funktionen

#kombinera diva-data och plumx-data
plumx_diva <- left_join(d, urval_plumxdata, by = "idnr")

#-----------------------------------------------------------------------------------------------------------------
#spara fil
filename = "/home/shub/assets/diva/diva_%format%_%timestamp%.csv"
list_of_tibbles = list("plumx_diva" = plumx_diva)

dir.create(dirname(filename), showWarnings = FALSE)

for (t in names(list_of_tibbles)) {
  af = sub("%format%", t, filename)
  
  afile = sub("%timestamp%", "latest", af)
  if(is.na(file.info(afile)$mtime) ||
     file.info(afile)$mtime < Sys.time()-(60*60*24)) {
    as = sub("%timestamp%", format(Sys.time(), "%Y%m%d_%H%M"), af)
    write.csv(list_of_tibbles[[t]], as)
    if (file.exists(afile)) {
      file.remove(afile)
    }
    file.symlink(as, afile)
  }
  
  #
  # Efter att ha laddat ner och uppdaterat länkar så tar vi bort eventuella tidigare nedladdningar.
  # Vi behåller dock en kopia bakåt i tiden.
  #
  l = list.files(path = dirname(afile), pattern = sub("%timestamp%", ".*", basename(af)))
  if (length(l) >= 4) {
    for (fname in l[(length(l)-4):1]) {
      file.remove(paste(dirname(afile), fname, sep="/"))
    }
  }
}
