#
#
#
#download-diva
#171008 CHL återgång till innan Tidyverse pga symlink
#170920 CHL (senaste uppdatering:anpassad till Tidyverse)
#laddar ner DiVA-data (2 csv-filer) via DiVAs API en gång per dygn. Sparar en kopia bakåt i tiden. 
#csv-filerna delas upp och kombineras till 5 basfiler: forskningspublikationer och forskare med och
#utan Sh-affiliering samt studentuppsatser.
#
#
#

#library(tidyverse)

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

#max 50000 rader, kan komma att behöva uppdateras framöver
origins = list("csvall2_allt" = "http://sh.diva-portal.org/smash/export.jsf?format=csvall2&noOfRows=500000",
               "csv2_allt" = "http://sh.diva-portal.org/smash/export.jsf?format=csv02&noOfRows=500000"
               )

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
  if (is.na(file.info(cfile)$mtime) ||
      file.info(cfile)$mtime < Sys.time()-(60*60*24)) {
      fs = sub("%timestamp%", format(Sys.time(), "%Y%m%d_%H%M"), f)
      download.file(origins[[format]], fs)
      if (file.exists(cfile)) {
        file.remove(cfile)
      }
      file.symlink(fs, cfile)
  }
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


#------------------------------------------------------------------------------------------------------------------------
#
#bearbetning av nedladdad data: förbered dfs.
#
#Nr 1: författarfraktionerad df utan studentuppsatser
csvall2 <- read.csv("/home/shub/assets/diva/diva_csvall2_allt_latest.csv",
                    header=TRUE,
                    sep=",",
                    encoding="UTF-8",
                    na.strings=c("","NA"),
                    stringsAsFactors = FALSE
                    )

csv2 <- read.csv("/home/shub/assets/diva/diva_csv2_allt_latest.csv",
                    header=TRUE,
                    sep=",",
                    encoding="UTF-8",
                    na.strings=c("","NA"),
                    stringsAsFactors = FALSE
                    )

author <- merge(x = csv2, y = csvall2, by.x = "PID", by.y = "PID", all.x = TRUE)

#sortera bort studentuppsatser
author <- author[!(author$PublicationType == "Studentuppsats" |
                     author$PublicationType == "Studentuppsats/Examensarbete" |
                     author$PublicationType == "Studentuppsats (Examensarbete)"),]  

#följande tidyverse-kod fungerar inte med symlink
#Nr 1: författarfraktionerad tibble utan studentuppsatser
#csvall2 <- read_csv("/home/shub/assets/diva/diva_csvall2_allt_latest.csv", col_names = TRUE)
#PID blir felaktigt format vid inläsning, därför:
#colnames(csvall2)[1] <- "PID"


#csv2 <- read_csv("/home/shub/assets/diva/diva_csv2_allt_latest.csv", col_names = TRUE)
#PID blir felaktigt format vid inläsning, därför:
#colnames(csv2)[1] <- "PID"


#author <- left_join(csv2, csvall2, by = "PID")

#sortera bort studentuppsatser ur författar-tibble
#author <- filter(author, !(PublicationType %in% c("Studentuppsats",
#                                                  "Studentuppsats/Examensarbete",
#                                                  "Studentuppsats (Examensarbete)"
#                                                  )
#                           )
#                 )

#eller: 
#author <- author[!(is.na(author$ContentType)),] syntax för read.csv
#vilken är mest tillförlitlig? PublicationType säger Greta

#Nr 2: dela csvall2 i två delar, en med uppsatser och en utan (resultat: 2 dfs).
#Notera utropstecknet.
studentessays <- csvall2[(csvall2$PublicationType == "Studentuppsats" |
                            csvall2$PublicationType == "Studentuppsats/Examensarbete" |
                            csvall2$PublicationType == "Studentuppsats (Examensarbete)"),]

researchpubl <- csvall2[!(csvall2$PublicationType == "Studentuppsats" |
                            csvall2$PublicationType == "Studentuppsats/Examensarbete" |
                            csvall2$PublicationType == "Studentuppsats (Examensarbete)"),]

#följande tidyverse-kod fungerar inte med symlink
#Nr 2: dela csvall2 i två delar, en med uppsatser och en utan (resultat: 2 tibbles). Notera utropstecknet.
#studentessays <- filter(csvall2, (PublicationType %in% c("Studentuppsats", 
#                                                        "Studentuppsats/Examensarbete", 
#                                                        "Studentuppsats (Examensarbete)"
#                                                        )
#                                  )
#                        )

#researchpubl <- filter(csvall2, !(PublicationType %in% c("Studentuppsats", 
#                                                               "Studentuppsats/Examensarbete", 
#                                                               "Studentuppsats (Examensarbete)"
#                                                        )
#                                 )
#                       )

#Nr 3: dra endast Sh ur researchpubl och author (resultat: 2 df)
author_sh <- author[!(is.na(author$OrganisationIds)),]
researchpubl_sh <- researchpubl[(grepl("\\[481\\]", researchpubl$Name)),]

#följande tidyverse-kod fungerar inte med symlink
#Nr 3: endast Sh-affilierade publikationer från researchpubl och author (resultat: 2 tibbles)
#sh_author <- filter(author, !(is.na(OrganisationIds)))
#sh_researchpubl <- filter(researchpubl, (grepl("\\[481\\]", Name)))


#-----------------------------------------------------------------------------------------------------------------
#spara undan de 5 dfs
list_of_dataframes <- list("author" = author, 
                           "studentessays" = studentessays, 
                           "researchpubl" = researchpubl,
                           "author_sh" = author_sh,
                           "researchpubl_sh" = researchpubl_sh)

for (df in names(list_of_dataframes)) {
  af = sub("%format%", df, filename)
  
  afile = sub("%timestamp%", "latest", af)
  if(is.na(file.info(afile)$mtime) ||
     file.info(afile)$mtime < Sys.time()-(60*60*24)) {
    as = sub("%timestamp%", format(Sys.time(), "%Y%m%d_%H%M"), af)
    write.csv(list_of_dataframes[[df]], as)
    if (file.exists(afile)) {
      file.remove(afile)
      }
    file.symlink(as, afile)
    }

#följande tidyverse-kod fungerar inte med symlink
#spara undan de 5 tibbles
#list_of_tibbles <- list("author" = author, "studentessays" = studentessays, "researchpubl" = researchpubl,
#                        "sh_author" = sh_author, "sh_researchpubl" = sh_researchpubl)


#for (t in names(list_of_tibbles)) {
#  af = sub("%format%", t, filename)
  
#  afile = sub("%timestamp%", "latest", af)
#  if(is.na(file.info(afile)$mtime) ||
#     file.info(afile)$mtime < Sys.time()-(60*60*24)) {
#    as = sub("%timestamp%", format(Sys.time(), "%Y%m%d_%H%M"), af)
#    write.csv(list_of_tibbles[[t]], as)
#   if (file.exists(afile)) {
#     file.remove(afile)
#   }
#    file.symlink(as, afile)
#  }
  
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
