#!/usr/bin/env zsh

function format_growth_assay_data(){

# remove machine settings information weird gaps
tail -n +14 input/$1.csv \
| tr '\t' ',' > tmp/rem_sett_format

# remove well designation and concatenate columns 1 and 2 with a -
cut -d ',' -f 3- tmp/rem_sett_format > tmp/rem_well_allo

# sort and remove blank incorporated duplicates
# seq -s ',' 0 5 955 > tmp/time
# head tmp/time | tr ',' '\n' | awk 'END{print NR}'
# output is 192, add 1 for rowname = 193
sort tmp/rem_well_allo | cut -d ',' -f 1,195-387 > tmp/rem_blank_dupli

# get time in minute format and save in results
seq -s ',' 0 5 955 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > tmp/time_line
cat tmp/rem_blank_dupli >> tmp/time_line

grep -v -E 'blank' tmp/time_line > tmp/time_line_1

cp tmp/time_line_1 tmp/$2_formatted.csv

cp tmp/$2_formatted.csv results/$2_formatted.csv

}

seq -s ',' 0 5 960 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > results/formatted_compiled.csv

VAR=(`seq -s ' ' 1 1 2`)

for i in $VAR; do
 
format_growth_assay_data salt-interaction-${i} replicate_${i}

tail -n +2 tmp/replicate_${i}_formatted.csv >> results/formatted_compiled.csv

done
