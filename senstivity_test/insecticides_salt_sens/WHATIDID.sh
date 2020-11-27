#!/usr/bin/env zsh


# remove machine settings information weird gaps
tail -n +14 input/insecticide_salt_sens.csv \
| tr '\t' ',' > tmp/rem_sett_format

# remove well designation and concatenate columns 1 and 2 with a -
cut -d ',' -f 3- tmp/rem_sett_format > tmp/rem_well_allo

# sort and remove blank incorporated duplicates
# seq -s ',' 0 5 955 > tmp/time
# head tmp/time | tr ',' '\n' | awk 'END{print NR}'
# output is 192, add 1 for rowname = 193
sort tmp/rem_well_allo | cut -d ',' -f 1,194-385 > tmp/rem_blank_dupli

# get time in minute format and save in results
seq -s ',' 0 5 955 > tmp/time
echo "time" > tmp/time_header
paste -d ',' tmp/time_header tmp/time > tmp/time_line
cat tmp/rem_blank_dupli >> tmp/time_line

grep -v -E 'blank' tmp/time_line > tmp/time_line_1

cp tmp/time_line_1 tmp/insecticide_salt_sens_formatted.csv

cp tmp/insecticide_salt_sens_formatted.csv results/insecticide_salt_sens_formatted.csv