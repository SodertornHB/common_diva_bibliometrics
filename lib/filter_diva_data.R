# filter-funktioner
#CHL 170816
#filter-funktionerna filtrerar diva-tibbles i shub-assets

#filter_ref_ovr_vet: övrigt vet och refgr
filter_ref_ovr_vet <- function(x) {
  library(tidyverse)
  a = x %>%
    filter(ContentType != "Övrig (populärvetenskap, debatt, mm)")
  return(a)
}

filter_konf_publ <- function(x) {
  library(tidyverse)
  a = x %>%
    filter(is.na(PublicationSubtype)|PublicationSubtype %in% c("editorialMaterial", "exhibitionCatalogue", "letter", "meetingAbstract", "newsItem", "publishedPaper"))
    
  return(a)
}
csvall2 <- read_csv("/home/shub/assets/diva/diva_researchpubl_df_latest.csv")
test <- filter_konf_publ(csvall2)
