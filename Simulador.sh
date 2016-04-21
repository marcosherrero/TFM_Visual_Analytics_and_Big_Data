#!/bin/bash

#definicion de variables publicas:
respuesta=0
respuestaAcelerar=0
respuestaFrenar=0
velocidad=0
segundosInicio=`date +%s`

controlInicio=1
procesoSegundoPlano=0
tipoConduccion=0 #1->deportiva|0->normal
codigoMotor=`echo $RANDOM`

controlRespuestaConduccion=0

pesoVehiculoActual=0
bultos=0 #numero total de bultos
pasajeros=0 #numero total de ocupantes
respuestaPeso=0

codigoError=0

#valores Geolocalizacion:
longitude=""
latitude=""

#Parametros de configuracion del vehiculo:
pesoMaximoAutorizadoVehiculo=0
pesoVehiculoVacio=0
bultosMaximoPermitido=0
pasajerosMaximoPermitido=0


function pintarOpcionesMenu(){
	echo "#--------------------------------------------#"
	echo "#|      SIMULADOR DE CONDUCCION KLEPPER     |#"
	echo "#|                                          |#"
	echo "#| Seleccione una opcion                    |#"
	echo "#|  1.Acelerar                              |#"
	echo "#|  2.Frenar	                            |#"
	echo "#|  3.Annadir pasajero (conductor)          |#"
	echo "#|  4.Annadir bulto                         |#"
	echo "#|  5.Notificar error                       |#"
	echo "#|  6.Notificar accidente                   |#"
	echo "#|  0.Salir                                 |#"
	echo "#--------------------------------------------#"
	echo "#| Informacion:                             |#"
	echo "#|  pesoMax:"${pesoMaximoAutorizadoVehiculo}" pesoActual:"${pesoVehiculoActual}"           |#"
	echo "#|  pasajerosMax:"${pasajerosMaximoPermitido}" pasajerosActual:"${pasajeros}"         |#"
	echo "#|  bultosMax:"${bultosMaximoPermitido}" bultosActual:"${bultos}"             |#"
	echo "#--------------------------------------------#"
	echo "    Numero de Bastidor: "${bastidor}         
	echo "    Cod. Motor: "${codigoMotor}
	echo "#--------------------------------------------#"
	if [ ${velocidad} -gt 0 ]
	then
		echo "   VELOCIDAD ACTUAL: "${velocidad}" kms/h"  
	fi
	echo "#--------------------------------------------#"
	echo "  Indique la opcion elegida:"
	read respuesta
	return
}
function pintarOpcionesMenuAcelerar(){
	eleccion=
	echo "#--------------------------------------------#"
	echo "#| 1.Elige estilo Conducc.(a.Deport)(b.Norm)|#" 
	echo "#| 0.Salir                                  |#"
	echo "#--------------------------------------------#"
	echo "Indica la velocidad maxima a acelerar, estilo de conduccion o seleccione 0 para Salir:"
	read eleccion
	
	if [ "${eleccion}" = "a" -o "${eleccion}" = "b" ]
	then
		if [ "${eleccion}" = "a" ]
		then
			let tipoConduccion=1
		else
			let tipoConduccion=0
		fi
		let controlRespuestaConduccion=1
	else
		let respuestaAcelerar=${eleccion}	
	fi
	return
}
function pintarOpcionesMenuFrenar()
{
	captura=0
	
	echo "#--------------------------------------------#"
	echo "#|  999.Salir                               |#"
	echo "#--------------------------------------------#"
	echo "Indica la velocidad a frenar o seleccione 999 para Salir:"
	read captura
	
	if [ ${captura} -gt 0 ]
	then
		let respuestaFrenar=`echo ${captura}`
	fi
	return
}
function pintarMenuAnnadirPeso ()
{
	captura=0
	
	echo "#--------------------------------------------#"
	echo "#|  0.Salir                                 |#"
	echo "#--------------------------------------------#"
	echo "Indicar el peso:"
	read captura
	
	if [ ${captura} -gt 0 ]
	then
		let respuestaPeso=`echo ${captura}`
	fi
	return 
}
function pintarTrazaArranqueMotor()
{
	fecha=`date "+%Y-%m-%d"`
	hora=`date "+%H:%M:%S"`
	echo ${bastidor}"|"${codigoMotor}"|"${fecha}" "${hora}"|0|0|0|0|0|0|"${pesoVehiculoVacio}"|0|0|0|0|0|0|0|0|0|0|"${latitude}"|"${longitude} >>./${bastidor}.csv
	return
}
function pintarMenuNotificacionError()
{
	captura=0
	
	echo "#--------------------------------------------#"
	echo "#|  1.Fallo MAF (Error 180)                 |#"
	echo "#|  2.Fallo EGR (Error 403)                 |#"
	echo "#|  3.Fallo IAT (Error 110)                 |#"
	echo "#|  4.Fallo FRF (Error 89)                  |#"
	echo "#|  0.Salir                                 |#"
	echo "#--------------------------------------------#"
	echo "Indicar Codigo de Error:"
	read captura
	
	
	if [ "${captura}" == "1" ]
	then
		let codigoError=180
	elif [ "${captura}" == "2" ]
	then
		let codigoError=403
	elif [ "${captura}" == "3" ]
	then
		let codigoError=110
	elif [ "${captura}" == "4" ]
	then
		let codigoError=89	
	fi
	return
}
function obtenerGeolocalizacion()
{
	#fichero contenedor de rutas GPS: geolocalizador.csv
	#El fichero contiene filas con 2 colunmas separadas por '|', la primera columna muesta la latitud y en la segunda columna muestra la longitud
	tamanno=`cat geolocalizacion.csv|wc -l`
	numeroFilaBuscar=`shuf -i 1-${tamanno} -n 1`
	numeroFila=0
	
	while read linea
	do
		let numeroFila=`expr ${numeroFila}\+1`
		if [ "${numeroFila}" == "${numeroFilaBuscar}" ]
		then
			latitude=`echo ${linea}|cut -d"|" -f1`
			longitude=`echo ${linea}|cut -d"|" -f2`
			break
		fi
	done < geolocalizacion.csv
	echo "TRAZA: Latitude:"${latitude}" Longitude:"${longitude}
	return
}
function pintarTrazaAccidente()
{
	#Recuperamos la localizacion del accidente:
	obtenerGeolocalizacion
	
	fecha=`date "+%Y-%m-%d"`
	hora=`date "+%H:%M:%S"`
	echo ${bastidor}"|"${codigoMotor}"|"${fecha}" "${hora}"|0|0|0|0|0|0|"${pesoVehiculoVacio}"|0|0|0|0|0|0|0|0|0|1|"${latitude}"|"${longitude} >>./${bastidor}.csv
	return
}
function parametrosVehiculo()
{
	codigo=$1
	echo "Bastidor:["${codigo}"]"
	if [ "${codigo}" == "Y4543GGBD3433" ]
	then
	echo "entra1"
		pesoVehiculoVacio=1200
		pesoMaximoAutorizadoVehiculo=1500
		pasajerosMaximoPermitido=2
		bultosMaximoPermitido=10
	elif [ "${codigo}" == "B34532ADRY43" ]
	then
	echo "entra2"
		pesoVehiculoVacio=1300
		pesoMaximoAutorizadoVehiculo=1700
		pasajerosMaximoPermitido=5
		bultosMaximoPermitido=10
	else
	echo "entra3"
		pesoVehiculoVacio=1300
		pesoMaximoAutorizadoVehiculo=1800
		pasajerosMaximoPermitido=5
		bultosMaximoPermitido=10
	fi
	return
}



