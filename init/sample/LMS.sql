DROP SCHEMA IF EXISTS lms_sch1 CASCADE;
DROP SCHEMA IF EXISTS lms_sch2 CASCADE;
DROP SCHEMA IF EXISTS lms_sch3 CASCADE;
DROP OWNED BY instructor_client CASCADE;
DROP OWNED BY student_client CASCADE;
DROP ROLE IF EXISTS instructor_client;
DROP ROLE IF EXISTS student_client;



--functions and extentions are in the public
--to give the access to all schemas given the path is set to schemaname, public;


--create citex entention for type_email domain
DROP EXTENSION IF EXISTS citext CASCADE;
DROP DOMAIN IF EXISTS type_email CASCADE;
CREATE EXTENSION citext;

--using citext for case-insensitive character string type
--create a domain for emails to check the RegExp compatibility
CREATE DOMAIN type_email AS citext
CHECK(
   VALUE ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'
);


--by insert/update changes the last_update to current time
CREATE OR REPLACE FUNCTION last_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_update = CURRENT_TIMESTAMP;
    RETURN NEW;
END $$;


--only students can give feedback who are registered in the course
CREATE OR REPLACE FUNCTION prevent_invalid_feedback() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT student_can_give_feedback(NEW.sid, NEW.cid) THEN
      RAISE EXCEPTION 'THE STUDENT DOES NOT HAVE ACCESS TO THIS COURSE';
    END IF;
    RETURN NEW;
END $$;

