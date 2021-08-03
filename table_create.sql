use njit;

-- ----------------------
-- Create Student table
-- ----------------------
CREATE TABLE student
(
  student_id  int(4)   PRIMARY KEY ,
  student_name  char(50)  NULL ,
  student_add  char(80)   NULL ,
  student_ssn  int(9)    NULL ,
  student_year  int(4)   NULL ,
  student_hs  char(30)  NULL
);

-- -----------------------
-- Create Staff table
-- -----------------------
CREATE TABLE staff
(
  staff_ssn  int(9)  PRIMARY KEY ,
  staff_name  char(30)  NULL ,
  staff_add  char(100)   NULL ,
  staff_salary  int(10)  NULL
);

-- -------------------
-- Create Course table
-- -------------------
CREATE TABLE course
(
  course_code  char(6)  PRIMARY KEY ,
  course_name   char(30)  NULL ,
  credit  int(1)  NULL ,
  ta_hrs_req  int(2)  NULL
);

-- -----------------------
-- Create Department table
-- -----------------------
CREATE TABLE department
(
  dept_code   char(3)  PRIMARY KEY ,
  dept_name   char(30)  NULL ,
  annual_budget  int(10)  NULL
);

-- ---------------------
-- Create Building table
-- ---------------------
CREATE TABLE building
(
  build_id  int(3)  PRIMARY KEY ,
  build_name  char(50)  NULL ,
  location  char(50)  NULL
);

-- ---------------------
-- Create Section table
-- ---------------------
CREATE TABLE section
(
  sec_no  int(3)  NOT NULL,
  course_code char(6) NOT NULL,
  max_enroll  int(3)  NULL
);
ALTER TABLE section ADD
(
  PRIMARY KEY (sec_no, course_code)
);

-- ---------------------
-- Create Room table
-- ---------------------
CREATE TABLE room
(
  room_no  int(4)  NOT NULL,
  build_id int(3) NOT NULL,
  capacity  int(3)  NULL ,
  audio_visual  char(50)  NULL
);
ALTER TABLE room ADD
(
  PRIMARY KEY (room_no, build_id)
);
-- ----------------------------------------------
-- Add Faculty and Teaching Assistant Information
-- ----------------------------------------------
ALTER TABLE staff ADD
(
  `function` char(20) NULL,
  `rank`  char(10)  NULL,
  course_load  int(2)  NULL,
  work_hr  int(2)  NULL
);


-- -------------------
-- Define foreign keys
-- -------------------
ALTER TABLE student ADD
(
  major char(6) NOT NULL,
  FOREIGN KEY (major) REFERENCES department(dept_code)
);

ALTER TABLE course ADD
(
  dept_code char(6) NOT NULL,
  FOREIGN KEY (dept_code) REFERENCES department(dept_code)
);

ALTER TABLE department ADD
(
  dept_location int(3) NOT NULL,
  dept_chair int(9) NOT NULL,
  FOREIGN KEY (dept_location) REFERENCES building(build_id),
  FOREIGN KEY (dept_chair) REFERENCES staff(staff_ssn)
);

ALTER TABLE section ADD
(
  instructor_ssn int(9) NOT NULL,
  FOREIGN KEY (instructor_ssn) REFERENCES staff(staff_ssn),
  FOREIGN KEY (course_code) REFERENCES course(course_code)
);

ALTER TABLE room ADD
(
  FOREIGN KEY (build_id) REFERENCES building(build_id)
);

-- -------------------
-- Define relationship tables
-- -------------------

CREATE TABLE faculty_department
(
  staff_ssn int(9) NOT NULL,
  dept_code char(3) NOT NULL,
  FOREIGN KEY (staff_ssn) REFERENCES staff(staff_ssn),
  FOREIGN KEY (dept_code) REFERENCES department(dept_code)
);

ALTER TABLE faculty_department ADD
(
  PRIMARY KEY (staff_ssn, dept_code)
);

CREATE TABLE assignment
(
  staff_ssn int(9) NOT NULL,
  course_code char(6) NOT NULL,
  sec_no int(3) NOT NULL,
  FOREIGN KEY (staff_ssn) REFERENCES staff(staff_ssn),
  FOREIGN KEY (course_code, sec_no) REFERENCES section(course_code, sec_no)
);

ALTER TABLE assignment ADD
(
  PRIMARY KEY (staff_ssn, course_code, sec_no)
);

CREATE TABLE registrations
(
  student_id int(4) NOT NULL,
  sec_no int(3) NOT NULL,
  course_code char(6) NOT NULL,
  FOREIGN KEY (student_id) REFERENCES student(student_id),
  FOREIGN KEY (course_code, sec_no) REFERENCES section(course_code, sec_no)
);

CREATE TABLE section_in_room
(
  build_id int(3) NOT NULL,
  room_no int(4) NOT NULL,
  course_code char(6) NOT NULL,
  sec_no int(3) NOT NULL,
  weekday char(2) NOT NULL,
  time int(4) NOT NULL,
  FOREIGN KEY (build_id) REFERENCES building(build_id),
  FOREIGN KEY (room_no) REFERENCES room(room_no),
  FOREIGN KEY (course_code, sec_no) REFERENCES section(course_code, sec_no)
);

ALTER TABLE section_in_room ADD
(
  PRIMARY KEY (build_id, room_no, course_code, sec_no, weekday, time)
);

-- ------------------------
-- Populate staff table
-- ------------------------
INSERT INTO staff(staff_ssn, staff_name, staff_add, staff_salary)
VALUES
    ('332980909', 'Karen Piper', '2 Wonder Way', '125000'),
    ('121980787', 'Ed Norton', '14 Pumpkin Pike', '110000'),
    ('450230098', 'Jack Johnson', '90 Meslar Road', '115000'),
    ('123990012', 'Julie Ahn', '17 Cunningham Way', '117000');


