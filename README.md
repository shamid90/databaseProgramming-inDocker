# database_programming-postgreSQL-Java-Bash

## DB for Learning Management System (LMS)

## To Start

1. install Docker and Docker-Compose
2. copy .env.example into .env [$cat .env.example > .env]
3. change the password in .env to user's password [$nano .env, then POSTGRES_PASSWORD=4b570]
4. change the persmissions of the folder sample [$cd sample, then $chmod ugo+rwx sample/]
5. in the main directory (lmsplatform), docker-compose build
6. docker-compose up

## User password

lmsceo: 4b570
instructor_client: 123
student_client: 123

## Schema

1. lms_sch1
2. lms_sch2
3. lms_sch3

## Run the JAVA

1. compile the maven file [$mvn compile]
2. execute the maven file [$mvn exec:java]

## Run psql

### lmsceo

1. $psql -h localhost -p 5435 -U lmsceo
2. Enter the User password
3. SET SEARCH_PATH TO <schema_name>, public;

### instructor_client

1. $psql -h localhost -p 5435 -U instructor_client lmsceo
2. Enter the User password
3. SET SEARCH_PATH TO lms_sch1, public;

### student_client

1. $psql -h localhost -p 5435 -U student_client lmsceo
2. Enter the User password
3. SET SEARCH_PATH TO lms_sch1, public;

## Reset the system

1. docker-compose down
2. remove the folder data [$sudo rm -r data]
3. docker-compose build
4. docker-compose up

## Port

5435
