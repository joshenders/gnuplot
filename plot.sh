#!/bin/bash

if [[ "$#" != '1' ]]; then
    echo "Usage: $(basename $0) <infile.csv>" >&2
    exit 1
fi

zone="$(basename ${1%%.csv})"
basedir="$(dirname $1)"

echo "Processing $1"

function plot() {
    # usage: plot infile field outfile title ylabel

    local infile="$1"
    local field="$2"
    local outfile="$3"
    local title="$4"
    local ylabel="$5"

gnuplot <<- EOF
    reset                                  # reset to defaults

    set datafile separator ','             # input file field separator
    set timefmt '%s'                       # first field is in unix time format

    set terminal png size 1200,600         # output type
    set output "${outfile}"                # output file name 

    set xdata time                         # x axis is time
    #set yrange [0:.500]                   # optional min/max scale
    #set autoscale y
    set logscale y                         # logarithmic scale y

    set title "${title}"                   # label of graph
    set format x "%H:%M"                   # time format for label of x axis
    set ylabel "${ylabel}"                 # label of y axis
    set grid                               # enable grid background
    unset key                              # disable graph legend

    plot "${infile}" using 1:${field} with points pointtype 7 linecolor 2 pointsize 1
EOF
}

# infile looks like:
# epoch_time,time_namelookup,time_connect,time_starttransfer,http_code,time_total,CF-Cache-Status

echo "Plotting time_namelookup"
plot "$1" 2 "${basedir}/${zone}-time_namelookup.png" "Total time for DNS resolution - ${zone}" "time_namelookup (in seconds)"

echo "Plotting time_connect"
plot "$1" 3 "${basedir}/${zone}-time_connect.png" "Time to establish connection - ${zone}" 'time_connect (in seconds)'

echo "Plotting time_starttransfer"
plot "$1" 4 "${basedir}/${zone}-time_starttransfer.png" "Time to first byte - ${zone}" 'time_starttransfer (in seconds)'

echo "Plotting time_total"
plot "$1" 6 "${basedir}/${zone}-time_total.png" "Total request time - ${zone}" 'time_total (in seconds)'
