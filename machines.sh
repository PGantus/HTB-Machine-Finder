#!/bin/bash

#Colors
greenColor="\e[0;32m\033[1m"
endColor="\033[0m\e[0m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function ctrl_c(){
	echo -e "\n\n${redColor}[!] Saliendo...${endColor}\n"
	tput cnorm && exit 1
}

#Ctrl + C
trap ctrl_c INT

function helpPanel(){
	echo -e "\n${purpleColor}[+]${endColor}${grayColor} Uso:${endColor}\n"
	echo -e "\t${blueColor}-u${endColor}${grayColor}  Descargar o actualizar archivos necesarios${endColor}"
	echo -e "\t${blueColor}-m${endColor}${grayColor}  Buscar por nombre de máquina${endColor}"
	echo -e "\t${blueColor}-i${endColor}${grayColor}  Buscar por dirección IP${endColor}"
	echo -e "\t${blueColor}-d${endColor}${grayColor}  Buscar por difucultad (Fácil, Media, Difícil, Insane)${endColor}"
	echo -e "\t${blueColor}-o${endColor}${grayColor}  Buscar por sistema operativo${endColor}"
	echo -e "\t${blueColor}-s${endColor}${grayColor}  Buscar por skills${endColor}"
	echo -e "\t${blueColor}-y${endColor}${grayColor}  Obtener link de la resolución de la máquina en Youtube${endColor}"
	echo -e "\t${blueColor}-h${endColor}${grayColor}  Mostrar este panel de ayuda${endColor}\n"
}

function updateFiles(){
	if [ ! -f bundle.js ]; then
		tput civis
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Descargando archivos necesarios...${endColor}"
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Descarga terminada${endColor}"
		tput cnorm
	else
		tput civis
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Comprobando si hay actualizaciones pendientes...${endColor}"
		sleep 2
		curl -s $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')
		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n${purpleColor}[+]${endColor}${grayColor} Nada que actualizar${endColor}"
			rm bundle_temp.js
		else
			tput civis
                	echo -e "\n${purpleColor}[+]${endColor}${grayColor} Se han encontrado actualizaciones disponibles. Actualizando archivos necesarios...${endColor}"
			sleep 2
			rm bundle.js && mv bundle_temp.js bundle.js
                	echo -e "\n${purpleColor}[+]${endColor}${grayColor} Descarga terminada${endColor}"
                	tput cnorm
		fi
		tput cnorm
	fi
}

function searchMachine(){
        tput civis
	machineName="$1"
	machineproperties="$(cat bundle.js | awk "BEGIN {IGNORECASE=1} /name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta:" | tr -d '",' | sed "s/^ *//" | sed 's/name:/Nombre:/' | sed 's/ip:/IP:/' | sed 's/dificultad:/Dificultad:/' | sed 's/skills:/Skills:/' | sed 's/like:/Certs:/' | sed 's/youtube:/Tutorial:/' | sed 's/so:/OS:/'| while read line; do echo -en ${blueColor}$(echo $line | awk '{print $1}')${endColor}; echo -e ${grayColor} $(echo $line | awk '{for(i=2; i <= NF; i++) print $i}')${endColor}; done)"
	if [ ! "$machineproperties" ]; then
		echo -e "\n${redColor}[!] La máquina $machineName no fue encontrada, inténtalo de nuevo${endColor}\n"
	else
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Listando las propiedades de la máquina${endColor}${blueColor} $machineName${endColor}${grayColor}:${endColor}\n"
		echo "$machineproperties"
	fi
	tput cnorm
}

function searchIP(){
	ipAdress="$1"
	machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}'| tr -d '",')"
	if [ "$machineName" ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} La máquina correspondiente para la IP${endColor}${blueColor} $ipAdress${endColor}${grayColor} es:${endColor}${blueColor} $machineName${endColor}\n"
	else
		echo -e "\n${redColor}[!] La IP $ipAdress no fue encontrada, inténtalo de nuevo${endColor}\n"
	fi
}

