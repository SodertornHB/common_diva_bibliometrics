#
#
#
#sh_diva_bibliometrics_functions
#171031 JÖ/CHL/GL
#Här samlar vi alla våra egna funktioner, uppdelade på avdelningar.
#Funktionerna är inte ett separat bibliotek utan måste inkluderas
#i de program där man vill använda dem. Exempelvis genom:
#
#source('/home/shub/src/common/lib/sh_diva_bibliometrics_functions.R')
#
#
# Ingående katagorier
#
#  sh_filter_	Funktioner för att filtrera data.frames på ett spårbart sätt
#  sh_archive_	Funktioner för att arkivera rapporter och ingående data
#  filter_	Diverse data-specifika funktioner för att filtrera data
#  doaj_	Funktion för att matcha DOAJ
#  sh_timeline_ Diagramfunktioner
#
library(tidyverse)
library(lazyeval)

source('/home/shub/src/common/lib/sh_parameters.R')


# sh_filter ------------------------------------------------------------------
#

#' 
#' Applicerar ett dplyr::filter på en data.frame och gör samtidigt en notering (i samma data.frame)
#' om vilket filter som gjorde att en specifik rad filtrerades bort. Funktionen använder kolumnerna
#' "Filtered" och "Filter" som tillfälliga kolumner för att hålla ordning på informationen. Dessa
#' kolumner skapas om de inte finns. Det finns inga garantier för att en returnerad data.frame är
#' sorterad på samma sätt som den ursprungliga.
#'
#' @param df  En data.frame, lämpligen DiVA-data men funktionen fungerar
#'            för alla varianter av data.frames
#' @param ... Ett eller flera uttryck som skickas omodifierade till
#'            dplyr::filter, ex.v. PublicationType != "Artikel"
#' @return    En data.frame där filtrerade rader är noterade med TRUE i
#'            kolumnen "Filtered" och där kolumnen "Filter" innehåller det
#'            exakta uttryck som gjorde att de filtrerades bort.
#' @examples
#'
#' Exempel på användning:
#'
#' x <- data.frame(PID = c(123456,789012,345679),
#'                 PublicationType = c("Artikel", "Artikel", "Doktorsavhandling, monografi"),
#'                 Name = c("Test Testsson", "Test Josesson", "Test Abrahamsson"))
#' x <- sh_filter_track(x, PublicationType != "Artikel")
#' x <- sh_filter_track(x, PID != 345679)
#'
#' [x]
#'     PID              PublicationType             Name Filtered                       Filter
#' 1 123456                      Artikel    Test Testsson     TRUE PublicationType != "Artikel"
#' 2 789012                      Artikel    Test Josesson     TRUE PublicationType != "Artikel"
#' 3 345679 Doktorsavhandling, monografi Test Abrahamsson     TRUE                PID != 345679
sh_filter_track <- function(df, ...) {
  if (!("Filtered" %in% colnames(df))) {
    # Skapa kolumnerna Filtered och Filter om de inte finns redan
    df$Filtered <- FALSE
    df$Filter <- NA
  }
  # Vi börjar med att filtrera bort de som redan filtrerats bort tidigare
  W <- dplyr::filter(df, Filtered != TRUE)
  # Sedan appliceras dplyr::filter på de som är kvar
  N <- dplyr::filter(W, ...)
  # 
  # Med setdiff() får vi ut de rader i en data.frame som har filtrerats ut av dplyr::filter.
  # Om vi har filtrerat ut några rader (fler än 0) så sätter vi på dessa rader kolumnen
  # "Filtered" till TRUE samt "Filter" till en text-representation av argumenten till dplyr::filter
  # 
  D <- setdiff(W, N)
  if (nrow(D) > 0) {
    D$Filter <- deparse(substitute(...))
    D$Filtered <- TRUE
    return(rbind(setdiff(df, W), N, D))
  } else {
    return(rbind(setdiff(df, W), N))
  }
}

