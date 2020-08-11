#!/bin/bash

#make 1000 random students
for i in {1..1000}
do
   # make a random username (5 character long in regexp "a-zA-Z0-9")
   user=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)

   # using the username to produce a corresponding email (concatenation with "@email.com")
   email="${user}@email.com"

   # make a random username (9 character long in some symbols like !$ etc are allowed in password)
   password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-!$%^&*()+_' | fold -w 9 | head -n 1)

   # save the data in csv format for table student
   echo "${i},${user},${email},${password}" >> "/docker-entrypoint-initdb.d/sample/LMS_Student.csv"
done
