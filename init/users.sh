#!/bin/bash
set -e

user=lmsceo

echo Creating user $user
user_pw='4b570'

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $user;
    CREATE DATABASE $user;
    REVOKE connect ON DATABASE $user FROM PUBLIC;
    GRANT ALL PRIVILEGES ON DATABASE $user TO $user;
    ALTER USER $user WITH PASSWORD '$user_pw';
    GRANT pg_read_server_files TO $user;
    ALTER USER $user WITH SUPERUSER;
EOSQL

bash /docker-entrypoint-initdb.d/sample/RandomStudents.sh &
bash /docker-entrypoint-initdb.d/sample/RandomInstructor.sh &
bash /docker-entrypoint-initdb.d/sample/RandomCourse.sh &
bash /docker-entrypoint-initdb.d/sample/RandomCourseContent.sh &
bash /docker-entrypoint-initdb.d/sample/RandomRegistration.sh &
wait



    echo Creating LMS sample database
    echo $user_pw | psql -W --username $user --dbname $user -f /docker-entrypoint-initdb.d/sample/LMS.sql
