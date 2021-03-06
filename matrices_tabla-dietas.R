###########################################################
#Este c�digo tiene como fin crear tres matrices: Matriz base (Mb), Matriz multiestado (Mm), Matriz binaria 1, 2 y 3 (B1, B2 y B3, respectivamente) derivadas de la Tabla de dietas cruda, la cual contiene los reportes de dieta obtenidos para todas las especies junto con su fuente en la literatura.

#Estos reportes de dieta est�n dados por la cantidad de individuos utilizados en los trabajos revisados. Siguiendo esto, se construir�n tres tablas complementarias distintas, basadas en la Tabla de dietas cruda; con estas tablas se crear�n las matrices Mb, Mm, B1, B2 y B3, es decir, habr�n tres r�plicas de cada matriz.

#Matriz base - Mb: esta matriz cuenta con 5 caracteres: Insectivor�a, Carnivor�a, Hematofagia, Frugivor�a y Nectarivor�a; y 4 estados: Ausente (0), Complementario (1), Predominante (2) y Estricto (3). La asignaci�n de estados depender� de la frecuencia de reporte de la dieta por especie, es decir, si una especie presenta una frecuencia de reporte de alguna dieta (car�cter) en menos de 0.05, se considera que esta dieta est� ausente (0) en la epecie; si la frecuencia est� entre 0.05 y 0.5 se considera que la dieta es complementaria (1) en la especie; por otro lado, si la frecuencia es mayor a 0.5 y menor a 0.95, la dieta se asume como predominante (2) en la especie; y si esta frecuencia es mayor o igual a 0.95, asignamos la especie como estricta (3) a dicho h�bito alimenticio. De esta matriz derivar�n las dem�s matrices.

#Matriz multiestado - Mm: esta matriz cuenta con un solo caracter, dieta, y 5 estados: Insectivor�a (0), Carnivor�a (1), Hematofagia (2), Frugivor�a (3) y Nectarivor�a (4). Para construir esta matriz se asignar� a cada especie la dieta (estado) que en Mb sea complementaria o estricta. En caso de que presente solo dietas complementarias, en Mb, se tendr� en cuenta la dieta con mayor frecuencia de reporte para la especie.

#Matrices binarias: estas matrices tendr�n 5 car�cteres: Insectivor�a, Carnivor�a, Hematofagia, Frugivor�a y Nectarivor�a, y los estados ser�n ausente (0) y presente (0). Las matrices ser�n contruidas bajo la misma norma, pero distinto grado de estrictez.La matriz binaria 1 (B1) considerar� las dietas complementarias, predominantes y estrictas, en Mb, de la especie como presentes (1). Para la matriz binaria 2 (B2) las dietas predominantes y estrictas, en Mb, ser�n asignadas como presentes en las especies, pero no las complementarias que ser�n ausentes. Por �ltimo, la matriz B3 ser� construida �nicamente con las dietas estrictas, de Mb, como presentes en las especies, y las dietas complementarias y predominantes se considerar�n ausentes. Para todas las matrices binarias, las dietas ausentes en Mb ser�n tomadas como ausentes tambi�n.

# Para organizar el script ennumerar� cada uno de los pasos secuencialmente en orden como deben ser desarrollados (?).
###########################################################

library(readxl)
library(dplyr)

setwd('C:/Users/Papra/Documents/Trabajo de Grado/Dietas')

# Paso 1 - Llamada de la Tabla de dietas cruda
tablaDietas <- read_xlsx('Tabla_dietas.xlsx',guess_max = 10000) ###guess_max es para indicar el n�mero m�ximo de filas de datos que se utilizar�n para adivinar tipos de columnas (seg�n R)


# Paso 2 - Para organizar mejor la informaci�n, en la columna "Reportes" de tablaDietas, dividiremos los nombres de las especies y los reportes en dos columnas distintas: Especie y Reporte, los cuales est�n separados con un gui�n "-", en un objeto llamado tmp1, que despu�s ser� el data frame, tmp2. Seguido de esto, crearemos un objeto llamado tmp3 que contenga �nicamente las columnas de los trabajos usados con la informaci�n de los reportes, para unirlo con tmp1 y crear tablaDietas2.
tmp1 <- strsplit(tablaDietas$Reportes,"-")

