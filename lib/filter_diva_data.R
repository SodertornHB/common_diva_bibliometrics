#
#
#
# filter-funktioner
#CHL 170816
#filter-funktionerna filtrerar diva-data från assets: kom ihåg att välja rätt uval därifrån
#library(tidyverse)
#
#
#

# PublicationType ---------------------------------------------------------

#filter_publtyp_art_bok_kap_konf: tar fram endast art (art + forsknöversikt),
#bok, kap, och konfbidrag (med abstract etc om inte publsubtype-filter tillämpas)

filter_publtyp_art_bok_kap_konf <- function(divadata) {
  a = divadata %>%
    filter(PublicationType %in% c("Artikel, forskningsöversikt", "Artikel i tidskrift",
                                  "Bok", "Kapitel i bok, del av antologi", "Konferensbidrag"))
  return(a)
}


#filter_publtyp_avh: tar fram endast avhandlingar (monografier och sammanläggnings)
filter_publtyp_avh <- function(divadata) {
  a = divadata %>%
    filter(PublicationType %in% c("Doktorsavhandling, monografi", "Doktorsavhandling, sammanläggning"))
  return(a)
}


# ContentType -------------------------------------------------------------

#filter contenttype: obs att studentuppsats har Content Type NA

#filter_content_ovrig_no: tar bort kategori "Övrig (populärvetenskap, debatt, mm)"
filter_content_ovrig_no <- function(divadata) {
  a = divadata %>%
    filter(ContentType != "Övrig (populärvetenskap, debatt, mm)")
  return(a)
}


#filter_content_ovr_vet_no: tar bort kategori "Övrigt vetenskapligt"
filter_content_ovr_vet_no <- function(divadata) {
  a = divadata %>%
    filter(ContentType != "Övrigt vetenskapligt")
  return(a)
}


# Status ------------------------------------------------------------------

#filter_status_publ_yes: tar fram publicerat material
filter_status_publ_yes <- function(divadata) {
  a = divadata %>%
    filter(is.na(Status)|Status == "published")
  return(a)
}

#filter_status_publ_no: tar fram opublicerat material
filter_status_publ_no <- function(divadata) {
  a = divadata %>%
    filter(Status %in% c("accepted", "aheadofprint", "inPress", "submitted"))
  return(a)
}


# Year --------------------------------------------------------------------

#filter_years: filtrerar på år
filter_years <- function(divadata, startyear, endyear) {
  a = divadata %>%
    filter(Year >= startyear & Year <= endyear)
}

# FullTextLink ------------------------------------------------------------

#filter_fulltextlink_yes: tar fram publ med fulltextlänk
filter_fulltextlink_yes <- function(divadata) {
  a = divadata %>%
    filter(!is.na(FullTextLink))
  return(a)
}


# PublicationSubType -----------------------------------------------------

#filter_publsubtype_papers: tar bort de kategorier som inte är papers (abstracts, poster, presentation)
filter_publsubtype_papers <- function(divadata) {
  a = divadata %>%
    filter(is.na(PublicationSubtype)|PublicationSubtype %in% c("editorialMaterial", "exhibitionCatalogue",
                                                               "letter", "meetingAbstract", "newsItem",
                                                               "publishedPaper"))
  
  return(a)
}


# Reviewed ----------------------------------------------------------------


#filter_reviewed_yes: tar fram granskade publikationer
filter_reviewed_yes <- function(divadata) {
  a = divadata %>%
    filter(Reviewed == "true")
  return(a)
}

#filter__reviewed_no: tar fram ogranskade publikationer
filter_reviewed_no <- function(divadata) {
  a = divadata %>%
    filter(Reviewed == "false")
  return(a)
}


# Institutioner och ämnen -------------------------------------------------

filter_orgs <- function(divadata, org) {
  source('/home/shub/assets/shorgs.R')
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
