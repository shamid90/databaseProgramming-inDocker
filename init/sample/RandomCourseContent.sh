#!/bin/bash

for i in {1..1000}
do

   #each course content is between 1 to 60 minutes long
   duration=$(shuf -i 1-60 -n 1)

   # since we have 300 cid (randomCourse)
   course_id=$(shuf -i 1-300 -n 1)

   #random last update chosen arbitrarily
   last_update="2020-07-26 14:12:26"

   #since link should be unique, concatenated with 8 random char with regexp "a-zA-Z0-9"
   link=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

   #Procduce the link with imaginary web site of the lerning platform
   content_link="lms.com/c${link}"

   #save the outcome in csv file for table course content
   echo "${i},${content_link},${duration},${last_update},${course_id}" >> "/docker-entrypoint-initdb.d/sample/LMS_CourseContent.csv"

done
