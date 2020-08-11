#!/bin/bash

#registering 500 students in random courses
for i in {1..500}
do

   #choose from student (1000 student are produced in random students), so a number between 1 and 1000
   student_id=$(shuf -i 1-1000 -n 1)

   #choose from student (300 courses are produced in random courses), so a number between 1 and 300
   course_id=$(shuf -i 1-300 -n 1)

	 # arbitrary random date for date_value
   date_value="2020-07-26 11:11:11"

   #save the data in a csv file for table registration
   echo "${student_id},${course_id},${date_value}" >> "/docker-entrypoint-initdb.d/sample/LMS_Registration.csv"

done
