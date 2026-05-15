const { sql, poolPromise } = require("../config/db");

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

function requiredString(value, fieldName) {
  if (typeof value !== "string" || !value.trim()) {
    throw httpError(400, `${fieldName} is required`);
  }

  return value.trim();
}

function parseDeadline(value) {
  if (typeof value !== "string" || !value.trim()) {
    throw httpError(400, "deadline is required");
  }

  const deadline = new Date(value);

  if (Number.isNaN(deadline.getTime())) {
    throw httpError(400, "deadline must be a valid date");
  }

  return deadline;
}

function parsePositiveInt(value, fieldName) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw httpError(400, `Valid ${fieldName} is required`);
  }

  return parsed;
}

function optionalString(value, fieldName) {
  if (value === undefined) {
    return undefined;
  }

  if (typeof value !== "string" || !value.trim()) {
    throw httpError(400, `${fieldName} must be a non-empty string`);
  }

  return value.trim();
}

function optionalDeadline(value) {
  if (value === undefined) {
    return undefined;
  }

  return parseDeadline(value);
}

async function ensureVerifiedProfessor(request, userId, message) {
  const professorResult = await request
    .input("professor_check_user_id", sql.Int, userId)
    .query(`
      SELECT user_id
      FROM dbo.Users
      WHERE user_id = @professor_check_user_id
        AND role = 'professor'
        AND is_verified = 1
    `);

  if (professorResult.recordset.length === 0) {
    throw httpError(403, message);
  }
}

async function ensureVerifiedStudent(request, userId, message) {
  const studentResult = await request
    .input("student_check_user_id", sql.Int, userId)
    .query(`
      SELECT user_id
      FROM dbo.Users
      WHERE user_id = @student_check_user_id
        AND role = 'student'
        AND is_verified = 1
    `);

  if (studentResult.recordset.length === 0) {
    throw httpError(403, message);
  }
}

async function createJob(userId, data) {
  const jobCategory = requiredString(data.job_category, "job_category");
  const departmentName = requiredString(data.department_name, "department_name");
  const position = requiredString(data.position, "position");
  const description = requiredString(data.description, "description");
  const deadline = parseDeadline(data.deadline);

  const pool = await poolPromise;

  const userResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT user_id
      FROM dbo.Users
      WHERE user_id = @user_id
        AND role = 'professor'
        AND is_verified = 1
    `);

  if (userResult.recordset.length === 0) {
    throw httpError(403, "Only verified professors can create jobs");
  }

  const result = await pool.request()
    .input("user_id", sql.Int, userId)
    .input("job_category", sql.NVarChar(100), jobCategory)
    .input("department_name", sql.NVarChar(255), departmentName)
    .input("position", sql.NVarChar(255), position)
    .input("description", sql.NVarChar(sql.MAX), description)
    .input("deadline", sql.Date, deadline)
    .query(`
      INSERT INTO dbo.Jobs
        (user_id, job_category, department_name, position, description, deadline)

      OUTPUT
        INSERTED.job_id,
        INSERTED.user_id,
        INSERTED.job_category,
        INSERTED.department_name,
        INSERTED.position,
        INSERTED.description,
        INSERTED.deadline,
        INSERTED.is_active,
        INSERTED.created_at

      VALUES
        (@user_id, @job_category, @department_name, @position, @description, @deadline)
    `);

  return {
    message: "Job created successfully",
    job: result.recordset[0]
  };
}

async function listActiveJobsForStudent(userId) {
  const pool = await poolPromise;

  const userResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT user_id
      FROM dbo.Users
      WHERE user_id = @user_id
        AND role = 'student'
        AND is_verified = 1
    `);

  if (userResult.recordset.length === 0) {
    throw httpError(403, "Only verified students can view active jobs");
  }

  const result = await pool.request()
    .query(`
      SELECT
        j.job_id,
        j.user_id AS professor_id,
        u.first_name AS professor_first_name,
        u.last_name AS professor_last_name,
        u.email AS professor_email,
        j.job_category,
        j.department_name,
        j.position,
        j.description,
        j.deadline,
        j.created_at
      FROM dbo.Jobs j
      INNER JOIN dbo.Users u
        ON u.user_id = j.user_id
      WHERE j.is_active = 1
        AND j.deadline >= CAST(SYSDATETIME() AS DATE)
      ORDER BY j.created_at DESC
    `);

  return {
    jobs: result.recordset
  };
}

