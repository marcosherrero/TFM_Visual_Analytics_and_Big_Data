#!/bin/bash

#echo "Acelerar.sh numero parametros:"$#
#echo "Acelerar parametros: 1)"$1" 2)"$2" 3)"$3" 4)"$4" 5)"$5" 6)"$6" 7)"$7" 8)"$8
bastidor=$1
codigoMotor=$2
velocidadActual=$3
velocidadMaxima=$4
tipoConduccion=$5
segundosInicioProceso=$6
pasajeros=$7
bultos=$8
pesoVehiculoActual=$9
codigoError=${10} 
latitude=${11}
longitude=${12}
control=1
marcha=0
revoluciones=0
controlMensaje=0
fecha=`date "+%Y-%m-%d"`
#segundos=0
kmsRecorridos=0
segundosTotales=
velocidadMedia=
distanciaRecorrida=

#Valores OBD2:
iat=
maf=
frf=
egr=
ect1=
ect2=
ect3=
ect4=


function calculoValoresSensoresOBD2()
{
	let iat=`shuf -i 0-215 -n 1`
	let maf=`shuf -i 0-655 -n 1` 	
	let egr=`shuf -i 0-100 -n 1`
	let frf=`shuf -i 0-5177 -n 1`  
	let ect1=`shuf -i 0-215 -n 1`
	let ect2=`shuf -i 0-215 -n 1` 
	let ect3=`shuf -i 0-215 -n 1` 
	let ect4=`shuf -i 0-215 -n 1`

	if [ "${codigoError}" == "180" ]
	then
		let maf=9000
	elif [ "${codigoError}" == "403" ]
	then
		let egr=2000
	elif [ "${codigoError}" == "110" ]
	then
		let iat=1500
	elif [ "${codigoError)" == "89" ]
	then
		let frf=10000
	fi
	return
}
function calcularSegundosProceso(){
	horas=`date "+%_H"`
	minutos=`date "+%M"`
	let segundos=`expr ${horas}\*60\+${minutos}\*60\+${segundos}`
	return
}
function revolucionesCocheDeportivoPorMinuto(){
	desde=800
	hasta=
	if [ ${tipoConduccion} = 1 ]
	then
		let hasta=8000
	else
		let hasta=5000
	fi
		
	if [ ${velocidadActual} -eq 0 ]
	then
		let marcha=0
		let revoluciones=${desde}
	fi
	
	if [ ${velocidadActual} -gt 0 -a ${velocidadActual} -le 40 -a ${tipoConduccion} = 1 ]		
	then
		let marcha=1
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/40`
	elif [ ${velocidadActual} -gt 0 -a ${velocidadActual} -le 30 -a ${tipoConduccion} = 0 ]		
	then
		let marcha=1
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/30`
	elif [ ${velocidadActual} -gt 50 -a ${velocidadActual} -le 80 -a ${tipoConduccion} = 1 ]
	then
		let marcha=2
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/80`
	elif [ ${velocidadActual} -gt 30 -a ${velocidadActual} -le 70 -a ${tipoConduccion} = 0 ]
	then
		let marcha=2
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/70`
	elif [ ${velocidadActual} -gt 80 -a ${velocidadActual} -le 130 -a ${tipoConduccion} = 1 ] 
	then
		let marcha=3
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/130`
	elif [ ${velocidadActual} -gt 70 -a ${velocidadActual} -le 100 -a ${tipoConduccion} = 0 ] 
	then
		let marcha=3
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/110`
	elif [ ${velocidadActual} -gt 130 -a ${velocidadActual} -le 170 -a ${tipoConduccion} = 1 ]
	then
		let marcha=4
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/170`
	elif [ ${velocidadActual} -gt 100 -a ${velocidadActual} -le 120 -a ${tipoConduccion} = 0 ]
	then
		let marcha=4
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/140`
	elif [ ${velocidadActual} -gt 170 -a ${velocidadActual} -le 210 -a ${tipoConduccion} = 1 ] 
	then
		let marcha=5
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/210`
	elif [ ${velocidadActual} -gt 120 -a ${velocidadActual} -le 145 -a ${tipoConduccion} = 0 ] 
	then
		let marcha=5
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/145`
	elif [ ${velocidadActual} -gt 210 -a ${tipoConduccion} = 1 ]
	then
		let marcha=6
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/250`
	elif [ ${velocidadActual} -gt 145 -a ${tipoConduccion} = 0 ]
	then
		let marcha=6
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/145`	
	elif [ ${velocidadActual} -eq 250 ]		
	then
		echo "Velocidad maxima 250 kms/h"
	fi

	if [ ${velocidadActual} -eq ${velocidadMaxima} -a ${controlMensaje} -eq 0 ]
	then
		echo "Alerta!! Hemos llegado a la velocidad solicitada "${velocidadMaxima}" kms/h"
		let controlMensaje=1
	fi	
}

