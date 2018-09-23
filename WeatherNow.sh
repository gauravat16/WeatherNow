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
    resources="resources"
    bin="bin"
    json_file="weather.json"
    current_city="ghaziabad"
    get_jq
}

get_jq(){
    curr_path="$(pwd)"
    cd $bin
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

    cd $curr_path

    
    
}

get_weather_response(){
    echo "$(curl -s 'http://api.openweathermap.org/data/2.5/weather?q='$current_city'&units=metric&appid=d7099ce3c4c235675313b13bae804658')" > $resources/$json_file
}

post_notifications(){

 case $machine in 
        Linux)
            	notify-send "Weather" "Temprature in $1 is $2 ℃"
        ;;

        Mac)
        	command="display notification \"Temprature in $1 is $2 ℃\" with title \"Weather\" "
    		osascript -e "$command"


        ;;

        esac


    
}

get_icon(){
    icon_name=$1
    curr_path="$(pwd)"
    cd $resources
    if [[ ! -f "$icon_name" ]] 
    then
        wget http://openweathermap.org/img/w/$icon_name

    fi
    cd $curr_path
}

process(){
    get_icon "$(./$bin/jq -r '.weather[0].icon' $resources/$json_file).png"
    post_notifications $current_city $(./$bin/jq -r '.main.temp' $resources/$json_file)
}

init(){
    setup_vars

    while true 
    do
    get_weather_response
    process 
    sleep 3600
    done
    
  

}

init