async function listJobsForProfessor(userId) {
  const pool = await poolPromise;

  const professorResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT user_id
      FROM dbo.Users
      WHERE user_id = @user_id
        AND role = 'professor'
        AND is_verified = 1
    `);

  if (professorResult.recordset.length === 0) {
    throw httpError(403, "Only verified professors can view their jobs");
  }

  const result = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT
        j.job_id,
        j.job_category,
        j.department_name,
        j.position,
        j.description,
        j.deadline,
        j.is_active,
        j.created_at,
        j.updated_at,
        COUNT(ja.id) AS application_count,
        SUM(CASE WHEN ja.status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
        SUM(CASE WHEN ja.status = 'approved' THEN 1 ELSE 0 END) AS approved_count,
        SUM(CASE WHEN ja.status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count
      FROM dbo.Jobs j
      LEFT JOIN dbo.Job_Applicants ja
        ON ja.job_id = j.job_id
      WHERE j.user_id = @user_id
      GROUP BY
        j.job_id,
        j.job_category,
        j.department_name,
        j.position,
        j.description,
        j.deadline,
        j.is_active,
        j.created_at,
        j.updated_at
      ORDER BY j.created_at DESC
    `);

  return {
    jobs: result.recordset
  };
}

async function getJobById(userId, role, jobId) {
  const parsedJobId = parsePositiveInt(jobId, "job_id");
  const pool = await poolPromise;

  if (role === "student") {
    await ensureVerifiedStudent(
      pool.request(),
      userId,
      "Only verified students can view job details"
    );
  } else if (role === "professor") {
    await ensureVerifiedProfessor(
      pool.request(),
      userId,
      "Only verified professors can view job details"
    );
  } else {
    throw httpError(403, "Valid user role required");
  }

  const result = await pool.request()
    .input("job_id", sql.Int, parsedJobId)
    .input("user_id", sql.Int, userId)
    .input("role", sql.NVarChar(30), role)
    .query(`
      SELECT
        j.job_id,
        j.user_id AS professor_id,
        u.first_name AS professor_first_name,
        u.last_name AS professor_last_name,
        u.email AS professor_email,
        j.job_category,
        j.department_name,
        j.position,
        j.description,
        j.deadline,
        j.is_active,
        j.created_at,
        j.updated_at,
        COUNT(ja.id) AS application_count,
        MAX(CASE WHEN ja.user_id = @user_id THEN ja.id END) AS my_application_id,
        MAX(CASE WHEN ja.user_id = @user_id THEN ja.status END) AS my_application_status
      FROM dbo.Jobs j
      INNER JOIN dbo.Users u
        ON u.user_id = j.user_id
      LEFT JOIN dbo.Job_Applicants ja
        ON ja.job_id = j.job_id
      WHERE j.job_id = @job_id
        AND (
          (@role = 'student' AND j.is_active = 1 AND j.deadline >= CAST(SYSDATETIME() AS DATE))
          OR (@role = 'professor' AND j.user_id = @user_id)
        )
      GROUP BY
        j.job_id,
        j.user_id,
        u.first_name,
        u.last_name,
        u.email,
        j.job_category,
        j.department_name,
        j.position,
        j.description,
        j.deadline,
        j.is_active,
        j.created_at,
        j.updated_at
    `);

  if (result.recordset.length === 0) {
    throw httpError(404, "Job not found");
  }

  return {
    job: result.recordset[0]
  };
}

