
sh.filter <- function(df, ...) {
  # Applicerar ett dplyr::filter på en data.frame och gör samtidigt en notering (i samma data.frame)
  # om vilket filter som gjorde att en specifik rad filtrerades bort. Funktionen använder kolumnerna
  # "Filtered" och "Filter" som tillfälliga kolumner för att hålla ordning på informationen. Dessa
  # kolumner skapas om de inte finns. Det finns inga garantier för att en returnerad data.frame är
  # sorterad på samma sätt som den ursprungliga.
  #
  # Argument:
  #     df: En data.frame, lämpligen DiVA-data men funktionen fungerar för alla varianter av data.frames
  #    ...: Ett eller flera uttryck som skickas omodifierade till dplyr::filter, ex.v.
  #              PublicationType != "Artikel"
  #
  # Returvärde:
  #   En data.frame där filtrerade rader är noterade med TRUE i kolumnen "Filtered" och där kolumnen
  #   "Filter" innehåller det exakta uttryck som gjorde att de filtrerades bort.
  #
  # Exempel på användning:
  #
  # x <- data.frame(PID = c(123456,789012,345679),
  #                 PublicationType = c("Artikel", "Artikel", "Doktorsavhandling, monografi"),
  #                 Name = c("Test Testsson", "Test Josesson", "Test Abrahamsson"))
  # x <- sh.filter(x, PublicationType != "Artikel")
  # x <- sh.filter(x, PID != 345679)
  #
  # [x]
  #     PID              PublicationType             Name Filtered                       Filter
  # 1 123456                      Artikel    Test Testsson     TRUE PublicationType != "Artikel"
  # 2 789012                      Artikel    Test Josesson     TRUE PublicationType != "Artikel"
  # 3 345679 Doktorsavhandling, monografi Test Abrahamsson     TRUE                PID != 345679
  #
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

sh.filter.result <- function(df) {
  #
  # Efter användningen av sh.filter innehåller en data.frame både sådana rader som har blivit bort-
  # filtrerade och anledningen bakom det. Denna funktion tar en data.frame från sh.filter och
  # plockar bort rader som har blivit filtrerade och tar även bort kolumnerna "Filter" och
  # "Filtered"
  #
  W <-dplyr::filter(df, Filtered != TRUE)
  W$Filter <- NULL
  W$Filtered <- NULL
  return(W)
}