--check if the student is registered in the course
CREATE OR REPLACE FUNCTION student_can_give_feedback(std_id integer, c_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    std_regc INTEGER;
BEGIN

    SELECT count(*) INTO std_regc
    FROM registration r
    WHERE std_id = r.sid
      AND c_id = r.cid;

    IF std_regc > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
END $$;



--update the rate for both course and instructor
--one instructor can have many course, the rate is the avg of all of her/his courses
CREATE OR REPLACE FUNCTION new_rate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    newCourseRate NUMERIC(2,1);
    newInstructorRate NUMERIC(2,1);
BEGIN
    SELECT AVG(f.rate) INTO newCourseRate
    FROM feedback f
    WHERE NEW.cid = f.cid;

    UPDATE course c
    SET rate = newCourseRate
    WHERE c.cid = NEW.cid;


    SELECT AVG(f.rate) INTO newInstructorRate
    FROM feedback f JOIN course c USING (cid)
      JOIN instructor i USING (iid)
    WHERE c.iid IN (SELECT c.iid FROM course c WHERE c.cid = NEW.cid);


    UPDATE instructor i
    SET rate = newInstructorRate
    FROM course c
    WHERE (c.cid = NEW.cid) and (c.iid = i.iid);
    RETURN NEW;
END $$;



--if the student is not registered, there cannot be a progress in that course
CREATE OR REPLACE FUNCTION prevent_invalid_progress() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT student_is_registered(NEW.sid, NEW.ccid) THEN
      RAISE EXCEPTION 'THE STUDENT DOES NOT HAVE ACCESS TO THIS COURSE CONTENT';
    END IF;
    RETURN NEW;
END $$;


--check if the student has access to the course content
CREATE OR REPLACE FUNCTION student_is_registered(std_id integer, cc_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    std_reg INTEGER;
BEGIN

    SELECT count(*) INTO std_reg
    FROM registration r JOIN course_content cc USING (cid)
    WHERE r.sid = std_id
      AND cc.ccid = cc_id;

    IF std_reg > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
END $$;






--creatint the first schema
CREATE SCHEMA lms_sch1;

--set the path, also public in order to use the functions,extentions and domains
SET SEARCH_PATH TO lms_sch1, public;


--BEGIN of All the SEQUENCES part

--for sid, table student
CREATE SEQUENCE student_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for iid, table instructor
CREATE SEQUENCE instructor_iid_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;

--for cid, table course
CREATE SEQUENCE course_cid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for ccid, table course_content
CREATE SEQUENCE course_content_ccid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for fid, table feedback
CREATE SEQUENCE feedback_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- END of part creating SEQUENCES



--BEGIN the part CREATING TABLES


--table studnet
CREATE TABLE student (
    sid INTEGER DEFAULT nextval('student_sid_seq') NOT NULL PRIMARY KEY,
    username VARCHAR(45) NOT NULL,
    email type_email NOT NULL,
    password VARCHAR(45) NOT NULL
);

--inisializing table student, schema: lms_sch1
INSERT INTO student (username, email, password) VALUES ('ahhuk', 'ah_huk@mlu.de','ah12345!');
INSERT INTO student (username, email, password) VALUES ('ajvnk', 'aj_06@mlu.de', '0aj123nk');
INSERT INTO student (username, email, password) VALUES ('qwert', 'qw98@gmail.com', 'QW98rt');
INSERT INTO student (username, email, password) VALUES ('mnbvc', 'mn_bvc@yahoo.com','mn!b6');
INSERT INTO student (username, email, password) VALUES ('asdfg', 'as@email.com', '987as789');
INSERT INTO student (username, email, password) VALUES ('ahmuk', 'am_huk@mlu.de','am12345!');
INSERT INTO student (username, email, password) VALUES ('agvnk', 'ag_08@mlu.de', '0ag128nk');
INSERT INTO student (username, email, password) VALUES ('qweet', 'qw99@gmail.com', 'QW99rt');
INSERT INTO student (username, email, password) VALUES ('mncnn', 'mn_bbc@yahoo.com','mn!bb');


SELECT * FROM student;


--table instructor
CREATE TABLE instructor (
    iid INTEGER DEFAULT nextval('instructor_iid_seq') NOT NULL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email type_email NOT NULL,
    rate NUMERIC(2,1) DEFAULT NULL,
    description VARCHAR,
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5)
);


--inisializing table instructor, schema: lms_sch1
INSERT INTO instructor (first_name, last_name, email) VALUES ('Angela','Yu', 'angi_yu@gmail.com');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Nick', 'Walter', 'Nick_Walter@ProtonMail.com', 'I am Java and C# specialist.');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Veronila', 'PV', 'Veronila_md@yahoo.com', 'Medicin is my passion!');
INSERT INTO instructor (first_name, last_name, email) VALUES ('Maryam','Mirzakhani', 'MM_math@harvard.edu');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Kiril', 'Eremenko', 'k_ML_erko@t.com', 'Let''s learn ML together(#! Maschine Learnig)');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Susi','Lederer', 'sl@outlook.com', 'I teach German DE');
INSERT INTO instructor (first_name, last_name, email) VALUES ('Kianna','Parsa', 'KianaP@gmail.com');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Daniel','Edwin', 'DaniEd@aol.io', 'Pro Web Developer instructor');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Stephan','Grider', 'StephanGr@gmail.com', 'Docker and Kubernetes');

SELECT * FROM instructor;


--table course
CREATE TABLE course (
    cid INTEGER DEFAULT nextval('course_cid_seq') NOT NULL PRIMARY KEY,
    title VARCHAR(45) NOT NULL,
    main_category VARCHAR(45) NOT NULL,
    sub_category VARCHAR(45) NOT NULL,
    rate NUMERIC(2,1) DEFAULT NULL,
    price NUMERIC(5,2),
    iid INTEGER REFERENCES instructor ON DELETE CASCADE,
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5)
);


--inisializing table course, schema: lms_sch1
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Java Complete','Programming','Java',119,2);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('TestDaF','Language','German',189,6);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('SPRING FRAMEWORK','Programming','Java',129,2);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Tip for Giving a Killer Speech','Business','Marketing',99,1);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Full-Stack Web Development','Programming','Web_development',159,8);
INSERT INTO course (title, main_category, sub_category, iid) VALUES ('Introduction to Geometry Easy','Math','Geometry',4);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Advanced Geometry Easy','Math','Geometry',199 ,4);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Introduction to Python','Programming','Python',99,5);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('ML and Data Science with Python/R','Programming','Maschine_learning',199,5);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Master Docker and Kubernetes','DevOps','Docker',99,9);

SELECT * FROM course;



--table registration
CREATE TABLE registration (
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    registration_date TIMESTAMPTZ DEFAULT Now(),
    PRIMARY KEY (sid, cid)
);


