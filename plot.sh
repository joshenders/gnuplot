#!/bin/bash

# alias plot="find . -name '*.csv' -exec ./plot.sh {} \;"
# alias clean="find . -name '*.png' -delete"

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
    # preroll
    reset                                  # reset to defaults
    set datafile separator ','             # input file field separator
    set timefmt '%s'                       # first field is in unix time format

    # statsistical analysis
    #stats "${infile}" using ${field} nooutput

    # HITS only, use-case specific
    stats "< grep HIT ${infile}" \
        using ${field} nooutput

    # output
    set terminal pngcairo size 1200,600    # output type, pngcairo > png
    set output "${outfile}"                # output file name 

    # ranges
    set xdata time                         # x axis is time
    set logscale y                         # logarithmic scale y
    set autoscale xfixmin                  # scale plot to x min on x
    set autoscale xfixmax                  # scale plot to x max on x

    # labels
    set title "${title}"                   # label of graph
    set format x "%H:%M"                   # time format for label of x axis
    set ylabel "${ylabel}"                 # label of y axis
    set grid                               # enable grid background
    set mytics 10                          # display minor y tics
    set mxtics 6                           # display minor x tics
    set xtics 3600                         # major tics every 3600 seconds (hourly)
    set key left Left                      # legend placement

    set label 1 gprintf("Mean: %g", STATS_mean) at graph .85,.95
    set label 2 gprintf("Median: %g", STATS_median) at graph .85,.9
    set label 3 gprintf("Sigma: %g", STATS_stddev) at graph .85,.85

    #plot "${infile}" using 1:${field} with points notitle \
    #    pointtype 7 linecolor 2 pointsize .5

    # HITS only, use-case specific
    plot "< grep HIT ${infile}" using 1:${field} with points notitle \
        pointtype 7 linecolor 2 pointsize .5, \
        STATS_max with lines linetype 1 linecolor 1 title "Max"
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