#'
#' Efter användningen av sh_filter_track innehåller en data.frame både sådana rader som har blivit bort-
#' filtrerade och anledningen bakom det. Denna funktion tar en data.frame från sh_filter_track och
#' plockar bort rader som har blivit filtrerade och tar även bort kolumnerna "Filter" och
#' "Filtered"
#'
#' @param df Den data.frame som ska städas
#' @return En data.frame utan kolumnerna "Filter" och "Filtered"
#'
sh_filter_track_result <- function(df) {
  W <-dplyr::filter(df, Filtered != TRUE)
  W$Filter <- NULL
  W$Filtered <- NULL
  return(W)
}

# filter ------------------------------------------------------------------

#

#specifika filter-funktioner
#

#
#PublicationType
#

#' filtrera fram följande PublicationType: "Artikel, forskningsöversikt", "Artikel i tidskrift",
#' "Bok", "Kapitel i bok, del av antologi", "Konferensbidrag"
#' (med abstract etc om inte publsubtype-filter tillämpas)
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble
#'
filter_publtyp_art_bok_kap_konf <- function(divadata) {
  a = divadata %>%
    filter(PublicationType %in% c("Artikel, forskningsöversikt", "Artikel i tidskrift",
                                  "Bok", "Kapitel i bok, del av antologi", "Konferensbidrag"))
  return(a)
}


#' filter_publtyp_avh: tar fram endast avhandlingar (monografier och sammanläggnings) ur klumn PublicationType
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble
#'
filter_publtyp_avh <- function(divadata) {
  a = divadata %>%
    filter(PublicationType %in% c("Doktorsavhandling, monografi", "Doktorsavhandling, sammanläggning"))
  return(a)
}

#
#ContentType
#

#filter contenttype: obs att studentuppsats har Content Type NA

#' filter_content_ovrig_no: tar bort kategori "Övrig (populärvetenskap, debatt, mm)"
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_content_ovrig_no <- function(divadata) {
  a = divadata %>%
    filter(ContentType != "Övrig (populärvetenskap, debatt, mm)")
  return(a)
}


#' filter_content_ovr_vet_no: tar bort kategori "Övrigt vetenskapligt"
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_content_ovr_vet_no <- function(divadata) {
  a = divadata %>%
    filter(ContentType != "Övrigt vetenskapligt")
  return(a)
}

#
#Status
#

#' filter_status_publ_yes: tar fram publicerat material
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_status_publ_yes <- function(divadata) {
  a = divadata %>%
    filter(is.na(Status)|Status == "published")
  return(a)
}

#' filter_status_publ_no: tar fram opublicerat material
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_status_publ_no <- function(divadata) {
  a = divadata %>%
    filter(Status %in% c("accepted", "aheadofprint", "inPress", "submitted"))
  return(a)
}

#
#Year
#

#' filter_years: filtrerar på år
#'
#' @param divadata den tibble med divadata som ska filtreras
#' @param startyear det år som ska vara startpunkt för urvalet
#' @param endyear det år som ska vara slutpunkt för urvalet
#'
#' @return filtrerad tibble

filter_years <- function(divadata, startyear, endyear) {
  a = divadata %>%
    filter(Year >= startyear & Year <= endyear)
}

#
#FullTextLink
#

#' filter_fulltextlink_yes: tar fram publ med fulltextlänk
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_fulltextlink_yes <- function(divadata) {
  a = divadata %>%
    filter(!is.na(FullTextLink))
  return(a)
}

#
#PublicationSubType
#

#' filter_publsubtype_papers: tar bort de kategorier som inte är papers (abstracts, poster, presentation)
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_publsubtype_papers <- function(divadata) {
  a = divadata %>%
    filter(is.na(PublicationSubtype)|PublicationSubtype %in% c("editorialMaterial", "exhibitionCatalogue",
                                                               "letter", "meetingAbstract", "newsItem",
                                                               "publishedPaper"))
  
  return(a)
}

#
#Reviewed
#

#' filter_reviewed_yes: tar fram granskade publikationer
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_reviewed_yes <- function(divadata) {
  a = divadata %>%
    filter(Reviewed == "true")
  return(a)
}

