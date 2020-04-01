#
#
#
#sh_parameters
#170818 JÖ/CHL/GL
#Här samlar vi alla våra parametrar på en plats så att vi bara ändrar på en plats - här.

#nedladdningar
downloadpath <- "http://sh.diva-portal.org/smash/export.jsf?"
download_csvall2 <- "format=csvall2"
download_csv2 <- "format=csv02"
noOfRows <- "&noOfRows=500000"



#
#institutions- och ämneskoder i DiVA
#listar alla institutioner och ämnen för funktionen filter_orgs
#

arkeologi <- c("485", "7357", "7358", "7359", "11804") #maris och något mer räknas in här i diva?
arkivvetenskap <- c("7409", "11805")
beegs <- c("483")
biologi <- c("7360", "7361", "7362", "11832")
cbees <- c("482", "496")
praktisk <- c("5550", "7365", "7366", "11810")
engelska <- c("7372", "7373", "7374", "11811")
enter <- c("7375", "11843")
estetiska <- c("15801")
estetik <- c("7376", "7377", "7378", "11812")
etnologi <- c("7379", "7380", "7381", "11806")
foretagsekonomi <- c("7388", "7389", "11823")
filosofi <- c("7382", "7383", "7384", "11813")
forvaltning <- c("11750", "11842")
genusvetenskap <- c("7390", "7391", "7392", "7393", "11814")
geografi <- c("7394", "7395", "11833")
historia <- c("7399", "7400", "7401", "7402", "11803")
idehistoria <- c("7353", "7354", "7355", "7356", "11807")
hs <- c("11802", "485", "497", "7356", "7381", "7402", "7409", "7462", "7485", "7499", "7500", "7501", 
        "11803", "11804", "11805", "11806", "11807", "11808", "11846")
ikl <- c("11809", "495", "498", "5550", "7374", "7378", "7384", "7393", "7456", "7460", "7479", "7489",
         "7490", "7519", "7520", "11810", "11811", "11812", "11813", "11814", "11815", "11816", "11817",
         "11818", "11819", "11820", "11821", "15801")
internationell_halsa <- c("11751", "11834")
internationella_relationer <- c("11824")
journalistik <- c("7403", "7405", "7406", "7407", "11825")
juridik <-  c("11827", "883451")
konstvetenskap <- c("7455", "7456", "11815")
lararutbildning <- c("495", "11821", "873601")
litteraturvetenskap <- c("7457", "7458", "7459", "7460",  "11816")
maltidskunskap <- c("7473", "11838")
maris <- c("7462", "11845")
matematisk_didaktik <- c("15800")
medieteknik <- c("7465", "7466", "7467", "7468", "11835")
miljovetenskap <- c("7469", "7470", "11837")
mkv <- c("498", "7351", "7352", "11817")
nationalekonomi <- c("7474", "7475", "7476", "7477", "11826")
nmt <- c("11831", "484", "486", "7362", "7395", "7408", "7454", "7467", "7468", "7470", "7472", "7473",
         "7521", "7522", "7523", "7527", "11751", "11831", "11832", "11833", "11834", "11835", "11837",
         "11838", "11839", "11840", "15800")
pedagogik <- c("7478", "7479", "11818")
polisutbildning <- c("873602")
politikens_organisering <- c("878302")
psykologi <- c("7481", "11828")
reinvent <- c("878301")
religionsvetenskap <- c("7482", "7483", "7484", "7485", "11808")
retorik <- c("7486", "7488", "7489", "7490", "11819")
sam <- c("11822", "7375", "7389", "7406", "7407", "7452", "7477", "7481", "7504", "7508", "7516", "9000",
         "11750", "11822", "11823", "11824", "11825", "11826", "11827", "11828", "11829", "11830", "11841",
         "11842", "11843", "11844", "878301", "878302", "883451")
samtidshistoriska <- c("497", "7497", "7498", "7499", "7531", "11846")
scohost <- c("7502", "7503", "7504", "11844", "13305")
sh_csv <- "\\[481\\]"
sh <- c("481")
shb <- c("2050")
socialt_arbete <- c("9000", "11829")
sociologi <- c("7505", "7506", "7507", "7508", "11841")
statsvetenskap <- c("7513", "7514", "7515", "7516", "11830")
svenska <- c("7517", "7518", "7519", "7520", "11820")
turismvetenskap <- c("7521", "7522", "7523", "11839")
utveckling_och_int_samarbete <- c("7527", "11840")

#medelsfördelningsspecifika parametrar:

#för kopplingar institution/ämne:
inst_list <- list("hs" = hs, "ikl" = ikl, "nmt" = nmt, "sam" = sam)
#centra: maris, scohost, cbees
centra_list <- c("enter" = enter, "maris" = maris, "scohost" = scohost)
ämnen_list <- c("arkeologi" = arkeologi, "arkivvetenskap" = arkivvetenskap, "biologi" = biologi, "engelska" = engelska,
                "estetik" = estetik, "etnologi" = etnologi, "foretagsekonomi" = foretagsekonomi, "filosofi" = filosofi,
                "genusvetenskap" = genusvetenskap, "geografi" = geografi, "historia" = historia,
                "idehistoria" = idehistoria, "internationell_halsa" = internationell_halsa,
                "internationella_relationer" = internationella_relationer, "journalistik" = journalistik, "juridik" = juridik,
                "konstvetenskap" = konstvetenskap, "litteraturvetenskap" = litteraturvetenskap,
                "lararutbildning" = lararutbildning, "maltidskunskap" = maltidskunskap,"matematisk_didaktik" = matematisk_didaktik,
                "medieteknik" = medieteknik, "miljovetenskap" = miljovetenskap,
                "mkv" = mkv, "nationalekonomi" = nationalekonomi,
                "pedagogik" = pedagogik, "psykologi" = psykologi, "praktisk" = praktisk,
                "religionsvetenskap" = religionsvetenskap, "retorik" = retorik, "samtidshistoriska" = samtidshistoriska,  "socialt_arbete" = socialt_arbete,
                "sociologi" = sociologi, "statsvetenskap" = statsvetenskap, "svenska" = svenska,
                "turismvetenskap" = turismvetenskap, "utveckling_och_int_samarbete" = utveckling_och_int_samarbete)


#divadata: ska vi förenkla namnen på det som vi avgränsar till? Nedanstående vektorer används inte idag.
content_type <- c(a = "Refereegranskat",
                  b = "Övrigt vetenskapligt",
                  c = "Övrig (populärvetenskap, debatt, mm)"
)

publication_type <- c(a = "Artikel, forskningsöversikt",
                      b = "Artikel i tidskrift",
                      c = "Artikel, recension",
                      d = "Bok",
                      e = "Doktorsavhandling, monografi",
                      f = "Doktorsavhandling, sammanläggning",
                      g = "Kapitel i bok, del av antologi",
                      h = "Konferensbidrag",
                      i = "Licentiatavhandling, monografi",
                      j = "Licentiatavhandling, sammanläggning",
                      k = "Manuskript (preprint)",
                      l = "Proceedings (redaktörskap)",
                      m = "Rapport",
                      n = "Samlingsverk (redaktörskap)",
                      o = "Studentuppsats",
                      p = "Studentuppsats (Examensarbete)",
                      q = "Studentuppsats/Examensarbete",
                      r = "Övrigt"
)

publication_subtype <- c(a = "abstracts",
                         b = "editorialMaterial",
                         c = "exhibitionCatalogue",
                         d = "letter",
                         e = "meetingAbstract",
                         f = "newsItem",
                         g = "poster",
                         h = "presentation",
                         i = "publishedPaper")