## Paso 2.1 - Data frame con los nombres de las especies y de los reportes.
temp2 <- as.data.frame(matrix(unlist(tmp1),ncol= 2,byrow = T))

names(temp2) <- c("Especie","Reporte")

## Paso 2.2 - Data frame de la informaci�n de cada trabajo revisado.
temp3 <- as.data.frame(tablaDietas[,2:length(tablaDietas[1,])])

## Paso 2.3 - Creaci�n de tablaDietas2.
tablaDietas2 <- cbind(temp2,temp3)


# Paso 3 - En este paso crearemos un dataframe con �nicamente los reportes de dieta. Ya que en la Tabla de dietas cruda (tablaDietas y tablaDietas2) hay reportes de fuentes alimenticias como materia vegetal no identificada, polen y nectar-polen, y el n�mero de reportes por tipo de evidencia, es necesario agrupar �nicamente los reportes de las dietas Insectivor�a, Carnivor�a, Hematofagia, Frugivor�a y Nectarivor�a.
tablaDietas3 <- tablaDietas2[!tablaDietas2$Reporte %in% c('obs','matVeg','contEst','heces','is�topos','nect','poli'),]

# Paso 4 - Ya que no todas las especies cuentan con reportes, eliminamos las que a�n no tienen creando un nuevo dataframe con estas caracter�sticas llamado tablaDietas3. Adem�s, para un mejor manejo de los datos cambiaremos los valores de NA a 0.
tablaDietas3 <- tablaDietas3[-which(is.na(tablaDietas3$'1')),]

## Paso 4.2 - Paso de valores de NA a 0.
tablaDietas3[is.na(tablaDietas3)]=0

# Paso 5 - Organizamos los valores de las filas del dataframe par que sean continuos.
rownames(tablaDietas3) <- 1:nrow(tablaDietas3)


# Paso 6 - Crearemos la primera tabla complementaria llamada matrizIncidencias. Iniciando, esta ser� un duplicado de tablaDietas3. Esta tabla considerar� el n�mero de individuos de los reportes como binarios, entonces las celdas con n�meros de individuos ser�n cambiadas a 1, y los 0 se mantendr�n iguales.
matrizIncidencias <- tablaDietas3

## Paso 6.1 - Cambio de reportes continuos a binarios.
for (columnas in 3:length(tablaDietas3[1,])) {
  for (filas in 1:length(tablaDietas3[,1])) {
    if (matrizIncidencias[filas,columnas]>0) {
      matrizIncidencias[filas,columnas]=1
    }
  }
}
########puedo hacer eso con solo llamar esos valores del dataframe


# Paso 7 - Para hacer la Matriz base, crearemos una tabla preliminar, el dataframe matrizBasePrem, con las mismas especies y nombres de los reportes que tablaDietas3, m�s y 4 columnas adicionales con vaolres de 0: Conteo, Sumatoria, Frecuencia y Estado. Los valores de la columna Conteo har�n referencia a la cantidad de reportes de cada dieta para cada especie; los valores de Sumatoria, como su nombre lo indica, es la suma total de reportes de dieta por especie; la columna de Frecuencia contar� con los valores de frecuencia de reporte de dietas (Conteo) dada la cantidad de reportes totales para la especie (Sumatoria); y por �ltimo, la columna Estado tendr� los estados de cada dieta siguiendo la regla mencionada al inicio del script.
matrizBasePrem <- data.frame('Especie'= tablaDietas3$Especie,'Reporte'= tablaDietas3$Reporte, 'Conteo' = 0,'Sumatoria'=0,'Frecuencia'=0,'Estado'=0)


## Paso 7.1 - Columna Conteo. Asignaremos los valores a la  con la suma de los reportes por dieta para cada especie.
for (i in 1:length(tablaDietas3$Especie)) {
  matrizBasePrem[i,3]=sum(matrizIncidencias[i,3:length(tablaDietas3[1,])],na.rm = T)
}


