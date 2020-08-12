#!/usr/bin/env zsh

function format_growth_assay_data(){

# remove machine settings information and removes weird gaps
tail -n +11 input/$1.csv \
| tr '\t' ',' > tmp/rem_sett_format

# remove other useless rows and well designation
tail -n +4 tmp/rem_sett_format | cut -d ',' -f 3- > tmp/rem_well_allo

# sort and remove blank incorporated duplicates
# seq -s ',' 0 5 960 > tmp/time
# head tmp/time | tr ',' '\n' | wc -l
# output is 192, add 1 for t=0 and 1 for rowname = 194
sort tmp/rem_well_allo | cut -d ',' -f -194 > tmp/rem_blank_dupli

# get time in minute format and save in results
seq -s ',' 0 5 960 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > tmp/time_line
cat tmp/rem_blank_dupli >> tmp/time_line

cp tmp/time_line results/$2_formatted.csv

}