--inisializing table course, schema: lms_sch1
INSERT INTO registration (sid, cid) VALUES (1,1);
INSERT INTO registration (sid, cid) VALUES (1,3);
INSERT INTO registration (sid, cid) VALUES (1,6);
INSERT INTO registration (sid, cid) VALUES (2,2);
INSERT INTO registration (sid, cid) VALUES (2,4);
INSERT INTO registration (sid, cid) VALUES (3,1);
INSERT INTO registration (sid, cid) VALUES (4,8);
INSERT INTO registration (sid, cid) VALUES (4,9);
INSERT INTO registration (sid, cid) VALUES (5,5);
INSERT INTO registration (sid, cid) VALUES (1,9);


select * from registration;


--table course_content
CREATE TABLE course_content(
    ccid INTEGER DEFAULT nextval('course_content_ccid_seq') NOT NULL PRIMARY KEY,
    content_link VARCHAR NOT NULL,
    duration NUMERIC(5,2) NOT NULL,
    last_update TIMESTAMPTZ DEFAULT Now(),
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    CONSTRAINT unique_link UNIQUE(content_link)
);

--keep track of when the course content has been updated last time
CREATE TRIGGER course_content_last_updated BEFORE UPDATE ON course_content FOR EACH ROW EXECUTE PROCEDURE last_updated();

--inisializing table course_content, schema: lms_sch1
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c11',12.25,1);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c21',7.2,2);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c22',10,2);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c12',12,1);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c41',7,4);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c51',15,5);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c31',21.5,3);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c32',25.2,3);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c42',3,4);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c81',9,8);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c91',14,9);

SELECT * FROM course_content;



--table feedback
CREATE TABLE 	feedback (
    fid INTEGER DEFAULT nextval('feedback_fid_seq') NOT NULL,
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    rate NUMERIC(2,1) NOT NULL,
    comment VARCHAR,
    last_update TIMESTAMPTZ DEFAULT Now(),
    PRIMARY KEY (fid, sid, cid),
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5),
    CONSTRAINT each_course_one_feedback_from_each_std UNIQUE (sid,cid)
);

--keep track of when the feedbacl has been inserted/updated last time
CREATE TRIGGER feedback_last_updated BEFORE UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE last_updated();

--after each feedback the rate of the corresponding course and instructor will be updated
CREATE TRIGGER new_rate AFTER INSERT OR UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE new_rate();

--only registered students are allowed to give feedback
CREATE TRIGGER prevent_invalid_feedback BEFORE INSERT OR UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_feedback();

--inisializing table feedback, schema: lms_sch1
INSERT INTO feedback (sid, cid, rate, comment) VALUES (1, 1, 4.8, 'super!');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (2, 2, 4, 'Very Good and comprehensive.');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (3, 1, 3, 'some content are outdated');
INSERT INTO feedback (sid, cid, rate) VALUES (2, 4, 4.2);
INSERT INTO feedback (sid, cid, rate, comment) VALUES (1, 9, 4.2, 'Well structured');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (4, 9, 4.7, 'Great!');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (4, 8, 2.5, 'Should improve!');
INSERT INTO feedback (sid, cid, rate) VALUES (5, 5, 5);

SELECT * FROM feedback;
SELECT * FROM instructor;


--table progress
CREATE TABLE progress (
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    ccid INTEGER REFERENCES course_content ON DELETE CASCADE,
    hasDone BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (sid, ccid)
);

--only students with access to the course content can make progress in that course/course content
CREATE TRIGGER prevent_invalid_progress BEFORE INSERT OR UPDATE ON progress FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_progress();