## Paso 7.2 - Columna Sumatoria. Suma de reportes totales por especie en un nuevo objeto 
suma <- matrizBasePrem %>% group_by(Especie) %>% summarize(Sumatoria=sum(Conteo)) # Ctrl + Shift + M = %>% 


### Paso 7.2.1 - Columna Sumatoria. Ya que todas las especies cuenta con 5 filas, cada una con una dieta, en la columna Sumatoria repetimos los valores del objeto suma 5 veces para cada especie.
matrizBasePrem$Sumatoria=rep(suma$Sumatoria,each=5)


## Paso 7.3 - Columna Frecuencia. Para continuar con la construcci�n de la Matriz base, en este paso calcularemos la fecuancia de reporte de cada dieta por especie.
for (i in 1:length(matrizBasePrem$Especie)) {
  matrizBasePrem[i,5] <-  round(matrizBasePrem[i,3]/matrizBasePrem[i,4],digits=3)
}


## Paso 7.4 - Columna Estado. Ya teniendo la frecuencia de reporte de cada dieta, les asignaremos un estado con respecto a la regla mencionada al inicio del script, donde la dieta puede ser Ausente (0), Complementaria (1), Predominante (2) o Estricta (3) en las especies. 

frecuencia1 <- 0.05
frecuencia2 <- 0.5
frecuencia3 <- 0.95

for (i in 1:length(matrizBasePrem$Especie)) { 
  if (matrizBasePrem[i,5]<frecuencia1) {
    matrizBasePrem[i,6]=0
  } 
  else if (matrizBasePrem[i,5]==frecuencia1){
    matrizBasePrem[i,6]=0
  }
  else if (matrizBasePrem[i,5]>frecuencia1&matrizBasePrem[i,5]<frecuencia2){
    matrizBasePrem[i,6]=1
  }
  else if (matrizBasePrem[i,5]==frecuencia2){
    matrizBasePrem[i,6]=1
  }
  else if (matrizBasePrem[i,5]>frecuencia2&matrizBasePrem[i,5]<frecuencia3){
    matrizBasePrem[i,6]=2
  }
  else if (matrizBasePrem[i,5]==frecuencia3){
    matrizBasePrem[i,6]=3
  }
  else if (matrizBasePrem[i,5]>frecuencia3){
    matrizBasePrem[i,6]=3
  }
} 


# Paso 8 - Matriz base. Ya que contamos con los estados de dieta en cada especie, construiremos un dataframe cuyas filas ser�n las especies, las columnas las dietas y los estados los valores que conpongan el contenido dentro de estas.
matrizBasePrem2 <- data.frame('Especie'=matrizBasePrem$Especie,'Dieta'=matrizBasePrem$Reporte,'Estados'=matrizBasePrem$Estado)

# Paso 8.1 - Como los reportes de dieta est�n organizados como filas para cada especie, traspondremos la matrizBasePrem2 de tal forma que hayan 6 columnas, una con los nombres de las especies y las 5 siguientes con las dietas. Este nuevo dataframe, matrizBase, se compondr� de los estados de dieta por especie.
matrizBase1 <- matrix(matrizBasePrem2[,3],nrow = 85,ncol = 5,byrow = T)

matrizBase <- data.frame('Especie'=unique(matrizBasePrem2$Especie), 'Insectivor�a'=matrizBase1[,1], "Carnivor�a"=matrizBase1[,2],"Hematofagia"=matrizBase1[,3],"Frugivor�a"=matrizBase1[,4],"Nectarivor�a"=matrizBase1[,5])


# Paso 9 - Matriz multiestado: matrizMultiestado. En este paso asignaremos las dietas predominantes (2) o estrictas (3) obtenidas en la matrizBase para cada especie. Es decir, las filas ser�n las especies y habr�n dos columnas, una con los nombres de las especies, llamada Especie, y la segunda, Dieta, con los valores de estado que ser�an las dietas: Insectivor�a (0), Carnivor�a (1), Hematofagia (2), Frugivor�a (3) y Nectarivor�a (4).