#calcularSegundosInicioProceso

`rm -rf velocidad.log` #en este fichero registramos la velocidad para poder calcular la media y la distancia recorrida

echo "Indica el numero de bastidor: "
read bastidor

parametrosVehiculo ${bastidor}

let pesoVehiculoActual=${pesoVehiculoVacio}

obtenerGeolocalizacion

pintarTrazaArranqueMotor

while [ ${controlInicio} -eq 1 ];
do
	sleep 1
	pintarOpcionesMenu
	
	if [ ${respuesta} -lt 1 -a ${respuesta} -gt 0 ]
	then
		echo "error, elige una opcion de 0 - 6"
	elif [ ${respuesta} -eq 0 ]
	then
		let controlInicio=0
	elif [ ${respuesta} -eq 1 -o ${respuesta} -eq 2 ]
	then
		if [ ${pasajeros} -eq 0 ]
		then
			echo "Primero debe annadir un pasajero como Conductor"
			continue
		fi
	fi
			
	if [ ${respuesta} -eq 1 ]
	then
		 #Acelerar

		 pintarOpcionesMenuAcelerar
		 if [ ${controlRespuestaConduccion} -eq 1 ]
		 then
		 		let controlRespuestaConduccion=0
		 		continue
		 fi 
		 
		 if [ ${respuestaAcelerar} -gt 0 -a ${respuestaAcelerar} -gt ${respuestaFrenar} ]
		 then
		 		echo "Acelera: "${respuestaAcelerar}
		 		
		 		obtenerGeolocalizacion 
		 		
		 		if [ ${procesoSegundoPlano} -gt 0 ]
		 		then
		 			kill ${procesoSegundoPlano}
		 		fi
		 		
		 		./Acelerar.sh ${bastidor} ${codigoMotor} ${velocidad} ${respuestaAcelerar} ${tipoConduccion} ${segundosInicio} ${pasajeros} ${bultos} ${pesoVehiculoActual} ${codigoError} ${latitude} ${longitude} &
		 		procesoSegundoPlano=$!
		 		
		 		let velocidad=${respuestaAcelerar}
		 fi		
	elif [ ${respuesta} -eq 2 ]
	then
		 #Frenar
		 pintarOpcionesMenuFrenar
		 if [ ${respuestaFrenar} -ge 0 -a ${respuestaFrenar} -lt ${respuestaAcelerar} ]
		 then
		 		echo "Frenar: "${respuestafrenar}
		 		
		 		obtenerGeolocalizacion 
		 		
		 		if [ ${procesoSegundoPlano} -gt 0 ]
		 		then
		 			kill ${procesoSegundoPlano}
		 		fi
		 		./Frenar.sh ${bastidor} ${codigoMotor} ${velocidad} ${respuestaFrenar} ${tipoConduccion} ${segundosInicio} ${pasajeros} ${bultos} ${pesoVehiculoActual} ${codigoError} ${latitude} ${longitude} &
		 		procesoSegundoPlano=$!
		 		
		 		let velocidad=${respuestaFrenar}
		 fi
	elif [ ${respuesta} -eq 3 -o ${respuesta} -eq 4	]
	then
		if [ ${velocidad} -ne 0 ]
		then
			continue
		fi
		
		pintarMenuAnnadirPeso
		
		if [ ${respuestaPeso} -eq 0 ]
		then 
			continue
		fi
		
		if [ ${respuesta} -eq 3 ]
		then
			let pasajeros=`expr ${pasajeros}\+1`
		else
			let bultos=`expr ${bultos}\+1`
		fi
		
		let pesoVehiculoActual=`expr ${pesoVehiculoActual}\+${respuestaPeso}`
		if [ ${pesoVehiculoActual} -gt ${pesoMaximoAutorizadoVehiculo} ]
		then
			echo "¡¡OJO!! que has sobepasado el peso maximo autorizado del vehiculo ["${pesoMaximoAutorizadoVehiculo}"kg]"
		fi
	elif [ ${respuesta} -eq 5 ]
	then
		pintarMenuNotificacionError	
	elif [ ${respuesta} -eq 6 ]
	then
		pintarTrazaAccidente
		break
	fi
done

if [ ${procesoSegundoPlano} -gt 0 ]
then
	kill ${procesoSegundoPlano}
fi