function revolucionesPorMinuto(){
	desde=1500
	hasta=
	if [ ${tipoConduccion} = 1 ]
	then
		hasta=4500
	else
		hasta=3000
	fi
		
	if [ ${velocidadActual} -eq 0 ]
	then
		let marcha=0
		let revoluciones=${desde}
	fi
	
	if [ ${velocidadActual} -gt 0 -a ${velocidadActual} -le 15 -a ${tipoConduccion} = 1 ]		
	then
		let marcha=1
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/15`
	elif [ ${velocidadActual} -gt 0 -a ${velocidadActual} -le 10 -a ${tipoConduccion} = 0 ]		
	then
		let marcha=1
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/10`
	elif [ ${velocidadActual} -gt 15 -a ${velocidadActual} -le 50 -a ${tipoConduccion} = 1 ]
	then
		let marcha=2
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/50`
	elif [ ${velocidadActual} -gt 10 -a ${velocidadActual} -le 30 -a ${tipoConduccion} = 0 ]
	then
		let marcha=2
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/30`
	elif [ ${velocidadActual} -gt 50 -a ${velocidadActual} -le 80 -a ${tipoConduccion} = 1 ] 
	then
		let marcha=3
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/80`
	elif [ ${velocidadActual} -gt 30 -a ${velocidadActual} -le 60 -a ${tipoConduccion} = 0 ] 
	then
		let marcha=3
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/60`
	elif [ ${velocidadActual} -gt 80 -a ${velocidadActual} -le 110 -a ${tipoConduccion} = 1 ]
	then
		let marcha=4
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/110`
	elif [ ${velocidadActual} -gt 60 -a ${velocidadActual} -le 90 -a ${tipoConduccion} = 0 ]
	then
		let marcha=4
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/90`
	elif [ ${velocidadActual} -gt 110 -a ${velocidadActual} -le 160 -a ${tipoConduccion} = 1 ] 
	then
		let marcha=5
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/160`
	elif [ ${velocidadActual} -gt 90 -a ${velocidadActual} -le 110 -a ${tipoConduccion} = 0 ] 
	then
		let marcha=5
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/110`
	elif [ ${velocidadActual} -gt 160 -a ${tipoConduccion} = 1 ]
	then
		let marcha=6
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/220`
	elif [ ${velocidadActual} -gt 110 -a ${tipoConduccion} = 0 ]
	then
		let marcha=6
		let revoluciones=`expr ${velocidadActual}\*${hasta}\/110`	
	elif [ ${velocidadActual} -eq 220 ]		
	then
		echo "Velocidad maxima 220 kms/h"
	fi

	if [ ${velocidadActual} -eq ${velocidadMaxima} -a ${controlMensaje} -eq 0 ]
	then
		echo "Alerta!! Hemos llegado a la velocidad solicitada "${velocidadMaxima}" kms/h"
		let controlMensaje=1
	fi	
}
function calcularSegundosTotales()
{
	segundosActuales=`date +%s`
	
	let segundosTotales=`expr ${segundosActuales} - ${segundosInicioProceso}`
}
function calcularVelocidadMedia()
{
		velocidadTotal=0
		contador=0
		
		while read linea
		do
			let velocidadTotal=`expr ${velocidadTotal}\+${linea}`
			let contador=`expr ${contador}\+1`
		done < ./velocidad.log
		
echo "velocidadTotal:"${velocidadTotal}", contador:"${contador}		
		let velocidadMedia=`expr ${velocidadTotal} / ${contador}`
echo "velocidadMedia:"${velocidadMedia}		
}
function calcularDistanciaRecorrida()
{
	horas=`echo "scale=2; ${segundosTotales} / 60"|bc`
echo "horas <minutos>:"${horas}

	let horas=`echo "scale=2; ${horas} / 60"|bc`
echo "horas <horas>:"${horas}
	
	let distanciaRecorrida=`echo scale=2; ${velocidadMedia} \* ${horas}`	
echo "Distancia recorrida:"${distanciaRecorrida}"kms"
}

if [ "${bastidor}" == "Y4543GGBD3433" ]
then
	revolucionesCocheDeportivoPorMinuto
else
	revolucionesPorMinuto
fi

while [ ${control} -eq 1 ];
do
	if [ ${velocidadActual} -lt ${velocidadMaxima} ]
	then
		let velocidadActual=`expr ${velocidadActual}\+1`
	else
		let velocidadActual=${velocidadMaxima}
	fi
	
	sleep 0.1
	
	hora=`date "+%H:%M:%S"`
	
	calculoValoresSensoresOBD2
	
	let distanciaRecorrida=0
	
	echo ${bastidor}"|"${codigoMotor}"|"${fecha}" "${hora}"|"${velocidadActual}"|"${marcha}"|"${revoluciones}"|"${distanciaRecorrida}"|"${pasajeros}"|"${bultos}"|"${pesoVehiculoActual}"|"${iat}"|"${maf}"|"${frf}"|"${egr}"|"${ect1}"|"${ect2}"|"${ect3}"|"${ect4}"|"${codigoError}"|0|"${latitude}"|"${longitude} >>./${bastidor}.csv
done

exit
