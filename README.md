# common repo

This repo consists of two parts: scripts for saving data from different sources and a library (lib) with our own functions.

# Scripts for saving data to our server
## download-diva-mods
test phase. Downloads data from DiVA in mods-format.
## download-diva
runs every night. Downloads two csv-files (csvall2 and csv2) from DiVA and combines the data in 5 basefiles: author, studentessays, research publications, authors from our university, research publications from our university.
## download-norskalistan
runs every month. Downloads 2 csv-files from NSD, journals and publishers.
## download-plumx
test phase. Not cleared with API about efficient downloading. Downloads our PlumX-data gathered for Diva-publications.

# Library (lib)
library to collect our own functions.
