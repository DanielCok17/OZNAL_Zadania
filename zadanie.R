# Načítanie potrebných knižníc
library(ggplot2)
library(tidyverse)
library(tidymodels)
library(lobstr)
install.packages("magrittr")

library(magrittr)

getwd() # Find where you are
setwd("/Users/danielcok/xcok/4.semester/OZNAL/Zadanie") # Set the correct path to players_22.csv
list.files() # List all files in the working directory

# Načítanie datasetu
data <- read_delim("NHL_Players_Statistics.csv", delim = ";", col_names = TRUE)

problems(data)

data

colnames(data)

summary(data$Goals)
summary(data$Assists)

# Základný plot pre kontrolu stĺpcov Goals a Assists
plot(data$Goals, data$Assists, main = "Basic Scatter Plot", xlab = "Goals", ylab = "Assists")
plot(data$Goals, data$Points, data$Losses, data$Saves, data$Height, data$Age, data$Weight)
data %<>% select(Goals, Points, Losses, Saves, Height, Age, Weight)
plot(data)































#Definovanie Hypotéz:
#  
#  Pre Regresiu: Môžeme skúmať, či počet gólov ovplyvňuje celkový počet bodov hráča v sezóne.
#Pre Klasifikáciu: Môžeme klasifikovať hráčov na základe ich pozície (útočník, obranca, brankár) na základe ich štatistík, ako sú počet gólov, asistencí, streľby atď.
#Úprava a Vyčistenie Datasetu:
#  
#  Odstránenie chýbajúcich hodnôt.
#Konverzia dátových typov, ak je to potrebné.
#Vytvorenie nových premenných, ktoré môžu pomôcť pri modelovaní, napríklad výpočet úspešnosti streľby.
#Výber Atribútov a Metód:
#  
#  Rozhodnutie, ktoré premenné budú slúžiť ako vstup pre regresný a klasifikačný model.
#Výber metód pre regresiu (napr. lineárna regresia) a klasifikáciu (napr. logistická regresia, rozhodovacie stromy).
#Vyhodnocovanie Modelov:
#  
#  Definovanie vhodných metrík pre regresné modely (napr. RMSE, R²) a klasifikačné modely (napr. presnosť, F1 skóre).
#Použitie krížovej validácie pre odhad výkonnosti modelov.
