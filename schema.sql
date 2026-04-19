-- =========================================
-- 1) Users
-- =========================================
CREATE TABLE dbo.Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    role NVARCHAR(30) NOT NULL
        CHECK (role IN ('student', 'professor')),
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    is_verified BIT NOT NULL DEFAULT 0,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    phone NVARCHAR(20),
    university NVARCHAR(255),
    faculty NVARCHAR(255),
    department NVARCHAR(255)
);


-- =========================================
-- 2) Email_Verification
-- =========================================
CREATE TABLE dbo.Email_Verification (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    verification_token NVARCHAR(255) NOT NULL,
    expires_at DATETIME2 NOT NULL,
    verified_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_EmailVerification_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);


-- =========================================
-- 3) Student_Profile
-- =========================================
CREATE TABLE dbo.Student_Profile (
    user_id INT PRIMARY KEY,
    degree_level NVARCHAR(50),
    class_year INT,
    gpa DECIMAL(3,2),
    expected_graduation_date DATE,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_StudentProfile_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);


-- =========================================
-- 4) Professor_Profile
-- =========================================
CREATE TABLE dbo.Professor_Profile (
    user_id INT PRIMARY KEY,
    academic_title NVARCHAR(100),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_ProfessorProfile_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);


-- =========================================
-- 5) Jobs
-- =========================================
CREATE TABLE dbo.Jobs (
    job_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    job_category NVARCHAR(100) NOT NULL,
    department_name NVARCHAR(255) NOT NULL,
    position NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    deadline DATE NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Jobs_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);


-- =========================================
-- 6) Job_Applicants
-- =========================================
CREATE TABLE dbo.Job_Applicants (
    id INT IDENTITY(1,1) PRIMARY KEY,
    job_id INT NOT NULL,
    user_id INT NOT NULL,
    status NVARCHAR(50) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected')),
    applied_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_JobApplicants_JobUser UNIQUE (job_id, user_id),

    CONSTRAINT FK_JobApplicants_Jobs
        FOREIGN KEY (job_id) REFERENCES dbo.Jobs(job_id) ON DELETE CASCADE,

    CONSTRAINT FK_JobApplicants_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);


-- =========================================
-- 7) Skills
-- =========================================
CREATE TABLE dbo.Skills (
    skill_id INT IDENTITY(1,1) PRIMARY KEY,
    skill_name NVARCHAR(100) NOT NULL UNIQUE
);


-- =========================================
-- 8) Languages
-- =========================================
CREATE TABLE dbo.Languages (
    language_id INT IDENTITY(1,1) PRIMARY KEY,
    language_name NVARCHAR(100) NOT NULL UNIQUE
);


-- =========================================
-- 9) User_Skills
-- =========================================
CREATE TABLE dbo.User_Skills (
    user_id INT NOT NULL,
    skill_id INT NOT NULL,

    CONSTRAINT PK_UserSkills PRIMARY KEY (user_id, skill_id),

    CONSTRAINT FK_UserSkills_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,

    CONSTRAINT FK_UserSkills_Skills
        FOREIGN KEY (skill_id) REFERENCES dbo.Skills(skill_id) ON DELETE CASCADE
);


-- =========================================
-- 10) User_Languages
-- =========================================
CREATE TABLE dbo.User_Languages (
    user_id INT NOT NULL,
    language_id INT NOT NULL,
    level NVARCHAR(50) NOT NULL
        CHECK (level IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'NATIVE')),

    CONSTRAINT PK_UserLanguages PRIMARY KEY (user_id, language_id),

    CONSTRAINT FK_UserLanguages_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,

    CONSTRAINT FK_UserLanguages_Languages
        FOREIGN KEY (language_id) REFERENCES dbo.Languages(language_id) ON DELETE CASCADE
);


-- =========================================
-- 11) User_Experiences
-- =========================================
CREATE TABLE dbo.User_Experiences (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    company_name NVARCHAR(255),
    position NVARCHAR(255),
    description NVARCHAR(MAX),
    start_date DATE,
    end_date DATE,

    CONSTRAINT FK_UserExperiences_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);


-- =========================================
-- 12) User_Educations
-- =========================================
CREATE TABLE dbo.User_Educations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    university NVARCHAR(255),
    department NVARCHAR(255),
    gpa DECIMAL(3,2),
    start_date DATE,
    end_date DATE,

    CONSTRAINT FK_UserEducations_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);


-- =========================================
-- INDEXES
-- =========================================

CREATE INDEX IX_Jobs_Active
ON dbo.Jobs(job_category, deadline, created_at DESC)
WHERE is_active = 1;

CREATE INDEX IX_JobApplicants_JobId
ON dbo.Job_Applicants(job_id);

CREATE INDEX IX_JobApplicants_UserId
ON dbo.Job_Applicants(user_id);

CREATE INDEX IX_EmailVerification_UserId
ON dbo.Email_Verification(user_id);

CREATE INDEX IX_UserExperiences_UserId
ON dbo.User_Experiences(user_id);

CREATE INDEX IX_UserEducations_UserId
ON dbo.User_Educations(user_id);