function getYoutubeLink(){
	machineName="$1"
	youtubeLink="$(cat bundle.js | awk "BEGIN {IGNORECASE=1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '",' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
	if [ "$youtubeLink" ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} El tutorial de la máquina${endColor}${blueColor} $machineName${endColor}${grayColor} es:${endColor}${blueColor} $youtubeLink${endColor}"
	else
		echo -e "\n${redColor}[!] La máquina $machineName no fue encontrada, inténtalo de nuevo${endColor}\n"
	fi
}

function machineDifficulty(){
	difficulty="$1"
	difficultyCheck="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name: "| awk 'NF{print $NF}' | tr -d '",' | column)"
	if [ "$difficultyCheck" ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Mostrando máquinas de dificultad${endColor}${blueColor} $difficulty${endColor}\n"
		echo -e "$difficultyCheck"
	else
		echo -e "\n${redColor}[!] La dificultad $difficulty no existe, inténtalo de nuevo${endColor}\n"
	fi
}

function getOS(){
	os="$1"
	osCheck="$(cat bundle.js | grep -i "so: \"$os\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"
	if [ "$osCheck" ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Mostrando máquinas con sistema operativo${endColor}${blueColor} $os${endColor}\n"
		echo -e "$osCheck"
	else
		echo -e "\n${redColor}[!] El sistema operativo $os no existe, inténtalo de nuevo${endColor}\n"
	fi
}

function getSkills(){
	skills="$1"
	skillsCheck="$(cat bundle.js | grep "skills: " -B 6 | grep -i "$skills" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"
	if [ "$skillsCheck"  ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Mostrando máquinas con la skill${endColor}${blueColor} $skills${endColor}\n"
		echo -e "$skillsCheck"
	else
		echo -e "\n${redColor}[!] La skill $skills no existe, inténtalo de nuevo${endColor}\n"
	fi
}

function getOSDifficulty(){
	difficulty="$1"
	os="$2"
	osDifCheck="$(cat bundle.js | grep -i "so: \"$os\"" -C 4 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"
	if [ "$osDifCheck"  ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Mostrando máquinas con sistema operativo${endColor}${blueColor} $os${endColor}${grayColor} y dificultad${endColor}${purpleColor} $difficulty${endColor}\n"
		echo -e "$osDifCheck"
	else
		echo -e "\n${redColor}[!] Uno o más campos están mal escritos, inténtalo de nuevo${endColor}\n"
	fi
}

function getDS(){
	difficulty="$1"
	skills="$2"
	DSCheck="$(cat bundle.js |  grep -i "dificultad: \"$difficulty\"" -C 5 | grep "skills: " -B 6 | grep -i "$skills" -B 6 | grep "name: " | awk 'NF {print $NF}' | tr -d '",' | column)"
	if [ "$DSCheck" ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Mostrando máquinas con dificultad${endColor}${blueColor} $difficulty${endColor}${grayColor} y la skill${endColor}${blueColor} $skills${endColor}\n"
		echo -e "$DSCheck"
	else
		echo -e "\n${redColor}[!] No se encontró ninguna máquina, inténtalo de nuevo con otros parámetros${endColor}\n"
	fi
}

function getOSS(){
	os="$1"
	skills="$2"
	OSSCheck="$(cat bundle.js |  grep -i "so: \"$os\"" -C 5 | grep "skills: " -B 6 | grep -i "$skills" -B 6 | grep "name: " | awk 'NF {print $NF}' | tr -d '",' | column)"
	if [ "$OSSCheck" ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Mostrando máquinas con sistema operativo${endColor}${blueColor} $os${endColor}${grayColor} y la skill${endColor}${blueColor} $skills${endColor}"
		echo -e "$OSSCheck"
	else
		echo -e "\n${redColor}[!] No se encontró ninguna máquina, inténtalo de nuevo con otros parámetros${endColor}\n"
	fi
}

function getOSDS(){
	os="$1"
	difficulty="$2"
	skills="$3"
	OSDSCheck="$(cat bundle.js | grep -i "so: \"$os\"" -C 5 | grep -i "dificultad: \"$difficulty\"" -C 5 | grep -i "$skills" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '",' | column)"
	if [ "$OSDSCheck" ]; then
		echo -e "\n${purpleColor}[+]${endColor}${grayColor} Mostrando máquinas con sistema operativo${endColor}${blueColor} $os${endColor}${grayColor}, dificultad${endColor}${blueColor} $difficulty${endColor}${grayColor} y la skill${endColor}${blueColor} $skills${endColor}"
		echo -e "$OSDSCheck"
	else
		echo -e "\n${redColor}[!] No se encontró ninguna máquina, inténtalo de nuevo con otros parámetros${endColor}\n"
	fi
}

#Indicadores
declare -i parameter_counter=0

#Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0
declare -i chivato_skills=0

while getopts "m:ui:y:d:o:s:h" arg; do
	case $arg in
	m) machineName=$OPTARG; let parameter_counter+=1;;
	u) let parameter_counter+=2;;
	i) ipAdress=$OPTARG; let parameter_counter+=3;;
	y) machineName=$OPTARG; let parameter_counter+=4;;
	d) difficulty=$OPTARG; chivato_difficulty=1; let parameter_counter+=5;;
	o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
	s) skills=$OPTARG; chivato_skills=1; let parameter_counter+=7;;
	h) ;;
	esac
done


if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	machineDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	getOS $os
elif [ $parameter_counter -eq 7 ]; then
	getSkills "$skills"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ] && [ $chivato_skills -eq 0 ]; then
	getOSDifficulty $difficulty $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_skills -eq 1 ] && [ $chivato_os -eq 0 ]; then
	getDS "$difficulty" "$skills"
elif [ $chivato_os -eq 1 ] && [ $chivato_skills -eq 1 ] && [ $chivato_difficulty -eq 0 ]; then
	getOSS $os "$skills"
elif [ $chivato_os -eq 1 ] && [ $chivato_difficulty -eq 1 ] && [ $chivato_skills -eq 1 ]; then
	getOSDS "$os" "$difficulty" "$skills"
else
	helpPanel
fi
