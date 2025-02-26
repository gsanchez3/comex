Este repositorio contiene dos carpetas.

Arma-bases: tiene los codigos para identificar los casos de ENES en la importacion y repararlos. Y luego el codigo que arma las versiones reparadas de todas las bases de Expo
e impo de todos los años entre 1994 y 2023


Las posiciones ENES se encuentran corregidas hasta octubre de 2023, fecha del ultimo dato aportado por Indec. En caso que indec aporte una informacion mas actual deberan
correrse los codigos desde el primero observando las diferencias con el formato en que aporten la nueva informacion.

actualizar-mensual: tiene el codigo que se debe correr todos los meses despues de descargar las bases de aduana del ultimo año. Alli hay dos codigos:

renueva_bases: incluye la renovación de bases de comex para el caso del 2023 y le corrije los datos de comex

renueva_bases_v2: para renovar las bases de expo e impo a partir del 2024, sin considerar las impo y expo temporales sin transformación. No hace problemas o cambios con respecto a las ENES.
