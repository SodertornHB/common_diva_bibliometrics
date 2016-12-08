# Ladda ner MODS, men endast en gång per 24 timmar
mods.filename = "/home/shub/assets/validator.diva.mods"
if (is.na(file.info(mods.filename)$mtime) ||
    file.info(mods.filename)$mtime < Sys.time()-(60*60*24)) {
  download.file("http://sh.diva-portal.org/dice/mods?query=organisationId:481&rows=50000", mods.filename)
}
