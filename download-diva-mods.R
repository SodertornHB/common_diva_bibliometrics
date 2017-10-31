#
# Ladda ner MODS, denna körs endast en gång per dygn.
#
mods.filename = "/home/shub/assets/validator.diva.mods"
tempfile = tempfile("mods")

#
# Vi laddar först ner filen till en temporär lagringsplats
#
download.file("http://sh.diva-portal.org/dice/mods?query=organisationId:481&rows=50000", tempfile, quiet=TRUE)

# Kolla om filen är komplett. Den ska var minst 500000 bytes stor och
# innehålla texten "modsCollection" i början.
stopifnot(file.info(tempfile)$size > 500000)
stopifnot(grepl("modsCollection", readChar(tempfile, 100), fixed=TRUE) == TRUE)

#
# Om vi kommer så här långt, så flyttar vi in filen på rätt plats.
# Vi använder invisible() eftersom vi inte bryr oss så mycket om att
# file.rename returnerar TRUE.
#
invisible(file.rename(tempfile, mods.filename))