-- ------------------------
-- Populate building table
-- ------------------------
INSERT INTO building(build_id, build_name, location)
VALUES
       (001, 'Hazard Hall', 'East Wing'),
       (002, 'Diagon Alley', 'West Wing'),
       (003, 'Diagon Alley', 'West Wing');

-- ------------------------
-- Populate room table
-- ------------------------
INSERT INTO room(room_no, build_id, capacity, audio_visual)
VALUES
    (1001, 001, 30, 'Smart Screen'),
    (1002, 001, 30, 'None'),
    (2001, 001, 30, 'Whiteboard');


-- ------------------------
-- Populate department table
-- ------------------------
INSERT INTO department(dept_code, dept_name, annual_budget, dept_location, dept_chair)
VALUES
    ('CS', 'Computer Science', '400000', 001, 332980909),
    ('BZA', 'Business Admin', '500000', 001, 121980787),
    ('ENG', 'English', '300000', 002, 450230098),
    ('HIS', 'History', '200000', 003, 123990012);


-- ------------------------
-- Populate student table
-- ------------------------
INSERT INTO student(student_id, student_name, student_add, student_ssn, student_year, student_hs, major)
VALUES
    (1001, 'John Smith', '200 Maple Lane', '123456789', '2012', 'Seton Hall', 'CS'),
    (1002, 'Brian Carol', '2 Low Drive', '234567899', '2011', 'Delbarton', 'CS'),
    (1003, 'Jane Hamilton', '3 Copperton Way', '434860098', '2012', 'Morristown', 'BZA'),
    (1004, 'Josh Lurie', '4 Tight Road', '122345546', '2011', 'Randolph', 'ENG'),
    (1005, 'Dusty Hill', '72 Cool Hand Luke Lane', '009727272', '2012', 'Columbia', 'HIS');


-- ------------------------
-- Populate course table
-- ------------------------
INSERT INTO course(course_code, course_name, credit, ta_hrs_req, dept_code)
VALUES
    ('CS123', 'Computer Studies', 3, 6, 'CS'),
    ('BS101', 'Business Studies', 3, 4, 'BZA'),
    ('EG200', 'Writing', 3, 6, 'ENG'),
    ('HH400', 'History', 3, 8, 'HIS');


-- ------------------------
-- Populate section table
-- ------------------------
INSERT INTO section(sec_no, course_code, max_enroll, instructor_ssn)
VALUES
    (001, 'CS123', 3, 450230098),
    (002, 'CS123', 30, 450230098),
    (003, 'CS123', 30, 450230098);

-- ------------------------
-- Populate section_in_room table
-- ------------------------
INSERT INTO section_in_room(build_id, room_no, course_code, sec_no, weekday, time)
VALUES
    (001, 1001, 'CS123', 001, 'MO', '1020'),
    (001, 1001, 'CS123', 001, 'WE', '1020'),
    (001, 1001, 'CS123', 002, 'TU', '1020'),
    (001, 1001, 'CS123', 002, 'TH', '1020'),
    (001, 1001, 'CS123', 003, 'W', '1800');

-- ------------------------
-- Populate registrations table
-- ------------------------
INSERT INTO registrations(student_id, sec_no, course_code)
VALUES
    (1002, 1, 'CS123'),
    (1003, 1, 'CS123'),
    (1004, 1, 'CS123');


-- ------------------------
-- Make sure courses don't over-enroll
-- ------------------------
DELIMITER //
CREATE TRIGGER check_max_enroll
BEFORE INSERT ON registrations
FOR EACH ROW
BEGIN
     IF (SELECT COUNT(*) FROM registrations r WHERE r.sec_no = NEW.sec_no) >=
        (SELECT s.max_enroll from section s WHERE s.sec_no = NEW.sec_no)
     THEN SET NEW.sec_no = NULL;
     END IF;
END//


-- >----- TRIGGERS ------< --

-- ------------------------
-- Make sure courses don't overlap for a given student
-- ------------------------
CREATE TRIGGER check_schedule
BEFORE INSERT ON registrations
FOR EACH ROW
BEGIN
     IF (
         SELECT COUNT(*)
         FROM  section s, section_in_room sr
         WHERE NEW.sec_no = s.sec_no
         AND NEW.course_code = s.course_code
         AND s.sec_no = sr.sec_no
         AND NOT EXISTS (
            SELECT sr1.weekday
            FROM registrations r1, section s1, section_in_room sr1
            WHERE r1.sec_no = s1.sec_no
            AND r1.course_code = s1.course_code
            AND s1.sec_no = sr1.sec_no
            AND r1.course_code = s1.course_code
            AND r1.student_id = NEW.student_id
            AND sr.weekday = sr1.weekday
            AND sr.time = sr1.time
         ) > 0
     )
     THEN SET NEW.sec_no = NULL;
     END IF;
END//

-- ------------------------
-- Make sure TAs don't have too many hours
-- ------------------------
DELIMITER //
CREATE TRIGGER check_hours
BEFORE INSERT ON assignment
FOR EACH ROW
BEGIN
    IF
        ((
         SELECT c.ta_hrs_req
         FROM course c
         WHERE c.course_code = NEW.course_code
        ) + (
         SELECT SUM(c.ta_hrs_req)
         FROM  assignment a, course c
         WHERE a.course_code = c.course_code
         AND a.staff_ssn = NEW.staff_ssn
        )) > (
         SELECT s.work_hr
         FROM staff s
         WHERE s.staff_ssn = NEW.staff_ssn
        )
     THEN SET NEW.staff_ssn = NULL;
     END IF;
END//
DELIMITER ;