#' filter__reviewed_no: tar fram ogranskade publikationer
#'
#' @param divadata den tibble med divadata som ska filtreras
#'
#' @return filtrerad tibble

filter_reviewed_no <- function(divadata) {
  a = divadata %>%
    filter(Reviewed == "false")
  return(a)
}

#
#Institutioner och ämnen
#

#' filter_orgs: begränsar till en organisation
#'
#' @param divadata den tibble med divadata som ska filtreras
#' @param org organisation som ska filtreras fram enligt common_diva_bibliometrics/lib/sh_parameters
#'
#' @return framfiltrerad tibble
#'
#' @examples
#' filter_orgs(diva, svenska) ger alla publikationer, författare som har organisationstillhörighet svenska
#' såsom den definieras med institutionskoder i sh_parameters

filter_orgs <- function(divadata, org) {
  list_of_orgs <- regmatches(divadata[["Name"]], gregexpr("\\[\\d+\\]", divadata[["Name"]])) #gregexpr tar flera instanser per rad
  
  #ta bort []
  list_of_orgs <- rapply(list_of_orgs, function(x){gsub("\\[", "", x)}, how = "list")
  list_of_orgs <- rapply(list_of_orgs, function(x){gsub("\\]", "", x)}, how = "list")
  list_of_orgs <- tibble(list_of_orgs)
  a <- bind_cols(divadata, list_of_orgs)
  #skapa en separat kolumn med alla orgids i divadata:
  a %>%
    filter(map_lgl(list_of_orgs, ~any(c(org) %in% .x)))
}



#' filter_orgs_author: begränsar i en organistation när underlaget divadata en rad per författare
#'
#' @param divadata den tibble med divadata som ska filtreras
#' @param org organisation som ska filtreras fram enligt common_diva_bibliometrics/lib/sh_parameters
#'
#' @return framfiltrerad tibble

filter_orgs_author <- function(divadata, org) {
  list_of_orgs <- regmatches(divadata[["OrganisationIds"]], gregexpr("\\d+", divadata[["OrganisationIds"]])) #gregexpr tar flera instanser per rad
  
  #ta bort []
  list_of_orgs <- rapply(list_of_orgs, function(x){gsub("\\[", "", x)}, how = "list")
  list_of_orgs <- rapply(list_of_orgs, function(x){gsub("\\]", "", x)}, how = "list")
  list_of_orgs <- tibble(list_of_orgs)
  a <- bind_cols(divadata, list_of_orgs)
  #skapa en separat kolumn med alla orgids i divadata:
  a %>%
    filter(map_lgl(list_of_orgs, ~any(c(org) %in% .x)))
}

# Östersjöforskning -------------------------------------------------------


#' Funktion som i en ny kolumn markerar vilka publikationer som är finansierade av Östersjöstiftelsen eller har ämnesområdet 
#' Östersjö- och Östeuropaforskning. Möjliggör senare filtrering med TRUE.
#' 
#' @param df  En data.frame med DiVA-data
#' @return    En data.frame med kolumnen baltic med värdet TRUE eller FALSE.
#' 
subject_baltic <- function(df) {
  df <- mutate(df, baltic = ifelse(grepl("Baltic", df$ResearchSubjects)|grepl("Östersjöstiftelsen", df$Funder), T, F))
}


#' Funktion som i en kolumn markera om Östersjöstiftelsen är finansiär. Möjliggör filtrering.
#' 
#' @param df En data.frame med DiVA-data
#' @return   En data.frame med kolumnen oss med värdet TRUE eller FALSE.
#' 
funder_oss <- function(df) {
  df <- mutate(df, oss = ifelse(grepl("Östersjöstiftelsen", df$Funder), T, F))
}

# Open Access -------------------------------------------------------------

