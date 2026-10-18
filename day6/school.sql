PRAGMA foreign_keys = ON;

CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    course_name TEXT NOT NULL,
    instructor TEXT NOT NULL
);

CREATE TABLE enrolments (
    enrolment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    FOREIGN KEY (course_id) REFERENCES courses (course_id),
    UNIQUE (student_id, course_id)
);

CREATE INDEX idx_enrolments_course_id ON enrolments (course_id);

INSERT INTO students (student_id, name, email) VALUES
    (1, 'Amina Hassan', 'amina@example.com'),
    (2, 'Brian Otieno', 'brian@example.com'),
    (3, 'Chao Mwangi', 'chao@example.com'),
    (4, 'Diana Njeri', 'diana@example.com');

INSERT INTO courses (course_id, course_name, instructor) VALUES
    (1, 'Mathematics', 'Ms. Patel'),
    (2, 'Biology', 'Mr. Kimani'),
    (3, 'History', 'Ms. Clarke');

INSERT INTO enrolments (enrolment_id, student_id, course_id, grade) VALUES
    (1, 1, 1, 'A'),
    (2, 1, 2, 'B'),
    (3, 2, 1, 'B'),
    (4, 2, 3, 'A'),
    (5, 3, 2, 'A');

-- All courses taken by one student, selected by name.
SELECT c.course_name, e.grade
FROM students AS s
JOIN enrolments AS e ON e.student_id = s.student_id
JOIN courses AS c ON c.course_id = e.course_id
WHERE s.name = 'Amina Hassan';

-- All students enrolled in one course, selected by course name.
SELECT s.name, s.email, e.grade
FROM courses AS c
JOIN enrolments AS e ON e.course_id = c.course_id
JOIN students AS s ON s.student_id = e.student_id
WHERE c.course_name = 'Mathematics';

-- Number of enrolled students per course, including courses with none.
SELECT c.course_name, COUNT(e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrolments AS e ON e.course_id = c.course_id
GROUP BY c.course_id, c.course_name;

-- Students who are not enrolled in any course.
SELECT s.student_id, s.name, s.email
FROM students AS s
LEFT JOIN enrolments AS e ON e.student_id = s.student_id
WHERE e.student_id IS NULL;

-- Update one student's grade in one course.
UPDATE enrolments
SET grade = 'A'
WHERE enrolment_id = 3;
