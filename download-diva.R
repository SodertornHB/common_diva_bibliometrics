
#
# Filnamnet vi vill att nedladdade filer ska ha, %format% byts ut mot det specifika formatet, ex.v.
# csvall eller csvall2. Om vi vill göra olika utsökningar och ha dem tillgängliga, ex.v. ta ut en
# csvall som bara innehåller fulltext så skulle det gå att namnge den till csvall-fulltext osv.
#
# %timestamp% byts ut mot datum och tid som filen laddades ner.
#

filename = "/home/shub/assets/diva/diva-%format%-%timestamp%.csv"

dir.create(dirname(filename), showWarnings = FALSE)

origins = list("csvall" = "http://sh.diva-portal.org/smash/export.jsf?format=csvall&aq=[[]]&aqe=[]&aq2=[[{\"organisationId\":\"481\",\"organisationId-Xtra\":true}]]&onlyFullText=false&noOfRows=50000&sortOrder=title_sort_asc",
               "csvall2" = "http://sh.diva-portal.org/smash/export.jsf?format=csvall2&aq=[[]]&aqe=[]&aq2=[[{\"organisationId\":\"481\",\"organisationId-Xtra\":true}]]&onlyFullText=false&noOfRows=50000&sortOrder=title_sort_asc"
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
      fs = sub("%timestamp%", format(Sys.time(), "%Y%m%d-%H%M"), f)
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
