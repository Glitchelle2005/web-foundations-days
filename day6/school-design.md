# School Database Design

## Tables

- **Students** stores each student's name and unique email address.
- **Courses** stores each course and its instructor.
- **Enrolments** records which student takes which course, along with the grade.

## Relationships

One student can have many enrolments, and one course can have many enrolments. Students and courses therefore have a many-to-many relationship: a student can take several courses, and a course can have several students. The enrolments table joins them and stores the grade for each student in each course. It also prevents the same student from being added to the same course twice.

## Index

I added an index on the enrolments table's `course_id`. It can help the database find the students on a course more quickly.

## SQL or NoSQL?

I would use SQL for this system. Students, courses, and enrolments have clear relationships, and the database can use keys to keep those links correct. SQL also makes it easy to ask questions such as how many students are in each course.
