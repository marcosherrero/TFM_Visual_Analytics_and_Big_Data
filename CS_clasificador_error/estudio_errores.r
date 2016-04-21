os<-read.csv("datos_caso_uso_2.csv", sep="|", fileEncoding="UTF-8-BOM")

#cargamos en otra variable las columnas que nos interesan: 11,12 y 14 
# que corresponden con los sensores: iat,maf,frf y egb
datos2 <-data.frame(iat=lapply(datos[11],as.numeric),
                    maf=lapply(datos[12],as.numeric),
                    frf=lapply(datos[13], as.numeric),
                    egr=lapply(datos[14],as.numeric),
                    coderror=lapply(datos[19],as.numeric))

#damos nombre a las columnas:
colnames(datos2)<-c("iat","maf","frf","egr","coderr")

#calculamos la mediana, la media, primer y tercer cuartil y 
# los valores minimo y maximo
summary(datos2[-5])

#Mostramos la gráfica de la caja bigotes para representar la media, 
# los cuartiles 1, 3 y aquellos valores que están fuera del rango.
boxplot(datos2[-5])

#aplicamos el algoritmo de clasificacion kmeans a las columnas maf y codigo error
modelo.kmeans <- kmeans((datos2$maf & datos2$coderr),2)

#comprobamos el resultado de la clasificacion, debe llegar o acercarse al 100%, de lo contrario
# hay que seguir probando apliando los cluster hasta dar con el porcentaje mas alto.
modelo.kmeans

#Añadimos a los datos generales el campo generado por el algoritmo:
datos$cluster <- modelo.kmeans$cluster
write.csv(datos,'datos_caso_uso_2.csv',row.names=F)