#' Funtion som i en kolumn markerar om publikationen antingen har en fulltext i DiVA och/eller är länkad till en öppen resurs.
#' 
#' @param df  En data.frame med DiVA-data
#' @return    En data-frame med kolumnen oa med färdet TRUE eller FALSE.
#' 
oa_publishing <- function(df) {
  df <- mutate(df, oa = ifelse((FreeFulltext == TRUE)|(!(is.na(FullTextLink))), T, F))
}

# doaj --------------------------------------------------------------------


#' matchning mot doaj
#'
#' @param divadata den tibble med divadata som ska matchas mot DOAJ
#'
#' @return divadata med en extra kolumn där doaj-status anges

doaj_match <- function(divadata) {
  doaj_listan <- read_csv("/home/shub/assets/doaj.csv")
  divadata %>%
    mutate(JournalISSN = ifelse(is.na(JournalISSN), 0, JournalISSN)) %>%
    mutate(JournalEISSN = ifelse(is.na(JournalEISSN), 0, JournalEISSN)) %>%
    mutate(FreeFulltext = ifelse(FreeFulltext == "true", TRUE)) %>%
    select(PID, PublicationType, ContentType, Language, JournalISSN, JournalEISSN, Status, Year, FullTextLink, FreeFulltext) %>%
    filter(ContentType %in% content_type[c("a", "b")]) %>%
    filter(PublicationType %in% publication_type[c("a", "b")]) %>%
    mutate(doaj_issn = ((JournalISSN %in% doaj_listan$`Journal ISSN (print version)`)|
                          (JournalEISSN %in% doaj_listan$`Journal EISSN (online version)`)))
}


# arkivering --------------------------------------------------------------

#' Funktion för att arkivera information relaterad till en rapport för spårbarhet.
#'
#' Initialiserar ett antal globala variabler för att hålla reda på och unikt identifiera denna
#' rapport.
#'
#' @param id  En identifierare för denna typ av rapport, utan mellanslag,
#'            exempelvis "arsrapport" eller "validering-issn"
#' @return NULL
#'
sh_archive_start <- function(id) {
  XSH_timestamp <<- format(Sys.time(), "%Y%m%d-%H%M%S")
  XSH_id <<- sprintf("%s-%s", id, XSH_timestamp)
  XSH_dir <<- sprintf("/home/shub/reports/%s", XSH_id)
  dir.create(XSH_dir)
}

#' Funktion för att lägga till en data.frame till ett rapport-arkiv. Denna skrivs ner som CSV.
#'
#' @param df Den data.frame som ska läggas till
#' @param id En identifierare, utan mellanslag, exempelvis "tabell", "original", etc.
#' @return NULL
sh_archive_df <- function(df, id) {
  write.csv(df, sprintf("%s/%s.csv", XSH_dir, id))
}

#' Funktion för att lägga till en resurs (en fil) till ett rapport-arkiv. Denna kopieras som den är till
#' destinationen.
#'
#' @param f Den fil som ska kopieras
#' @return NULL
#'
sh_archive_resource <- function(f) {
  file.copy(f, XSH_dir)
}

#
#' Funktion för att avsluta arbetet med ett rapport-arkiv. Denna funktion gör inget mer än skapar
#' ett manifest över alla ingående filer i arkivet.
#'
sh_archive_end <- function() {
  write(list.files(path=XSH_dir), sprintf("%s/%s", XSH_dir, "manifest.txt"))
}

# sh_timeline -----------------------------------------------------------------

#
#tidsserier
#
 
#' Tidsserie för DiVA-data
#'
#' @param diva_csvall2_format diva-tibble i csvall2-format
#' @param spec_column kolumn att redovisa i diagram, inom citationstecken
#'
#' @return diagram

sh_timeline <- function(diva_csvall2_format, spec_column) {
  s <- diva_csvall2_format %>% #räknar förekomster
    group_by_("Year") %>%
    count_(spec_column) %>%
    ungroup() %>%
    rename_(year = "Year", n = "n", innehåll = spec_column) #för att ggplot ska fungera
  ggplot(s) +
    geom_line(aes(x = year, y = n, color = innehåll)) +
    labs(x = "publiceringsår")
  }