--inisializing table progress, schema: lms_sch1
INSERT INTO progress (sid, ccid, hasDone) VALUES (1,1,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (2,2,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (2,3,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (1,11,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (4,10,TRUE);


SELECT * FROM progress;


--to make it exactly the same at lms_sch2

UPDATE student SET username='mnbbc' WHERE username='mncnn';

INSERT INTO student (username, email, password) VALUES ('asdff', 'asf@email.com', '987as78');

UPDATE instructor SET first_name='Kiana' WHERE first_name='Kianna';

DELETE FROM instructor WHERE first_name='Stephan' AND last_name='Grider';

-- the course for the instructor "Stephan Grider" will be deleted automatically (ON DELETE CASCADE)







--creatint the second schema
CREATE SCHEMA lms_sch2;

--set the path, also public in order to use the functions,extentions and domains
SET SEARCH_PATH TO lms_sch2, public;



--BEGIN of All the SEQUENCES part

--for sid, table student
CREATE SEQUENCE student_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for iid, table instructor
CREATE SEQUENCE instructor_iid_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;

--for cid, table course
CREATE SEQUENCE course_cid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for ccid, table course_content
CREATE SEQUENCE course_content_ccid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for fid, table feedback
CREATE SEQUENCE feedback_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- END of part creating SEQUENCES



--BEGIN the part CREATING TABLES


--table studnet
CREATE TABLE student (
    sid INTEGER DEFAULT nextval('student_sid_seq') NOT NULL PRIMARY KEY,
    username VARCHAR(45) NOT NULL,
    email type_email NOT NULL,
    password VARCHAR(45) NOT NULL
);

--inisializing table student, schema: lms_sch2
INSERT INTO student (username, email, password) VALUES ('ahhuk', 'ah_huk@mlu.de','ah12345!');
INSERT INTO student (username, email, password) VALUES ('ajvnk', 'aj_06@mlu.de', '0aj123nk');
INSERT INTO student (username, email, password) VALUES ('qwert', 'qw98@gmail.com', 'QW98rt');
INSERT INTO student (username, email, password) VALUES ('mnbvc', 'mn_bvc@yahoo.com','mn!b6');
INSERT INTO student (username, email, password) VALUES ('asdfg', 'as@email.com', '987as789');
INSERT INTO student (username, email, password) VALUES ('ahmuk', 'am_huk@mlu.de','am12345!');
INSERT INTO student (username, email, password) VALUES ('agvnk', 'ag_08@mlu.de', '0ag128nk');
INSERT INTO student (username, email, password) VALUES ('qweet', 'qw99@gmail.com', 'QW99rt');
INSERT INTO student (username, email, password) VALUES ('mnbbc', 'mn_bbc@yahoo.com','mn!bb');
INSERT INTO student (username, email, password) VALUES ('asdff', 'asf@email.com', '987as78');

SELECT * FROM student;


--table instructor
CREATE TABLE instructor (
    iid INTEGER DEFAULT nextval('instructor_iid_seq') NOT NULL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email type_email NOT NULL,
    rate NUMERIC(2,1) DEFAULT NULL,
    description VARCHAR,
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5)
);


--inisializing table instructor, schema: lms_sch2
INSERT INTO instructor (first_name, last_name, email) VALUES ('Angela','Yu', 'angi_yu@gmail.com');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Nick', 'Walter', 'Nick_Walter@ProtonMail.com', 'I am Java and C# specialist.');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Veronila', 'PV', 'Veronila_md@yahoo.com', 'Medicin is my passion!');
INSERT INTO instructor (first_name, last_name, email) VALUES ('Maryam','Mirzakhani', 'MM_math@harvard.edu');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Kiril', 'Eremenko', 'k_ML_erko@t.com', 'Let''s learn ML together(#! Maschine Learnig)');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Susi','Lederer', 'sl@outlook.com', 'I teach German DE');
INSERT INTO instructor (first_name, last_name, email) VALUES ('Kiana','Parsa', 'KianaP@gmail.com');
INSERT INTO instructor (first_name, last_name, email, description) VALUES ('Daniel','Edwin', 'DaniEd@aol.io', 'Pro Web Developer instructor');

SELECT * FROM instructor;


--table course
CREATE TABLE course (
    cid INTEGER DEFAULT nextval('course_cid_seq') NOT NULL PRIMARY KEY,
    title VARCHAR(45) NOT NULL,
    main_category VARCHAR(45) NOT NULL,
    sub_category VARCHAR(45) NOT NULL,
    rate NUMERIC(2,1) DEFAULT NULL,
    price NUMERIC(5,2),
    iid INTEGER REFERENCES instructor ON DELETE CASCADE,
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5)
);


--inisializing table course, schema: lms_sch2
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Java Complete','Programming','Java',119,2);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('TestDaF','Language','German',189,6);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('SPRING FRAMEWORK','Programming','Java',129,2);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Tip for Giving a Killer Speech','Business','Marketing',99,1);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Full-Stack Web Development','Programming','Web_development',159,8);
INSERT INTO course (title, main_category, sub_category, iid) VALUES ('Introduction to Geometry Easy','Math','Geometry',4);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Advanced Geometry Easy','Math','Geometry',199 ,4);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('Introduction to Python','Programming','Python',99,5);
INSERT INTO course (title, main_category, sub_category, price, iid) VALUES ('ML and Data Science with Python/R','Programming','Maschine_learning',199,5);

SELECT * FROM course;



--table registration
CREATE TABLE registration (
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    registration_date TIMESTAMPTZ DEFAULT Now(),
    PRIMARY KEY (sid, cid)
);


--inisializing table course, schema: lms_sch2
INSERT INTO registration (sid, cid) VALUES (1,1);
INSERT INTO registration (sid, cid) VALUES (1,3);
INSERT INTO registration (sid, cid) VALUES (1,6);
INSERT INTO registration (sid, cid) VALUES (2,2);
INSERT INTO registration (sid, cid) VALUES (2,4);
INSERT INTO registration (sid, cid) VALUES (3,1);
INSERT INTO registration (sid, cid) VALUES (4,8);
INSERT INTO registration (sid, cid) VALUES (4,9);
INSERT INTO registration (sid, cid) VALUES (5,5);
INSERT INTO registration (sid, cid) VALUES (1,9);


select * from registration;


--table course_content
CREATE TABLE course_content(
    ccid INTEGER DEFAULT nextval('course_content_ccid_seq') NOT NULL PRIMARY KEY,
    content_link VARCHAR NOT NULL,
    duration NUMERIC(5,2) NOT NULL,
    last_update TIMESTAMPTZ DEFAULT Now(),
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    CONSTRAINT unique_link UNIQUE(content_link)
);

--keep track of when the course content has been updated last time
CREATE TRIGGER course_content_last_updated BEFORE UPDATE ON course_content FOR EACH ROW EXECUTE PROCEDURE last_updated();

--inisializing table course_content, schema: lms_sch2
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c11',12.25,1);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c21',7.2,2);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c22',10,2);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c12',12,1);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c41',7,4);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c51',15,5);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c31',21.5,3);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c32',25.2,3);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c42',3,4);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c81',9,8);
INSERT INTO course_content (content_link, duration, cid) VALUES ('lms.com/c91',14,9);

