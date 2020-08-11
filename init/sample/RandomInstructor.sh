#!/bin/bash

#array for first name
first_name_list=("Liam" "Noah" "William" "Oliver" "Benjamin" "Elijah" "Lucas" "Mason" "Logan"
 "Emma" "Olivia" "Ava" "Isabella" "Sophia" "Charlotte" "Mia" "Amelia" "Harper"
"Evelyn" "Martin" "Miller" "Rodriguez" "Lee" "Allen")

#array for last name
last_name_list=("Smith" "Jones" "Brown" "Williams" "Wilson" "Johnson" "Davies" "Robinson" "Wright" "Walker")


for i in {1..150}
do

   # seed random generator
   RANDOM=$$$(date +%s)

   # another random number between 0 and 9
   RANDOM2=$(cat /dev/urandom | tr -dc '0-9' | fold -w 256 | head -n 1 | head --bytes 1)

   NUMBER2=$RANDOM2

   #modify the first name with some random character (2) to make name more nique
   firstNameModifier=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 2 | head -n 1)

   #modify the last name with some random character (5) to make name more nique
   familyNameModifier=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -n 1)

   #concatenate the first name from array with modifier
   first_name=${first_name_list[$RANDOM % ${#first_name_list[@]}]}${firstNameModifier}

   #concatenate the last name from array with modifier
   last_name=${last_name_list[NUMBER2]}${familyNameModifier}

   #email based on first and last name
   email="${first_name}_${last_name}@lms.edu"

   #totally random description (not meaningful)
   description=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

   #save the data to a csv file for table Instructor
   echo "${i},${first_name},${last_name},${email},${description}" >> "/docker-entrypoint-initdb.d/sample/LMS_Instructor.csv"
done
