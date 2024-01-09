rm(list = ls())

library(data.table)
library(tidyverse)
library(fst)
library(openxlsx) 
library(Mectritas)
library(foreign)
library(readxl)
options(scipen=999) 

# Seteamos ruta general
ruta_pc <- "C:/Users/Usuario/"
ruta <- paste0(ruta_pc,"Documents/Cep Pedidos/Exportaciones por provincia/arma_bases_final/")
setwd(ruta)

# Seteamos ruta de bases
ruta_bases <- "C:/Users/Usuario/Documents/Bases CEP XXI/"

# Vamos a usar todas las bases descargadas entre el 94 y el 2014

bases_impo_aduana <- list.files(paste0(ruta, "impo2/"),
                                pattern='*.DBF',
                                full.names = T)

# Voy a armar una lista con los años para guardar los nombres
lista_anios <- seq(1994, 2014, by = 1)


for (i in 1:length(bases_impo_aduana)){
  tmp_impo <- setDT(read.dbf(bases_impo_aduana[i]))
  tmp_impo$DESTINAC <- NULL

  # elimino las destinaciones temporales
  
  tmp_impo <- tmp_impo[(DEST != 'IT01') & (DEST != 'IT04') &
                         (DEST != 'IT05') & (DEST != 'IT03') &
                         (DEST != 'TG04')& (DEST != 'IT06') &
                         (DEST != 'TG05')& (DEST != 'TG06')]
  
  tmp_impo$DEST <- NULL
  
  names(tmp_impo) <- tolower(names(tmp_impo))
  tmp_impo <- tmp_impo[, anyo:= as.character(anyo)]
  tmp_impo <- tmp_impo[, posic_sim := as.character(posic_sim)]
  
  # De 1994 a 1998 todas las posiciones se dejarán a 8 dígitos (Recien a partir de 1999 aparecen completos)
  
  if (i %in% 1:5) {
    tmp_impo <- tmp_impo[, posic_sim := substr(posic_sim, 1, 8)]
  }
  
  # Ahora solo resta colapsar por todas las variables que quiero guardar por las dudas que alguna destinacion distinta
  # me repita una observacion
  
  tmp_impo <- tmp_impo %>% rename(cuit = cuit_impor)
  
  tmp_impo <- tmp_impo[,. (fob= sum(fob, na.rm= T), kilos= sum(kilos, na.rm=T), 
                           cant_unest= sum(cant_unest, na.rm=T), cif= sum(cif, na.rm=T)), 
                       by = c('anyo', 'um_estad', 'umed_estad', 'porg', 'origen', 'mes', 'cuit', 'nombre', 'posic_sim')]
  
  # Ya tengo la base final deseada, voy a exportarla en dta, csv y en fst
  
  write.csv(tmp_impo, paste0(ruta_bases, 'COMEX/impo_csv/i', lista_anios[i], '.csv'), row.names=F)
  write.fst(tmp_impo,paste0(ruta_bases, 'COMEX/impo/i', lista_anios[i], '.fst'), compress=100)
  write.dta(tmp_impo, paste0(ruta_bases, 'COMEX/impo_dta/i', lista_anios[i], '.dta'))
  
  
  rm(tmp_impo)
  print(lista_anios[i])
  gc()
}








############## Lo mismo pero con las exportaciones


# Vamos a usar todas las bases descargadas entre el 94 y el 2014

bases_expo_aduana <- list.files(paste0(ruta, "expo/"),
                                pattern='*.DBF',
                                full.names = T)

# Voy a armar una lista con los años para guardar los nombres
lista_anios <- seq(1994, 2023, by = 1)


for (i in 1:length(bases_expo_aduana)){
  tmp_expo <- setDT(read.dbf(bases_expo_aduana[i]))
  tmp_expo$DESTINAC <- NULL
  
  # elimino las destinaciones temporales
  
  tmp_expo <- tmp_expo[(DEST != 'EC02') & (DEST != 'EG02') &
                                  (DEST != 'ZFE4') & (DEST != 'ZFTR') &
                                  (DEST != 'RR01')]
  
  tmp_expo$DEST <- NULL
  
  names(tmp_expo) <- tolower(names(tmp_expo))
  tmp_expo <- tmp_expo[, anyo:= as.character(anyo)]
  tmp_expo <- tmp_expo[, posic_sim := as.character(posic_sim)]
  
  # De 1994 a 1998 todas las posiciones se dejarán a 8 dígitos (Recien a partir de 1999 aparecen completos)
  
  if (i %in% 1:5) {
    tmp_expo <- tmp_expo[, posic_sim := substr(posic_sim, 1, 8)]
  }
  
  # Ajusto manualmente la posicion de satelites, tengo que quitar esa posicion de las expo
  
  if (i %in% c(21, 22, 25, 27)) {
    tmp_expo <- tmp_expo[posic_sim != '88026000000']
  }
  
  # Ahora solo resta colapsar por todas las variables que quiero guardar por las dudas que alguna destinacion distinta
  # me repita una observacion
  
  tmp_expo <- tmp_expo %>% rename(cuit = cuit_expor)
  
  tmp_expo <- tmp_expo[,. (fob= sum(fob, na.rm= T), kilos= sum(kilos, na.rm=T), 
                           cant_unest= sum(cant_unest, na.rm=T)), 
                       by = c('anyo', 'um_estad', 'umed_estad', 'pdest', 'destino', 'mes', 'cuit', 'nombre', 'posic_sim')]
  
  # Ya tengo la base final deseada, voy a exportarla en dta, csv y en fst
  
  write.csv(tmp_expo, paste0(ruta_bases, 'COMEX/expo_csv/e', lista_anios[i], '.csv'), row.names=F)
  write.fst(tmp_expo,paste0(ruta_bases, 'COMEX/expo/e', lista_anios[i], '.fst'), compress=100)
  write.dta(tmp_expo, paste0(ruta_bases, 'COMEX/expo_dta/e', lista_anios[i], '.dta'))
  
  
  rm(tmp_expo)
  print(lista_anios[i])
  gc()
}