SELECT * FROM course_content;



--table feedback
CREATE TABLE 	feedback (
    fid INTEGER DEFAULT nextval('feedback_fid_seq') NOT NULL,
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    rate NUMERIC(2,1) NOT NULL,
    comment VARCHAR,
    last_update TIMESTAMPTZ DEFAULT Now(),
    PRIMARY KEY (fid, sid, cid),
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5),
    CONSTRAINT each_course_one_feedback_from_each_std UNIQUE (sid,cid)
);

--keep track of when the feedbacl has been inserted/updated last time
CREATE TRIGGER feedback_last_updated BEFORE UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE last_updated();

--after each feedback the rate of the corresponding course and instructor will be updated
CREATE TRIGGER new_rate AFTER INSERT OR UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE new_rate();

--only registered students are allowed to give feedback
CREATE TRIGGER prevent_invalid_feedback BEFORE INSERT OR UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_feedback();

--inisializing table feedback, schema: lms_sch2
INSERT INTO feedback (sid, cid, rate, comment) VALUES (1, 1, 4.8, 'super!');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (2, 2, 4, 'Very Good and comprehensive.');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (3, 1, 3, 'some content are outdated');
INSERT INTO feedback (sid, cid, rate) VALUES (2, 4, 4.2);
INSERT INTO feedback (sid, cid, rate, comment) VALUES (1, 9, 4.2, 'Well structured');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (4, 9, 4.7, 'Great!');
INSERT INTO feedback (sid, cid, rate, comment) VALUES (4, 8, 2.5, 'Should improve!');
INSERT INTO feedback (sid, cid, rate) VALUES (5, 5, 5);