async function updateJob(userId, jobId, data) {
  const parsedJobId = parsePositiveInt(jobId, "job_id");
  const fields = {
    job_category: optionalString(data.job_category, "job_category"),
    department_name: optionalString(data.department_name, "department_name"),
    position: optionalString(data.position, "position"),
    description: optionalString(data.description, "description"),
    deadline: optionalDeadline(data.deadline)
  };

  if (!Object.values(fields).some(value => value !== undefined)) {
    throw httpError(400, "At least one job field is required");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    await ensureVerifiedProfessor(
      transaction.request(),
      userId,
      "Only verified professors can update jobs"
    );

    const currentResult = await transaction.request()
      .input("job_id", sql.Int, parsedJobId)
      .input("user_id", sql.Int, userId)
      .query(`
        SELECT job_category, department_name, position, description, deadline
        FROM dbo.Jobs
        WHERE job_id = @job_id
          AND user_id = @user_id
      `);

    if (currentResult.recordset.length === 0) {
      throw httpError(404, "Job not found for this professor");
    }

    const current = currentResult.recordset[0];

    const result = await transaction.request()
      .input("job_id", sql.Int, parsedJobId)
      .input("job_category", sql.NVarChar(100), fields.job_category !== undefined ? fields.job_category : current.job_category)
      .input("department_name", sql.NVarChar(255), fields.department_name !== undefined ? fields.department_name : current.department_name)
      .input("position", sql.NVarChar(255), fields.position !== undefined ? fields.position : current.position)
      .input("description", sql.NVarChar(sql.MAX), fields.description !== undefined ? fields.description : current.description)
      .input("deadline", sql.Date, fields.deadline !== undefined ? fields.deadline : current.deadline)
      .query(`
        UPDATE dbo.Jobs
        SET job_category = @job_category,
            department_name = @department_name,
            position = @position,
            description = @description,
            deadline = @deadline,
            updated_at = SYSDATETIME()
        OUTPUT
          INSERTED.job_id,
          INSERTED.user_id,
          INSERTED.job_category,
          INSERTED.department_name,
          INSERTED.position,
          INSERTED.description,
          INSERTED.deadline,
          INSERTED.is_active,
          INSERTED.created_at,
          INSERTED.updated_at
        WHERE job_id = @job_id
      `);

    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Job updated successfully",
      job: result.recordset[0]
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("UPDATE JOB ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function closeJob(userId, jobId) {
  const parsedJobId = parsePositiveInt(jobId, "job_id");
  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    await ensureVerifiedProfessor(
      transaction.request(),
      userId,
      "Only verified professors can close jobs"
    );

    const result = await transaction.request()
      .input("job_id", sql.Int, parsedJobId)
      .input("user_id", sql.Int, userId)
      .query(`
        UPDATE dbo.Jobs
        SET is_active = 0,
            updated_at = SYSDATETIME()
        OUTPUT
          INSERTED.job_id,
          INSERTED.user_id,
          INSERTED.job_category,
          INSERTED.department_name,
          INSERTED.position,
          INSERTED.description,
          INSERTED.deadline,
          INSERTED.is_active,
          INSERTED.created_at,
          INSERTED.updated_at
        WHERE job_id = @job_id
          AND user_id = @user_id
      `);

    if (result.recordset.length === 0) {
      throw httpError(404, "Job not found for this professor");
    }

    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Job closed successfully",
      job: result.recordset[0]
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("CLOSE JOB ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function applyToJob(userId, jobId) {
  const parsedJobId = Number(jobId);

  if (!Number.isInteger(parsedJobId) || parsedJobId <= 0) {
    throw httpError(400, "Valid job_id is required");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    const userResult = await transaction.request()
      .input("user_id", sql.Int, userId)
      .query(`
        SELECT user_id
        FROM dbo.Users
        WHERE user_id = @user_id
          AND role = 'student'
          AND is_verified = 1
      `);

    if (userResult.recordset.length === 0) {
      throw httpError(403, "Only verified students can apply to jobs");
    }

    const jobResult = await transaction.request()
      .input("job_id", sql.Int, parsedJobId)
      .query(`
        SELECT job_id
        FROM dbo.Jobs
        WHERE job_id = @job_id
          AND is_active = 1
          AND deadline >= CAST(SYSDATETIME() AS DATE)
      `);

    if (jobResult.recordset.length === 0) {
      throw httpError(404, "Active job not found");
    }

    const existingApplication = await transaction.request()
      .input("job_id", sql.Int, parsedJobId)
      .input("user_id", sql.Int, userId)
      .query(`
        SELECT id
        FROM dbo.Job_Applicants
        WHERE job_id = @job_id
          AND user_id = @user_id
      `);

    if (existingApplication.recordset.length > 0) {
      throw httpError(409, "You have already applied to this job");
    }

    const result = await transaction.request()
      .input("job_id", sql.Int, parsedJobId)
      .input("user_id", sql.Int, userId)
      .query(`
        INSERT INTO dbo.Job_Applicants
          (job_id, user_id)

        OUTPUT
          INSERTED.id,
          INSERTED.job_id,
          INSERTED.user_id,
          INSERTED.status,
          INSERTED.applied_at

        VALUES
          (@job_id, @user_id)
      `);

    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Application submitted successfully",
      application: result.recordset[0]
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("APPLY TO JOB ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function listApplicationsForStudent(userId) {
  const pool = await poolPromise;

  const studentResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT user_id
      FROM dbo.Users
      WHERE user_id = @user_id
        AND role = 'student'
        AND is_verified = 1
    `);

  if (studentResult.recordset.length === 0) {
    throw httpError(403, "Only verified students can view their applications");
  }

  const result = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT
        ja.id AS application_id,
        ja.status,
        ja.applied_at,
        j.job_id,
        j.job_category,
        j.department_name,
        j.position,
        j.description,
        j.deadline,
        j.is_active,
        j.created_at AS job_created_at,
        p.user_id AS professor_id,
        p.first_name AS professor_first_name,
        p.last_name AS professor_last_name,
        p.email AS professor_email
      FROM dbo.Job_Applicants ja
      INNER JOIN dbo.Jobs j
        ON j.job_id = ja.job_id
      INNER JOIN dbo.Users p
        ON p.user_id = j.user_id
      WHERE ja.user_id = @user_id
      ORDER BY ja.applied_at DESC
    `);

  return {
    applications: result.recordset
  };
}

async function withdrawApplication(userId, applicationId) {
  const parsedApplicationId = parsePositiveInt(applicationId, "application_id");
  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    await ensureVerifiedStudent(
      transaction.request(),
      userId,
      "Only verified students can withdraw applications"
    );

    const result = await transaction.request()
      .input("application_id", sql.Int, parsedApplicationId)
      .input("user_id", sql.Int, userId)
      .query(`
        DELETE FROM dbo.Job_Applicants
        OUTPUT
          DELETED.id,
          DELETED.job_id,
          DELETED.user_id,
          DELETED.status,
          DELETED.applied_at
        WHERE id = @application_id
          AND user_id = @user_id
      `);

    if (result.recordset.length === 0) {
      throw httpError(404, "Application not found for this student");
    }

    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Application withdrawn successfully",
      application: result.recordset[0]
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("WITHDRAW APPLICATION ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function listApplicantsForProfessor(userId, jobId) {
  const parsedJobId = Number(jobId);

  if (!Number.isInteger(parsedJobId) || parsedJobId <= 0) {
    throw httpError(400, "Valid job_id is required");
  }

  const pool = await poolPromise;

  const professorResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT user_id
      FROM dbo.Users
      WHERE user_id = @user_id
        AND role = 'professor'
        AND is_verified = 1
    `);

  if (professorResult.recordset.length === 0) {
    throw httpError(403, "Only verified professors can view applicants");
  }

  const jobResult = await pool.request()
    .input("job_id", sql.Int, parsedJobId)
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT job_id, position, department_name
      FROM dbo.Jobs
      WHERE job_id = @job_id
        AND user_id = @user_id
    `);

  if (jobResult.recordset.length === 0) {
    throw httpError(404, "Job not found for this professor");
  }

  const applicantsResult = await pool.request()
    .input("job_id", sql.Int, parsedJobId)
    .query(`
      SELECT
        ja.id AS application_id,
        ja.status,
        ja.applied_at,
        u.user_id,
        u.email,
        u.first_name,
        u.last_name,
        u.phone,
        u.university,
        u.faculty,
        u.department,
        sp.degree_level,
        sp.class_year,
        sp.gpa,
        sp.expected_graduation_date
      FROM dbo.Job_Applicants ja
      INNER JOIN dbo.Users u
        ON u.user_id = ja.user_id
      LEFT JOIN dbo.Student_Profile sp
        ON sp.user_id = u.user_id
      WHERE ja.job_id = @job_id
      ORDER BY ja.applied_at DESC
    `);

  return {
    job: jobResult.recordset[0],
    applicants: applicantsResult.recordset
  };
}

async function updateApplicationStatus(userId, applicationId, status) {
  const parsedApplicationId = Number(applicationId);

  if (!Number.isInteger(parsedApplicationId) || parsedApplicationId <= 0) {
    throw httpError(400, "Valid application_id is required");
  }

  if (!["approved", "rejected"].includes(status)) {
    throw httpError(400, "status must be approved or rejected");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    const professorResult = await transaction.request()
      .input("user_id", sql.Int, userId)
      .query(`
        SELECT user_id
        FROM dbo.Users
        WHERE user_id = @user_id
          AND role = 'professor'
          AND is_verified = 1
      `);

    if (professorResult.recordset.length === 0) {
      throw httpError(403, "Only verified professors can update application status");
    }

    const applicationResult = await transaction.request()
      .input("application_id", sql.Int, parsedApplicationId)
      .input("professor_id", sql.Int, userId)
      .query(`
        SELECT
          ja.id,
          ja.job_id,
          ja.user_id,
          ja.status,
          ja.applied_at
        FROM dbo.Job_Applicants ja
        INNER JOIN dbo.Jobs j
          ON j.job_id = ja.job_id
        WHERE ja.id = @application_id
          AND j.user_id = @professor_id
      `);

    if (applicationResult.recordset.length === 0) {
      throw httpError(404, "Application not found for this professor");
    }

    const result = await transaction.request()
      .input("application_id", sql.Int, parsedApplicationId)
      .input("status", sql.NVarChar(50), status)
      .query(`
        UPDATE dbo.Job_Applicants
        SET status = @status
        OUTPUT
          INSERTED.id,
          INSERTED.job_id,
          INSERTED.user_id,
          INSERTED.status,
          INSERTED.applied_at
        WHERE id = @application_id
      `);

    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Application status updated successfully",
      application: result.recordset[0]
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("UPDATE APPLICATION STATUS ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

module.exports = {
  createJob,
  listActiveJobsForStudent,
  listJobsForProfessor,
  getJobById,
  updateJob,
  closeJob,
  applyToJob,
  listApplicationsForStudent,
  withdrawApplication,
  listApplicantsForProfessor,
  updateApplicationStatus
};
