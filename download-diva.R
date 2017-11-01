#
#
#
#download-diva
#171031 fixat backup-problematiken (sparade för många filer) samt anpassat till sh_parametrar
#171031 JÖ felhantering
#171012 Tidyverse och _ fixat, kolumn x1 återstår
#171008 CHL återgång till innan Tidyverse pga symlink
#170920 CHL (senaste uppdatering:anpassad till Tidyverse)
#170411 JÖ
#laddar ner DiVA-data (2 csv-filer) via DiVAs API en gång per dygn. Sparar en kopia bakåt i tiden. 
#csv-filerna delas upp och kombineras till 5 basfiler: forskningspublikationer och forskare med och
#utan Sh-affiliering samt studentuppsatser.
#
#
#

suppressMessages(library(tidyverse))
library(stringr)

source('/home/shub/assets/sh_parameters.R')

#
# Filnamnet vi vill att nedladdade filer ska ha, %format% byts ut mot det specifika formatet, ex.v.
# csvall eller csvall2. Här processas också ett antal basfiler, som kan läsas in för vidare bearbetning.
#
# %timestamp% byts ut mot datum och tid som filen laddades ner.
#
#

#lokal filväg
filename = "/home/shub/assets/diva/diva_%format%_%timestamp%.csv"

dir.create(dirname(filename), showWarnings = FALSE)

origins = list("csvall2_allt" = str_c(downloadpath, download_csvall2, noOfRows),
               "csv2_allt" = str_c(downloadpath, download_csv02, noOfRows)
)
#max 50000 rader, kan komma att behöva uppdateras framöver
#origins = list("csvall2_allt" = "http://sh.diva-portal.org/smash/export.jsf?format=csvall2&noOfRows=500000",
#               "csv2_allt" = "http://sh.diva-portal.org/smash/export.jsf?format=csv02&noOfRows=500000"
#               )

for (format in names(origins)) {
  f = sub("%format%", format, filename)
  
  # 
  # Vi laddar ner respektive en gång om dagen, så kolla att senaste versionen är tillräckligt gammal.
  # Efter att vi laddat ner en ny fil så uppdaterar vi länken med namn "latest", ex.v.:
  #
  # diva_csvall2_allt_latest.csv
  #
  # så att denna i stället pekar på den nyss nedladdade filen.
  #
  cfile = sub("%timestamp%", "latest", f)
  fs = sub("%timestamp%", format(Sys.time(), "%Y%m%d.%H%M"), f)
  tempfile = tempfile("diva")

  download.file(origins[[format]], tempfile, quiet=TRUE)

  #
  # Filen ska vara större än 500000 bytes och ha fler än 5000 rader. Den
  # ska också innehålla kolumnen PID, deklarerad i början av filen.
  #
  stopifnot(file.info(tempfile)$size > 500000)
  stopifnot(length(readLines(tempfile)) > 5000)
  stopifnot(grepl("PID", readChar(tempfile, 100), fixed=TRUE) == TRUE)

  # Flytta till rätt ställe om allt är okey
  invisible(file.rename(tempfile, fs))

  if (file.exists(cfile)) {
    file.remove(cfile)
  }
  file.symlink(fs, cfile)
  #
  
  # Efter att ha laddat ner och uppdaterat länkar så tar vi bort eventuella tidigare nedladdningar.
  # Vi behåller dock en kopia bakåt i tiden.
  #
  l = list.files(path = dirname(cfile), pattern = sub("%timestamp%", ".*", basename(f)))
  if (length(l) >= 4) {
    for (fname in l[(length(l)-4):1]) {
      file.remove(paste(dirname(cfile), fname, sep="/"))
    }
  }
}
  
#  l = list.files(path = dirname(cfile), pattern = sub("%timestamp%", ".*", basename(f)))
#  if (length(l) >= 4) {
#    for (fname in l[(length(l)-4):1]) {
#      file.remove(paste(dirname(cfile), fname, sep="/"))
#    }
#  }
#}


#------------------------------------------------------------------------------------------------------------------------


#Nr 1: författarfraktionerad tibble utan studentuppsatser
csvall2 <- suppressMessages(read_csv("/home/shub/assets/diva/diva_csvall2_allt_latest.csv", col_names = TRUE))
#PID blir felaktigt format vid inläsning, därför:
colnames(csvall2)[1] <- "PID"


csv2 <- suppressMessages(read_csv("/home/shub/assets/diva/diva_csv2_allt_latest.csv", col_names = TRUE))
#PID blir felaktigt format vid inläsning, därför:
colnames(csv2)[1] <- "PID"


author <- left_join(csv2, csvall2, by = "PID")

#sortera bort studentuppsatser ur författar-tibble
author <- filter(author, !(PublicationType %in% publication_type[c("o", "p", "q")]))

#eller: 
#author <- author[!(is.na(author$ContentType)),] syntax för read.csv
#vilken är mest tillförlitlig? PublicationType säger Greta

#följande tidyverse-kod fungerar inte med symlink
#Nr 2: dela csvall2 i två delar, en med uppsatser och en utan (resultat: 2 tibbles). Notera utropstecknet.
studentessays <- filter(csvall2, (PublicationType %in% publication_type[c("o", "p", "q")]))

researchpubl <- filter(csvall2, !(PublicationType %in% publication_type[c("o", "p", "q")]))

#Nr 3: endast Sh-affilierade publikationer från researchpubl och author (resultat: 2 tibbles)
author_sh <- filter(author, !(is.na(OrganisationIds)))
researchpubl_sh <- filter(researchpubl, (grepl(sh_csv, Name)))

#-----------------------------------------------------------------------------------------------------------------

#spara 5 tibbles på shub
list_of_tibbles <- list("author" = author, "studentessays" = studentessays, "researchpubl" = researchpubl,
                        "author_sh" = author_sh, "researchpubl_sh" = researchpubl_sh)


for (t in names(list_of_tibbles)) {
  af = sub("%format%", t, filename)
  
  afile = sub("%timestamp%", "latest", af)

  as = sub("%timestamp%", format(Sys.time(), "%Y%m%d.%H%M"), af)

  write_csv(list_of_tibbles[[t]], as)
  if (file.exists(afile)) {
    file.remove(afile)
    }
  file.symlink(as, afile)
  
  #
  # Efter att ha laddat ner och uppdaterat länkar så tar vi bort eventuella tidigare nedladdningar.
  # Vi behåller dock en kopia bakåt i tiden. Notera mönstret [^_]* för underscore.
  #
  l = list.files(path = dirname(afile), pattern = sub("%timestamp%", "[^_]*", basename(af)))
  if (length(l) >= 4) {
    for (fname in l[(length(l)-4):1]) {
      file.remove(paste(dirname(afile), fname, sep="/"))
    }
  }
}

