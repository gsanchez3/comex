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
ruta <- paste0(ruta_pc,"Documents/Cep Pedidos/Exportaciones por provincia/renueva_datos/")
setwd(ruta)

# Seteamos ruta de bases
ruta_bases <- "C:/Users/Usuario/Documents/Bases CEP XXI/"

# Seteamos ruta de las bases que abro
ruta_insumos <- "C:/Users/Usuario/Documents/Cep Pedidos/Exportaciones por provincia/arma_bases_final/"



# Voy a armar una lista con los años para ir llamando a casos_enes año por año. 
#lista_anios <- seq(2015, 2023, by = 1)
lista_anios <- c(2024)


# Ahora con las posiciones ya corregidas mergeo la nueva base descargada para corregirla

bases <- list.files(ruta,  pattern='*.DBF',
                    full.names = T)

bases_impo <- bases[str_detect(bases, 'IMPO24')==T]
bases_expo <- bases[str_detect(bases, 'EXPO24')==T]



for (i in 1:length(bases_impo)){
  tmp_impo <- setDT(read.dbf(bases_impo[i]))
  #tmp_impo$NOMBRE <- NULL
  tmp_impo$DESTINAC <- NULL
  #tmp_impo$ORIGEN <- NULL
  
  
  
  tmp_impo <- tmp_impo[(DEST != 'IT01') & (DEST != 'IT04') &
                         (DEST != 'IT05') & (DEST != 'IT03') &
                         (DEST != 'TG04')& (DEST != 'IT06') &
                         (DEST != 'TG05')& (DEST != 'TG06')]
  
  tmp_impo$DEST <- NULL
  
  names(tmp_impo) <- tolower(names(tmp_impo))
  tmp_impo <- tmp_impo[, anyo:= as.character(anyo)]
  tmp_impo <- tmp_impo[, posic_sim := substr(posic_sim, 1, 11)]
  
  
  # Ahora solo resta colapsar por todas las variables que quiero guardar y debe quedar igual en extension a la version
  # descargada por esas variables luego de filtrar las temporales 
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
}






# Actualizo tambien las bases de expo


for (i in 1:length(bases_expo)){
  tmp_expo <- setDT(read.dbf(bases_expo[i]))
  tmp_expo$DESTINAC <- NULL
  
  # elimino las destinaciones temporales
  
  tmp_expo <- tmp_expo[(DEST != 'EC02') & (DEST != 'EG02') &
                         (DEST != 'ZFE4') & (DEST != 'ZFTR') &
                         (DEST != 'RR01')]
  
  tmp_expo$DEST <- NULL
  
  names(tmp_expo) <- tolower(names(tmp_expo))
  tmp_expo <- tmp_expo[, anyo:= as.character(anyo)]
  tmp_expo <- tmp_expo[, posic_sim := as.character(posic_sim)]
  
  
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
