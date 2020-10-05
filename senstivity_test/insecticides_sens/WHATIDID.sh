#!/usr/bin/env zsh

function format_growth_assay_data(){

# remove machine settings information weird gaps
tail -n +15 input/$1.csv \
| tr '\t' ',' > tmp/rem_sett_format

# remove well designation and concatenate columns 1 and 2 with a -
cut -d ',' -f 3- tmp/rem_sett_format | sed 's/,/-/1' > tmp/rem_well_allo

# sort and remove non-blank incorporated duplicates
# seq -s ',' 0 5 960 > tmp/time
# head tmp/time | tr ',' '\n' | awk 'END{print NR}'
# output is 193, add 1 for rowname = 194
sort tmp/rem_well_allo | cut -d ',' -f 1,195-387 > tmp/rem_blank_dupli

# get time in minute format and save in results
seq -s ',' 0 5 960 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > tmp/time_line
cat tmp/rem_blank_dupli >> tmp/time_line

cp tmp/time_line tmp/$2_formatted.csv

}

seq -s ',' 0 5 960 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > results/formatted_compiled.csv

VAR=(`seq -s ' ' 1 1 8`)

for i in $VAR; do
 
format_growth_assay_data replicate-${i} replicate_${i}

tail -n +2 tmp/replicate_${i}_formatted.csv \
| sed 's/,/-'"${i}"',/1' >> results/formatted_compiled.csv

done

# remove sulfoxaflor 6,7,8 replicates as had run out of sulfox
grep -v -E 'sulfoxaflor-.*-6|sulfoxaflor-.*-7|sulfoxaflor-.*-8' results/formatted_compiled.csv > tmp/no_sulfox_678

# remove blank rows in tmp/no_sulfox_678
grep -E -v 'blank.\d*.\d*.\d*,' tmp/no_sulfox_678 > tmp/no_sulfox_678_no_blank

cp tmp/no_sulfox_678_no_blank results/form_comp_corr_blank_cont.csv
