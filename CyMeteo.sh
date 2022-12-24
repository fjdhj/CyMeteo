#!/bin/bash

help() {
    #Dysplay help
    echo "CyMeteo - Create graphs of weather data"
    echo
    echo "Syntax: CyMeteo <dataType> [optionalArg] -f <dataFilePath>"
    echo "Data type option, create a graph with :"
    echo "  -t<mode>: the temperature in the selected mode"
    echo "  -p<mode>: the pressure in the selected mode"
    echo "  -w: the direction and average speed of the wind relative to its position"
    echo "  -h: the height of stations relative to their position"
    echo "  -m: the maximum moisture for each station relative to their position"
    echo "Mode (for -t and -p), create a graph with :"
    echo "  Mode 1: the temperature/pressure average, minimal and maximal value by station"
    echo "  Mode 2: the temperature/pressure average value by chronological order"
    echo "  Mode 3: the temperature/pressure value by chronological order"
    echo "Data file path :"
    echo "  -f <dataFilePath>: the data file use"
    echo
    echo "Optional argument"
    echo "Geographic restriction (exclusive argument)"
    echo "  -"
}


if [ $# -eq 0 ] ; then
    echo "Not enought arguments, use --help to show how to use the script" >&2
    exit 1;
fi

dataType=""
location=""
sortingAlgo=""

for arg in $(seq 1 $#) ; do
    echo "${!arg}"
    case "${!arg}" in
        
        #Help
        --help)
            help
            exit 0 ;;

        #Data type
        -[tp][1-3] | -[whm])
            dataType="$dataType ${!arg}" ;;

        #Geographical restriction 
        -[FGSAOQ])
            if [ "$location" != "" ] ; then
                echo "Bad arguments, $location and ${!arg} are exclusive. Use --help to show how to use the script" >&2
                exit 1;
            fi
            location=${!arg} ;;

        #Sorting algorithm
        --tab | --abr | --avl)
            if [ "$sortingAlgo" != "" ] ; then
                echo "Bad arguments, $sortingAlgo and ${!arg} are exclusive. Use --help to show how to use the script" >&2
                exit 1;
            fi
            sortingAlgo=${!arg} ;;

        #The agrument do no exist
        *)
            echo "Bad arguments, use --help to show how to use the script" >&2 
            exit 1 ;;
    esac
done