matrizMultiestado <- data.frame('Especie'= unique(matrizBase$Especie),'Dieta'=0)

for (i in 1:length(matrizMultiestado$Especie)) {
  if (matrizBase[i,2]==3) {
    matrizMultiestado[i,2]=0
  }
  else if (matrizBase[i,2]==2) {
    matrizMultiestado[i,2]=0
  }
  if (matrizBase[i,3]==3) {
    matrizMultiestado[i,2]=1
  }
  else if (matrizBase[i,3]==2) {
    matrizMultiestado[i,2]=1
  }
  if (matrizBase[i,4]==3) {
    matrizMultiestado[i,2]=2
  }
  else if (matrizBase[i,4]==2) {
    matrizMultiestado[i,2]=2
  }
  if (matrizBase[i,5]==3) {
    matrizMultiestado[i,2]=3
  }
  else if (matrizBase[i,5]==2) {
    matrizMultiestado[i,2]=3
  }
  if (matrizBase[i,6]==3) {
    matrizMultiestado[i,2]=4
  }
  else if (matrizBase[i,6]==2) {
    matrizMultiestado[i,2]=4
  }
}


# Paso 10 - Matriz binaria 1: matrizBinaria1. Para construir esta matriz consideraremos las dietas complementarias (1), predominantes (2) y estrictas (3) de la matrizBase, dietas que ser�n codificadas como presentes (1). Las dietas ausentes (0) en la matrizBase se mantendr�n con esa misma codificaci�n en la matrizBinaria1.

matrizBinaria1 <- data.frame('Especie'=matrizBase$Especie, 'Insectivor�a'=0, "Carnivor�a"=0,"Hematofagia"=0,"Frugivor�a"=0,"Nectarivor�a"=0)

for (rows in 1:length(matrizBase$Especie)) {
  for (colums in 2:6) {
    if (matrizBase[rows,colums]==0) {
      matrizBinaria1[rows,colums]=0
    }
    else if (matrizBase[rows,colums]>0) {
      matrizBinaria1[rows,colums]=1
    }
  }
}

# Paso 11 - Matriz binaria 2: matrizBinaria2. Similar a la matrizBinaria1, esta matriz codifica las dietas predominantes y estrictas como presentes en la especie, m�s las dietas complementarias, al igual que las asuentes, las toma como ausentes.

matrizBinaria2 <- data.frame('Especie'=matrizBase$Especie, 'Insectivor�a'=0, "Carnivor�a"=0,"Hematofagia"=0,"Frugivor�a"=0,"Nectarivor�a"=0)

for (rows in 1:length(matrizBase$Especie)) {
  for (colums in 2:6) {
    if (matrizBase[rows,colums]<1) {
      matrizBinaria2[rows,colums]=0
    }
    else if (matrizBase[rows,colums]>1) {
      matrizBinaria2[rows,colums]=1
    }
  }
}


# Paso 12 - Matriz binaria 3: matrizBinaria3. A diferencia de las matrices matrizBinaria1 y matrizBinaria2, esta matriz solo codificar� como presente las dietas estrictas de matrizBase.

matrizBinaria3 <- data.frame('Especie'=matrizBase$Especie, 'Insectivor�a'=0, "Carnivor�a"=0,"Hematofagia"=0,"Frugivor�a"=0,"Nectarivor�a"=0)

for (rows in 1:length(matrizBase$Especie)) {
  for (colums in 2:6) {
    if (matrizBase[rows,colums]<2) {
      matrizBinaria3[rows,colums]=0
    }
    else if (matrizBase[rows,colums]>2) {
      matrizBinaria3[rows,colums]=1
    }
  }
}


# Tabla complementaria 1: individuos. En esta tabla se mantendran los valores de individuos reportados para luego construir las dem�s matrices.

# Tabla complementaria 3: frcuencias. Para esta tabla se considerar�n las frecuencias de los n�meros de indiviuos reportados.





