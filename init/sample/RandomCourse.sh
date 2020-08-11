#!/bin/bash

#array for main category
main_category_list=("Programming" "Language" "Business" "Math")

#array for programming
programmin_list=("Java" "Python" "JavaScript" "C++" "Scala")

#array for language
language_list=("English" "German" "French" "Persian" "Russian")

#array for business
businnes_list=("Marketing" "Finance" "Sales")

#array for Math
math_list=("Geometry" "Linear Algebra" "Analysis")

#make 300 entry for table Course
for i in {1..300}
do

   # bash generate random number between 0 and 99
   iid_NUMBER=$(cat /dev/urandom | tr -dc '0-9' | fold -w 256 | head -n 1 | sed -e 's/^0*//' | head --bytes 2)
   if [ "$iid_NUMBER" == "" ]; then
	    iid_NUMBER=1
   fi

   # seed random generator (%s Seconds Format to generate more random based on date)
   RANDOM=$$$(date +%s)
   RANDOM2=$$$(date +%s)

   # random number between 0 and 3
   random_num=$(cat /dev/urandom | tr -dc '0-3' | fold -w 256 | head -n 1 | head --bytes 1)
   price=$(($iid_NUMBER * $random_num))

   # pick a random entry from the main category list (size of main category array taken into consideration)
   main_category=${main_category_list[$RANDOM % ${#main_category_list[@]}]}

   # produce a meaningful random sub category
   if [ "$main_category" == "Programming" ]; then
	    sub_category=${programmin_list[$RANDOM2 % ${#programmin_list[@]}]}
   elif [ "$main_category" == "Language" ]; then
	    sub_category=${language_list[$RANDOM2 % ${#language_list[@]}]}
   elif [ "$main_category" == "Business" ]; then
	    sub_category=${businnes_list[$RANDOM2 % ${#businnes_list[@]}]}
   else
	    sub_category=${math_list[$RANDOM2 % ${#math_list[@]}]}
   fi

   # string concatenation for random title
   title="${main_category} For Best ${sub_category}"

   #save the data as csv file in LMS_Course
   echo "${i},${title},${main_category},${sub_category},${price},${iid_NUMBER}" >> "/docker-entrypoint-initdb.d/sample/LMS_Course.csv"
done
