
#
# Filnamnet vi vill att nedladdade filer ska ha, %format% byts ut mot det specifika formatet, ex.v.
# csvall eller csvall2. Här processas också ett antal basfiler, som kan läsas in för vidare bearbetning.
#
# %timestamp% byts ut mot datum och tid som filen laddades ner.
#

filename = "/home/shub/assets/diva/diva_%format%_%timestamp%.csv"

dir.create(dirname(filename), showWarnings = FALSE)

origins = list("csvall2_allt" = "http://sh.diva-portal.org/smash/export.jsf?format=csvall2&noOfRows=500000",
               "csv2_allt" = "http://sh.diva-portal.org/smash/export.jsf?format=csv02&noOfRows=500000"
               )

for (format in names(origins)) {
  f = sub("%format%", format, filename)
  
  # 
  # Vi laddar ner respektive en gång om dagen, så kolla att senaste versionen är tillräckligt gammal.
  # Efter att vi laddat ner en ny fil så uppdaterar vi länken med namn "latest", ex.v.:
  #
  # diva-csvall-latest.csv
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
  # Vi behåller dock två kopior bakåt i tiden.
  #
  l = list.files(path = dirname(cfile), pattern = sub("%timestamp%", ".*", basename(f)))
  if (length(l) >= 3) {
    for (fname in l[(length(l)-3):1]) {
      file.remove(paste(dirname(cfile), fname, sep="/"))
    }
  }
}


#------------------------------------------------------------------------------------------------------------------------
#
#bearbetning av nedladdad data: förbered dataframess att spara till csv-filer.
#
  
#Nr 1: författarfraktionerad df utan studentuppsatser
csvall2_df <- read.csv("/home/shub/assets/diva/diva_csvall2_allt_latest.csv",
                       header=TRUE,
                       sep=",",
                       encoding="UTF-8",
                       na.strings=c("","NA"),
                       stringsAsFactors = FALSE
)

csv2_df <- read.csv("/home/shub/assets/diva/diva_csv2_allt_latest.csv",
                 header=TRUE,
                 sep=",",
                 encoding="UTF-8",
                 na.strings=c("","NA"),
                 stringsAsFactors = FALSE
)

author_df <- merge(x = csv2_df, y = csvall2_df, by.x = "PID", by.y = "PID", all.x = TRUE)

#sortera bort studentuppsatser
author_df <- author_df[!(author_df$PublicationType == "Studentuppsats" |
                           author_df$PublicationType == "Studentuppsats/Examensarbete" |
                           author_df$PublicationType == "Studentuppsats (Examensarbete)"),]
#eller: 
#author_df <- author_df[!(is.na(author_df$ContentType)),]
#vilken är mest tillförlitlig? PublicationType (säger Greta)

#Nr 2: dela csvall2_allt i två delar, en med uppsatser och en utan (resultat: 2 df)
studentessays_df <- csvall2_df[(csvall2_df$PublicationType == "Studentuppsats" |
                                csvall2_df$PublicationType == "Studentuppsats/Examensarbete" |
                                csvall2_df$PublicationType == "Studentuppsats (Examensarbete)"),]

researchpubl_df <- csvall2_df[!(csvall2_df$PublicationType == "Studentuppsats" |
                                  csvall2_df$PublicationType == "Studentuppsats/Examensarbete" |
                                  csvall2_df$PublicationType == "Studentuppsats (Examensarbete)"),]

#Nr 3: dra endast Sh ur researchpubl och author (resultat: 2 df)
author_sh_df <- author_df[!(is.na(author_df$OrganisationIds)),]
researchpubl_sh_df <- researchpubl_df[(grepl("\\[481\\]", researchpubl_df$Name)),]


list_of_dataframes <- list("author_df" = author_df, "studentessays_df" = studentessays_df, "researchpubl_df" = researchpubl_df,
                           "author_sh_df" = author_sh_df, "researchpubl_sh_df" = researchpubl_sh_df)

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
  
  #
  # Efter att ha laddat ner och uppdaterat länkar så tar vi bort eventuella tidigare nedladdningar.
  # Vi behåller dock två kopior bakåt i tiden.
  #
  l = list.files(path = dirname(afile), pattern = sub("%timestamp%", ".*", basename(af)))
  if (length(l) >= 3) {
    for (fname in l[(length(l)-3):1]) {
      file.remove(paste(dirname(afile), fname, sep="/"))
    }
  }
}
