#!/bin/bash

setup_env(){
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
}
setup_vars(){
    setup_env
    json_file="weather.json"
    current_city="ghaziabad"
    get_jq
}

get_jq(){

    if [[ ! -f jq ]] 
    then
       case $machine in 
        Linux)
            wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
            mv jq-linux64 jq
        ;;

        Mac)
            wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-osx-amd64
            mv jq-osx-amd64 jq

        ;;

        esac

        chmod u+x jq 
    fi

    
    
}

get_weather_response(){
    echo "$(curl -s 'http://api.openweathermap.org/data/2.5/weather?q='$current_city'&units=metric&appid=d7099ce3c4c235675313b13bae804658')" > $json_file
}

post_notifications(){

 case $machine in 
        Linux)
            	notify-send "Weather" "Temprature in $1 is $2 ℃"
        ;;

        Mac)
        	command="display notification \"Temprature in $1 is $2 ℃\" with title \"Weather\""
    		osascript -e "$command"


        ;;

        esac


    
}

process(){
    
    post_notifications $current_city $(./jq '.main.temp' $json_file)
}

init(){
    setup_vars

    while true 
    do
    get_weather_response
    process 
    sleep 5
    done
    
  

}

init
