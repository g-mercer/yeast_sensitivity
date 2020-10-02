#!/usr/bin/env zsh

function format_growth_assay_data(){

# remove machine settings information weird gaps
tail -n +15 input/$1.csv \
| tr '\t' ',' > tmp/rem_sett_format

# remove well designation and concatenate columns 1 and 2 with a -
cut -d ',' -f 3- tmp/rem_sett_format | sed 's/,/-/1' > tmp/rem_well_allo

# sort and remove blank incorporated duplicates
# seq -s ',' 0 5 960 > tmp/time
# head tmp/time | tr ',' '\n' | awk 'END{print NR}'
# output is 193, add 1 for rowname = 194
sort tmp/rem_well_allo | cut -d ',' -f -194 > tmp/rem_blank_dupli

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

# remove only blanks
grep 'blank' tmp/no_sulfox_678 > tmp/only-blanks

# create blank file
perl -E 'say "blank " x 40' | tr " " "\n" > tmp/blank

# replace blank-.... with -line number
awk '{gsub("blank-[0-9].[0-9]*-[0-9]*",-NR,$0);print}' tmp/only-blanks > tmp/blanks-row-name
awk '{gsub("blank-[0-9]-[0-9]",-NR,$0);print}' tmp/blanks-row-name > tmp/blanks-row-name-1

# paste files together and combine columns
paste -d, tmp/blank tmp/blanks-row-name-1 | sed 's/,//1' > tmp/blanks-correct-name

# replace blank rows in tmp/no_sulfox_678 with tmp/blanks-correct-name
grep -E -v 'blank.\d*.\d*.\d*,' tmp/no_sulfox_678 > tmp/no_sulfox_678_no_blank

cat tmp/blanks-correct-name >> tmp/no_sulfox_678_no_blank

head -n +466 tmp/no_sulfox_678_no_blank > tmp/no_sulfox_678_corr_blanks.csv

cp tmp/no_sulfox_678_corr_blanks.csv results/form_comp_corr_blank_cont.csv

# remove only controls
#grep 'control' tmp/no_sulfox_678_corr_blanks.csv > tmp/only-controls

# create control file
#perl -E 'say "control " x 40' | tr " " "\n" > tmp/control

# replace control-.... with -line number
#awk '{gsub("control-[0-9].[0-9]*-[0-9]*",-NR,$0);print}' tmp/only-controls > tmp/controls-row-name
#awk '{gsub("control-[0-9]-[0-9]",-NR,$0);print}' tmp/controls-row-name > tmp/controls-row-name-1

# paste files together and combine columns
#paste -d, tmp/control tmp/controls-row-name-1 | sed 's/,//1' > tmp/controls-correct-name

# replace control rows in tmp/no_sulfox_678_corr_blanks.csv with tmp/controls-correct-name
#grep -E -v 'control.\d*.\d*.\d*,' tmp/no_sulfox_678_corr_blanks.csv > tmp/no_sulfox_678_corr_blanks_no_control.csv

#cat tmp/controls-correct-name >> tmp/no_sulfox_678_corr_blanks_no_control.csv

#head -n +466 tmp/no_sulfox_678_corr_blanks_no_control.csv > tmp/no_sulfox_678_corr_blanks_corr_controls.csv

#cp tmp/no_sulfox_678_corr_blanks_corr_controls.csv results/form_comp_corr_blank_cont.csv

# function format_insecticide_assay_data(){

# remove only $1
# grep "$1" tmp/$2 > tmp/only-$1

# create $1 file
# perl -E "say "$1 " x 40" | tr " " "\n" > tmp/$1

# replace $1-.... with -line number
# awk '{gsub("$1-[0-9].[0-9]*-[0-9]*",-NR,$0);print}' tmp/only-$1 > tmp/$1-row-name
# awk '{gsub("$1-[0-9]-[0-9]",-NR,$0);print}' tmp/$1-row-name > tmp/$1-row-name-1

# paste files together and combine columns
# paste -d, tmp/$1 tmp/$1-row-name-1 | sed 's/,//1' > tmp/$1-correct-name

# replace $1 rows in tmp/$2 with tmp/$1-correct-name
# grep -E -v '$1.\d*.\d*.\d*,' tmp/$2 > tmp/$3

# cat tmp/$1-correct-name >> tmp/$3 

# head -n +465 tmp/$3 > tmp/$3.csv

# }

# format_insecticide_assay_data blank no_sulfox_678 data_with_blank

# format_insecticide_assay_data control data_with_blank data_with_blank_control

