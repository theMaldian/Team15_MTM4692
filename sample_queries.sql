-- =========================
-- SQL QUERY EXAMPLES
-- =========================

-- 1) List Active Job Postings
-- Function: Lists all active assistantship positions with valid deadlines.

SELECT
    job_id,
    job_category,
    department_name,
    position,
    description,
    deadline,
    created_at
FROM Jobs
WHERE is_active = 1
  AND deadline >= CAST(GETDATE() AS DATE)
ORDER BY created_at DESC;



-- 2) List Applicants for a Specific Job
-- Function: Displays students who applied to a specific job with their academic details.

SELECT
    ja.job_id,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.department,
    sp.class_year,
    sp.gpa,
    ja.status,
    ja.applied_at
FROM Job_Applicants ja
INNER JOIN Users u
    ON ja.user_id = u.user_id
INNER JOIN Student_Profile sp
    ON u.user_id = sp.user_id
WHERE ja.job_id = 1
ORDER BY ja.applied_at ASC;



-- =========================
-- VIEW EXAMPLE
-- =========================

-- View: Student Applications
-- Function: Simplifies queries for showing jobs that a student has applied to.

GO

CREATE VIEW vw_student_applications AS
SELECT
    ja.user_id,
    ja.job_id,
    j.job_category,
    j.department_name,
    j.position,
    j.deadline,
    ja.status,
    ja.applied_at
FROM Job_Applicants ja
INNER JOIN Jobs j
    ON ja.job_id = j.job_id;
GO



-- Example usage of the view
SELECT *
FROM vw_student_applications
WHERE user_id = 5;



-- =========================
-- CTE EXAMPLE
-- =========================

-- CTE: Student CV Generation
-- Function: Combines multiple tables to generate a full CV-like structure.

WITH StudentCV AS (
    SELECT
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.phone,
        u.university,
        u.faculty,
        u.department,
        sp.degree_level,
        sp.class_year,
        sp.gpa,
        sp.expected_graduation_date,
        ue.company_name,
        ue.position AS experience_position,
        ue.start_date AS experience_start_date,
        ue.end_date AS experience_end_date,
        ed.university AS education_university,
        ed.department AS education_department,
        ed.gpa AS education_gpa
    FROM Users u
    LEFT JOIN Student_Profile sp
        ON u.user_id = sp.user_id
    LEFT JOIN User_Experiences ue
        ON u.user_id = ue.user_id
    LEFT JOIN User_Educations ed
        ON u.user_id = ed.user_id
    WHERE u.user_id = 5
)

SELECT *
FROM StudentCV;