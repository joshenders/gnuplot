#!/usr/bin/gnuplot

# gnuplot 5.0 patchlevel rc2

# preroll
reset

# infile
set datafile separator ','

# outfile
#set terminal qt size 675,480 enhanced font 'Verdana,10' persist
set terminal pngcairo size 900,640 enhanced font 'Verdana,10'
set output 'world_histogram.png'

# retrieve statistical properties of infile
stats 'infile.dat' using (column('Avg Response (ms)')) nooutput

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
set grid xtics ytics mxtics

# labels
set title 'Route53 response latency'
set xlabel 'Milliseconds'
set ylabel 'Frequency'
set label sprintf("Max: %gms\nMedian: %gms\nSigma: %gms", STATS_max, STATS_median, floor(STATS_stddev)) at graph .86, .95

# histogram arithmetic
binwidth = 5
binstart = 0
load 'histogram.func'

# The jitter y-values add a random number between -75 and 50
plot 'infile.dat' using (column('Avg Response (ms)')):(50*rand(0)-75) pointtype 7 pointsize .1 notitle, \
     '' index 0 @hist notitle

# plot for [datafile in 'example.dat example2.dat'] datafile