SELECT * FROM feedback;
SELECT * FROM instructor;


--table progress
CREATE TABLE progress (
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    ccid INTEGER REFERENCES course_content ON DELETE CASCADE,
    hasDone BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (sid, ccid)
);

--only students with access to the course content can make progress in that course/course content
CREATE TRIGGER prevent_invalid_progress BEFORE INSERT OR UPDATE ON progress FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_progress();


--inisializing table progress, schema: lms_sch2
INSERT INTO progress (sid, ccid, hasDone) VALUES (1,1,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (2,2,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (2,3,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (1,11,TRUE);
INSERT INTO progress (sid, ccid, hasDone) VALUES (4,10,TRUE);


SELECT * FROM progress;





--creatint the third schema
CREATE SCHEMA lms_sch3;

--set the path, also public in order to use the functions,extentions and domains
SET SEARCH_PATH TO lms_sch3, public;


--BEGIN of All the SEQUENCES part

--for sid, table student
CREATE SEQUENCE student_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for iid, table instructor
CREATE SEQUENCE instructor_iid_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;

--for cid, table course
CREATE SEQUENCE course_cid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for ccid, table course_content
CREATE SEQUENCE course_content_ccid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--for fid, table feedback
CREATE SEQUENCE feedback_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- END of part creating SEQUENCES



--BEGIN the part CREATING TABLES


--table studnet
CREATE TABLE student (
    sid INTEGER DEFAULT nextval('student_sid_seq') NOT NULL PRIMARY KEY,
    username VARCHAR(45) NOT NULL,
    email type_email NOT NULL,
    password VARCHAR(45) NOT NULL
);

--inisializing table student, schema: lms_sch3
\COPY student (sid, username, email, password) FROM '/docker-entrypoint-initdb.d/sample/LMS_Student.csv' WITH DELIMITER AS ',' CSV;

SELECT * FROM student LIMIT 10;


--table instructor
CREATE TABLE instructor (
    iid INTEGER DEFAULT nextval('instructor_iid_seq') NOT NULL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email type_email NOT NULL,
    rate NUMERIC(2,1) DEFAULT NULL,
    description VARCHAR,
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5)
);


--inisializing table instructor, schema: lms_sch3
\COPY instructor (iid, first_name, last_name, email, description) FROM '/docker-entrypoint-initdb.d/sample/LMS_Instructor.csv' WITH DELIMITER AS ',' CSV;

SELECT * FROM instructor LIMIT 10;


--table course
CREATE TABLE course (
    cid INTEGER DEFAULT nextval('course_cid_seq') NOT NULL PRIMARY KEY,
    title VARCHAR(45) NOT NULL,
    main_category VARCHAR(45) NOT NULL,
    sub_category VARCHAR(45) NOT NULL,
    rate NUMERIC(2,1) DEFAULT NULL,
    price NUMERIC(5,2),
    iid INTEGER REFERENCES instructor ON DELETE CASCADE,
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5)
);


--inisializing table course, schema: lms_sch3
\COPY course (cid,title, main_category, sub_category, price, iid) FROM '/docker-entrypoint-initdb.d/sample/LMS_Course.csv' WITH DELIMITER AS ',' CSV;

SELECT * FROM course LIMIT 10;



--table registration
CREATE TABLE registration (
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    registration_date TIMESTAMPTZ DEFAULT Now(),
    PRIMARY KEY (sid, cid)
);


--inisializing table registration, schema: lms_sch3
\COPY registration (sid, cid, registration_date) FROM '/docker-entrypoint-initdb.d/sample/LMS_Registration.csv' WITH DELIMITER AS ',' CSV;


select * from registration LIMIT 10;


--table course_content
CREATE TABLE course_content(
    ccid INTEGER DEFAULT nextval('course_content_ccid_seq') NOT NULL PRIMARY KEY,
    content_link VARCHAR NOT NULL,
    duration NUMERIC(5,2) NOT NULL,
    last_update TIMESTAMPTZ DEFAULT Now(),
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    CONSTRAINT unique_link UNIQUE(content_link)
);

--keep track of when the course content has been updated last time
CREATE TRIGGER course_content_last_updated BEFORE UPDATE ON course_content FOR EACH ROW EXECUTE PROCEDURE last_updated();

--inisializing table course_content, schema: lms_sch3
\COPY course_content (ccid, content_link, duration, last_update, cid) FROM '/docker-entrypoint-initdb.d/sample/LMS_CourseContent.csv' WITH DELIMITER AS ',' CSV;

SELECT * FROM course_content LIMIT 10;



--table feedback
CREATE TABLE 	feedback (
    fid INTEGER DEFAULT nextval('feedback_fid_seq') NOT NULL,
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    cid INTEGER REFERENCES course ON DELETE CASCADE,
    rate NUMERIC(2,1) NOT NULL,
    comment VARCHAR,
    last_update TIMESTAMPTZ DEFAULT Now(),
    PRIMARY KEY (fid, sid, cid),
    CONSTRAINT rating CHECK (rate >= 1 and rate<=5),
    CONSTRAINT each_course_one_feedback_from_each_std UNIQUE (sid,cid)
);

--keep track of when the feedbacl has been inserted/updated last time
CREATE TRIGGER feedback_last_updated BEFORE UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE last_updated();

--after each feedback the rate of the corresponding course and instructor will be updated
CREATE TRIGGER new_rate AFTER INSERT OR UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE new_rate();

--only registered students are allowed to give feedback
CREATE TRIGGER prevent_invalid_feedback BEFORE INSERT OR UPDATE ON feedback FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_feedback();

--inisializing table feedback, schema: lms_sch3


-- SELECT * FROM feedback;



--table progress
CREATE TABLE progress (
    sid INTEGER REFERENCES student ON DELETE CASCADE,
    ccid INTEGER REFERENCES course_content ON DELETE CASCADE,
    hasDone BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (sid, ccid)
);

--only students with access to the course content can make progress in that course/course content
CREATE TRIGGER prevent_invalid_progress BEFORE INSERT OR UPDATE ON progress FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_progress();


--inisializing table progress, schema: lms_sch3


-- SELECT * FROM progress;


--Indexes

CREATE INDEX main_category_idx ON course (main_category);
CREATE INDEX sub_category_idx ON course (sub_category);




--Create Roles

SET SEARCH_PATH TO lms_sch1;

--creating a new user to who has the role of an instructor

CREATE ROLE instructor_client WITH PASSWORD '123';
GRANT CONNECT ON DATABASE lmsceo TO instructor_client;
ALTER ROLE instructor_client WITH LOGIN;

GRANT USAGE ON SCHEMA lms_sch1 TO instructor_client;
GRANT SELECT ON instructor,course,course_content,feedback TO instructor_client;

GRANT USAGE ON SEQUENCE instructor_iid_seq TO instructor_client;
GRANT INSERT (first_name, last_name, email, description) ON instructor TO instructor_client;
GRANT UPDATE (email, description) ON instructor TO instructor_client;

GRANT USAGE ON SEQUENCE course_cid_seq TO instructor_client;
GRANT INSERT (title, main_category, sub_category, price, iid) ON course TO instructor_client;

GRANT USAGE ON SEQUENCE course_content_ccid_seq TO instructor_client;
GRANT INSERT (content_link, duration, cid) ON course_content TO instructor_client;
GRANT UPDATE (duration) ON course_content TO instructor_client;


--creating a new user to who has the role of a student

CREATE ROLE student_client WITH PASSWORD '123';
GRANT CONNECT ON DATABASE lmsceo TO student_client;
ALTER ROLE student_client WITH LOGIN;

GRANT USAGE ON SCHEMA lms_sch1 TO student_client;
GRANT SELECT ON instructor,course,course_content,feedback,progress TO student_client;

GRANT USAGE ON SEQUENCE student_sid_seq TO student_client;
GRANT INSERT (username, email, password) ON student TO student_client;
GRANT UPDATE (email, password) ON student TO student_client;

GRANT INSERT (sid, cid) ON registration TO student_client;

GRANT USAGE ON SEQUENCE feedback_fid_seq TO student_client;
GRANT INSERT (sid, cid, rate, comment) ON feedback TO student_client;
GRANT UPDATE (rate, comment) ON feedback TO student_client;
