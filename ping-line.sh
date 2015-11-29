#!/usr/bin/gnuplot

# gnuplot 5.0 patchlevel rc2

# preroll
reset

# infile
set datafile separator ','
set timefmt '%s'
set xdata time
set format x "%m-%d %H:%M"
set key opaque

# outfile
set terminal x11 size 800,600 enhanced font 'Verdana,10' persist
#set terminal pngcairo size 900,640 enhanced font 'Verdana,10'
#set output '2015-11-16_bng_latency_survey.png'

# borders
set boxwidth 0.1 absolute
set xzeroaxis
set yzeroaxis
set zzeroaxis

# axes
set style line 11 linecolor rgb '#808080' linetype 1
set border 3 front linestyle 11
set tics nomirror out

# grid
set style line 12 linecolor rgb '#808080' linetype 0 linewidth 1
set grid back linestyle 12
set grid
set mxtics
set mytics
set ytics
set xtics rotate 14400
#set xrange ["1447026575":"1447285775"]
set xrange ["1447699288":"1447958488"]
#set yrange [-20:*]
set yrange [-50:*]

# labels
set xlabel 'Time' offset 0,-4.25,0 font ",12"
set ylabel 'RTT (ms)' font ",12"
set key left top font ",12"
set title "Broadband Network Gateway Latency"

#set multiplot

plot 'success.dat' using 1:2 with line lc rgb '#8CEC5A' title "success", \
     'fail.dat' using 1:($2-24) with point pt 12 ps 1.75 lc rgb '#E12728' title "failure"
     #'fail.dat' using 1:($2-9) with point pt 12 ps 1.75 lc rgb '#E12728' title "failure"
