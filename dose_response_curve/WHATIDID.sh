#!/usr/bin/env zsh

function format_growth_assay_data(){

# remove machine settings information weird gaps
tail -n +15 input/$1.csv \
| tr '\t' ',' > tmp/rem_sett_format

# remove well designation
cut -d ',' -f 3- tmp/rem_sett_format > tmp/rem_well_allo

# get time in minute format and save in results
seq -s ',' 0 5 960 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > tmp/time_line
cat tmp/rem_well_allo | sort >> tmp/time_line

cp tmp/time_line tmp/$2_formatted.csv

}

seq -s ',' 0 5 960 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > tmp/formatted_compiled.csv

VAR=(`seq -s ' ' 1 1 7`)

for i in $VAR; do
 
format_growth_assay_data drc_${i} replicate_${i}

tail -n +2 tmp/replicate_${i}_formatted.csv \
| sed 's/,/-'"${i}"',/1' >> tmp/formatted_compiled.csv

done

cp tmp/formatted_compiled.csv results/formatted_compiled.csv
