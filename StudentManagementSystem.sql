-- ========================
-- Student Management System
-- ========================

-- Description:
-- A database system to manage students, courses, enrollments, and attendance.
-- Includes features like attendance tracking, course management, and user roles.
-- Designed for educational institutions.

-- ========================
-- 1. Create Database
-- ========================
CREATE DATABASE IF NOT EXISTS StudentManagement;
USE StudentManagement;

-- ========================
-- 2. Drop Existing Tables
-- ========================
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Attendance;
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Students;

-- ========================
-- 3. Create Tables
-- ========================

-- Students Table: Stores student personal information.
CREATE TABLE Students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age > 0 AND age < 120),
    email VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(255)
);

-- Courses Table: Stores course details.
CREATE TABLE Courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) DEFAULT 'No description available', -- Changed TEXT to VARCHAR(255)
    credits INT NOT NULL CHECK (credits > 0)
);


-- Enrollments Table: Links students to courses.
CREATE TABLE Enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURDATE()), -- Adjusted to use parentheses
    FOREIGN KEY (student_id) REFERENCES Students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(id) ON DELETE CASCADE,
    UNIQUE (student_id, course_id) -- Prevent duplicate enrollments
);



-- Attendance Table: Tracks student attendance.
CREATE TABLE Attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late') NOT NULL,
    FOREIGN KEY (enrollment_id) REFERENCES Enrollments(id) ON DELETE CASCADE
);

-- Users Table: Manages user roles and authentication.
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Teacher', 'Student') NOT NULL
);

-- ========================
-- 4. Insert Sample Data
-- ========================

-- Insert Students
INSERT INTO Students (name, age, email, address)
VALUES 
('Peter Parker', 23, 'peter11@gmail.com', '123 Maple Street'),
('Gwen Stacy', 22, 'gwenstacy08@gmail.com', '456 Oak Avenue'),
('May Parker', 51, 'pmay51@gmail.com', '51 Station Street');

-- Insert Courses
INSERT INTO Courses (name, description, credits)
VALUES 
('Software Engineering', 'Data Structures and Algorithms', 3),
('Biology', 'Statistical Biology', 4),
('Artificial Intelligence', 'Neural Networks', 2);

-- Insert Enrollments
INSERT INTO Enrollments (student_id, course_id, enrollment_date)
VALUES
(1, 1, '2025-01-01'),
(2, 2, '2025-01-02'),
(3, 3, '2025-01-03');

-- Insert Attendance
INSERT INTO Attendance (enrollment_id, attendance_date, status)
VALUES
(1, '2025-01-03', 'Present'),
(2, '2025-01-03', 'Absent'),
(1, '2025-01-03', 'Present');

-- Insert Users
INSERT INTO Users (username, password_hash, role)
VALUES
('admin', 'hashedpassword123', 'Admin'),
('teacher1', 'hashedpassword456', 'Teacher'),
('student1', 'hashedpassword789', 'Student');

-- ========================
-- 5. Views for Common Queries
-- ========================

-- View: List students and their enrolled courses.
CREATE VIEW StudentCourses AS
SELECT 
    s.id AS student_id, 
    s.name AS student_name, 
    c.name AS course_name, 
    e.enrollment_date
FROM Students s
JOIN Enrollments e ON s.id = e.student_id
JOIN Courses c ON e.course_id = c.id;

-- View: Attendance Summary
CREATE VIEW AttendanceSummary AS
SELECT 
    e.student_id,
    s.name AS student_name,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS total_present,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS total_absent,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS total_late
FROM Attendance a
JOIN Enrollments e ON a.enrollment_id = e.id
JOIN Students s ON e.student_id = s.id
GROUP BY e.student_id, s.name;

-- ========================
-- 6. Stored Procedures
-- ========================

-- Procedure: Enroll a student in a course.
DELIMITER //
CREATE PROCEDURE EnrollStudent(IN student_id INT, IN course_id INT)
BEGIN
    INSERT INTO Enrollments (student_id, course_id, enrollment_date)
    VALUES (student_id, course_id, CURDATE());
END //
DELIMITER ;

-- Procedure: Mark attendance.
DELIMITER //
CREATE PROCEDURE MarkAttendance(
    IN enrollment_id INT, 
    IN attendance_date DATE, 
    IN status ENUM('Present', 'Absent', 'Late')
)
BEGIN
    INSERT INTO Attendance (enrollment_id, attendance_date, status)
    VALUES (enrollment_id, attendance_date, status);
END //
DELIMITER ;

-- ========================
-- 7. Indexes for Optimization
-- ========================

-- Ensure indexes are not duplicated by dropping existing ones
DROP INDEX IF EXISTS idx_student_name ON Students;
DROP INDEX IF EXISTS idx_course_name ON Courses;

-- Create indexes to optimize queries
CREATE INDEX idx_student_name ON Students(name);
CREATE INDEX idx_course_name ON Courses(name);

-- ========================
-- 8. Views for Common Queries
-- ========================

-- Drop existing views to prevent duplication
DROP VIEW IF EXISTS AttendanceSummary;

-- Create the AttendanceSummary view to summarize attendance
CREATE VIEW AttendanceSummary AS
SELECT 
    e.student_id,
    s.name AS student_name,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS total_present,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS total_absent,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS total_late
FROM Attendance a
JOIN Enrollments e ON a.enrollment_id = e.id
JOIN Students s ON e.student_id = s.id
GROUP BY e.student_id, s.name;
