const { sql, poolPromise } = require("../config/db");

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

function nullableString(value) {
  if (value === undefined) {
    return undefined;
  }

  if (value === null) {
    return null;
  }

  if (typeof value !== "string") {
    throw httpError(400, "String value expected");
  }

  const trimmed = value.trim();
  return trimmed || null;
}

function requiredString(value, fieldName) {
  if (typeof value !== "string" || !value.trim()) {
    throw httpError(400, `${fieldName} is required`);
  }

  return value.trim();
}

function positiveInt(value, fieldName) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw httpError(400, `Valid ${fieldName} is required`);
  }

  return parsed;
}

function nullableNumber(value, fieldName) {
  if (value === undefined) {
    return undefined;
  }

  if (value === null || value === "") {
    return null;
  }

  const parsed = Number(value);

  if (Number.isNaN(parsed)) {
    throw httpError(400, `${fieldName} must be a number`);
  }

  return parsed;
}

function nullableDate(value, fieldName) {
  if (value === undefined) {
    return undefined;
  }

  if (value === null || value === "") {
    return null;
  }

  const parsed = new Date(value);

  if (Number.isNaN(parsed.getTime())) {
    throw httpError(400, `${fieldName} must be a valid date`);
  }

  return parsed;
}

function hasAnyDefined(fields) {
  return Object.values(fields).some(value => value !== undefined);
}

async function getProfileDetails(pool, userId) {
  const skillsResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT s.skill_id, s.skill_name
      FROM dbo.User_Skills us
      INNER JOIN dbo.Skills s
        ON s.skill_id = us.skill_id
      WHERE us.user_id = @user_id
      ORDER BY s.skill_name
    `);

  const languagesResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT l.language_id, l.language_name, ul.level
      FROM dbo.User_Languages ul
      INNER JOIN dbo.Languages l
        ON l.language_id = ul.language_id
      WHERE ul.user_id = @user_id
      ORDER BY l.language_name
    `);

  const experiencesResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT id, company_name, position, description, start_date, end_date
      FROM dbo.User_Experiences
      WHERE user_id = @user_id
      ORDER BY start_date DESC, id DESC
    `);

  const educationsResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT id, university, department, gpa, start_date, end_date
      FROM dbo.User_Educations
      WHERE user_id = @user_id
      ORDER BY start_date DESC, id DESC
    `);

  return {
    skills: skillsResult.recordset,
    languages: languagesResult.recordset,
    experiences: experiencesResult.recordset,
    educations: educationsResult.recordset
  };
}

async function getProfile(userId) {
  const pool = await poolPromise;

  const userResult = await pool.request()
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT
        user_id,
        role,
        email,
        is_verified,
        first_name,
        last_name,
        phone,
        university,
        faculty,
        department,
        created_at,
        updated_at
      FROM dbo.Users
      WHERE user_id = @user_id
    `);

  if (userResult.recordset.length === 0) {
    throw httpError(404, "User not found");
  }

  const user = userResult.recordset[0];
  let roleProfile = null;

  if (user.role === "student") {
    const studentResult = await pool.request()
      .input("user_id", sql.Int, userId)
      .query(`
        SELECT degree_level, class_year, gpa, expected_graduation_date
        FROM dbo.Student_Profile
        WHERE user_id = @user_id
      `);

    roleProfile = studentResult.recordset[0] || null;
  }

  if (user.role === "professor") {
    const professorResult = await pool.request()
      .input("user_id", sql.Int, userId)
      .query(`
        SELECT academic_title
        FROM dbo.Professor_Profile
        WHERE user_id = @user_id
      `);

    roleProfile = professorResult.recordset[0] || null;
  }

  return {
    user,
    profile: roleProfile,
    details: await getProfileDetails(pool, userId)
  };
}

async function updateProfile(userId, role, data) {
  const commonFields = {
    first_name: nullableString(data.first_name),
    last_name: nullableString(data.last_name),
    phone: nullableString(data.phone),
    university: nullableString(data.university),
    faculty: nullableString(data.faculty),
    department: nullableString(data.department)
  };

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    if (hasAnyDefined(commonFields)) {
      const currentResult = await transaction.request()
        .input("user_id", sql.Int, userId)
        .query(`
          SELECT first_name, last_name, phone, university, faculty, department
          FROM dbo.Users
          WHERE user_id = @user_id
        `);

      if (currentResult.recordset.length === 0) {
        throw httpError(404, "User not found");
      }

      const current = currentResult.recordset[0];

      await transaction.request()
        .input("user_id", sql.Int, userId)
        .input("first_name", sql.NVarChar(100), commonFields.first_name !== undefined ? commonFields.first_name : current.first_name)
        .input("last_name", sql.NVarChar(100), commonFields.last_name !== undefined ? commonFields.last_name : current.last_name)
        .input("phone", sql.NVarChar(20), commonFields.phone !== undefined ? commonFields.phone : current.phone)
        .input("university", sql.NVarChar(255), commonFields.university !== undefined ? commonFields.university : current.university)
        .input("faculty", sql.NVarChar(255), commonFields.faculty !== undefined ? commonFields.faculty : current.faculty)
        .input("department", sql.NVarChar(255), commonFields.department !== undefined ? commonFields.department : current.department)
        .query(`
          UPDATE dbo.Users
          SET first_name = @first_name,
              last_name = @last_name,
              phone = @phone,
              university = @university,
              faculty = @faculty,
              department = @department,
              updated_at = SYSDATETIME()
          WHERE user_id = @user_id
        `);
    }

    if (role === "student") {
      const studentFields = {
        degree_level: nullableString(data.degree_level),
        class_year: nullableNumber(data.class_year, "class_year"),
        gpa: nullableNumber(data.gpa, "gpa"),
        expected_graduation_date: nullableDate(data.expected_graduation_date, "expected_graduation_date")
      };

      if (hasAnyDefined(studentFields)) {
        const currentStudentResult = await transaction.request()
          .input("user_id", sql.Int, userId)
          .query(`
            SELECT degree_level, class_year, gpa, expected_graduation_date
            FROM dbo.Student_Profile
            WHERE user_id = @user_id
          `);

        const currentStudent = currentStudentResult.recordset[0] || {};

        await transaction.request()
          .input("user_id", sql.Int, userId)
          .input("degree_level", sql.NVarChar(50), studentFields.degree_level !== undefined ? studentFields.degree_level : currentStudent.degree_level ?? null)
          .input("class_year", sql.Int, studentFields.class_year !== undefined ? studentFields.class_year : currentStudent.class_year ?? null)
          .input("gpa", sql.Decimal(3, 2), studentFields.gpa !== undefined ? studentFields.gpa : currentStudent.gpa ?? null)
          .input("expected_graduation_date", sql.Date, studentFields.expected_graduation_date !== undefined ? studentFields.expected_graduation_date : currentStudent.expected_graduation_date ?? null)
          .query(`
            MERGE dbo.Student_Profile AS target
            USING (SELECT @user_id AS user_id) AS source
              ON target.user_id = source.user_id
            WHEN MATCHED THEN
              UPDATE SET
                degree_level = @degree_level,
                class_year = @class_year,
                gpa = @gpa,
                expected_graduation_date = @expected_graduation_date,
                updated_at = SYSDATETIME()
            WHEN NOT MATCHED THEN
              INSERT (user_id, degree_level, class_year, gpa, expected_graduation_date)
              VALUES (@user_id, @degree_level, @class_year, @gpa, @expected_graduation_date);
          `);
      }
    }

    if (role === "professor") {
      const academicTitle = nullableString(data.academic_title);

      if (academicTitle !== undefined) {
        await transaction.request()
          .input("user_id", sql.Int, userId)
          .input("academic_title", sql.NVarChar(100), academicTitle)
          .query(`
            MERGE dbo.Professor_Profile AS target
            USING (SELECT @user_id AS user_id) AS source
              ON target.user_id = source.user_id
            WHEN MATCHED THEN
              UPDATE SET
                academic_title = @academic_title,
                updated_at = SYSDATETIME()
            WHEN NOT MATCHED THEN
              INSERT (user_id, academic_title)
              VALUES (@user_id, @academic_title);
          `);
      }
    }

    await transaction.commit();
    transactionOpen = false;

    return await getProfile(userId);
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("UPDATE PROFILE ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function listSkills() {
  const pool = await poolPromise;
  const result = await pool.request().query(`
    SELECT skill_id, skill_name
    FROM dbo.Skills
    ORDER BY skill_name
  `);

  return { skills: result.recordset };
}

async function addSkill(userId, data) {
  const skillName = data.skill_name === undefined ? undefined : requiredString(data.skill_name, "skill_name");
  const skillId = data.skill_id === undefined ? undefined : positiveInt(data.skill_id, "skill_id");

  if (!skillName && !skillId) {
    throw httpError(400, "skill_id or skill_name is required");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    let resolvedSkillId = skillId;

    if (!resolvedSkillId) {
      const skillResult = await transaction.request()
        .input("skill_name", sql.NVarChar(100), skillName)
        .query(`
          IF NOT EXISTS (
            SELECT 1 FROM dbo.Skills WHERE skill_name = @skill_name
          )
          INSERT INTO dbo.Skills (skill_name)
          VALUES (@skill_name);

          SELECT skill_id
          FROM dbo.Skills
          WHERE skill_name = @skill_name;
        `);

      resolvedSkillId = skillResult.recordset[0].skill_id;
    }

    await transaction.request()
      .input("user_id", sql.Int, userId)
      .input("skill_id", sql.Int, resolvedSkillId)
      .query(`
        IF NOT EXISTS (
          SELECT 1 FROM dbo.User_Skills
          WHERE user_id = @user_id AND skill_id = @skill_id
        )
        INSERT INTO dbo.User_Skills (user_id, skill_id)
        VALUES (@user_id, @skill_id)
      `);

    await transaction.commit();
    transactionOpen = false;

    return await getProfile(userId);
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("ADD SKILL ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function removeSkill(userId, skillId) {
  const parsedSkillId = positiveInt(skillId, "skill_id");
  const pool = await poolPromise;

  const result = await pool.request()
    .input("user_id", sql.Int, userId)
    .input("skill_id", sql.Int, parsedSkillId)
    .query(`
      DELETE FROM dbo.User_Skills
      OUTPUT DELETED.skill_id
      WHERE user_id = @user_id
        AND skill_id = @skill_id
    `);

  if (result.recordset.length === 0) {
    throw httpError(404, "Skill not found on profile");
  }

  return await getProfile(userId);
}

async function listLanguages() {
  const pool = await poolPromise;
  const result = await pool.request().query(`
    SELECT language_id, language_name
    FROM dbo.Languages
    ORDER BY language_name
  `);

  return { languages: result.recordset };
}

function normalizeLanguageLevel(level) {
  const normalizedLevel = requiredString(level, "level").toUpperCase();

  if (!["BEGINNER", "INTERMEDIATE", "ADVANCED", "NATIVE"].includes(normalizedLevel)) {
    throw httpError(400, "level must be BEGINNER, INTERMEDIATE, ADVANCED, or NATIVE");
  }

  return normalizedLevel;
}

async function addOrUpdateLanguage(userId, data) {
  const languageName = data.language_name === undefined ? undefined : requiredString(data.language_name, "language_name");
  const languageId = data.language_id === undefined ? undefined : positiveInt(data.language_id, "language_id");
  const level = normalizeLanguageLevel(data.level);

  if (!languageName && !languageId) {
    throw httpError(400, "language_id or language_name is required");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    let resolvedLanguageId = languageId;

    if (!resolvedLanguageId) {
      const languageResult = await transaction.request()
        .input("language_name", sql.NVarChar(100), languageName)
        .query(`
          IF NOT EXISTS (
            SELECT 1 FROM dbo.Languages WHERE language_name = @language_name
          )
          INSERT INTO dbo.Languages (language_name)
          VALUES (@language_name);

          SELECT language_id
          FROM dbo.Languages
          WHERE language_name = @language_name;
        `);

      resolvedLanguageId = languageResult.recordset[0].language_id;
    }

    await transaction.request()
      .input("user_id", sql.Int, userId)
      .input("language_id", sql.Int, resolvedLanguageId)
      .input("level", sql.NVarChar(50), level)
      .query(`
        MERGE dbo.User_Languages AS target
        USING (SELECT @user_id AS user_id, @language_id AS language_id) AS source
          ON target.user_id = source.user_id
          AND target.language_id = source.language_id
        WHEN MATCHED THEN
          UPDATE SET level = @level
        WHEN NOT MATCHED THEN
          INSERT (user_id, language_id, level)
          VALUES (@user_id, @language_id, @level);
      `);

    await transaction.commit();
    transactionOpen = false;

    return await getProfile(userId);
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("ADD LANGUAGE ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function removeLanguage(userId, languageId) {
  const parsedLanguageId = positiveInt(languageId, "language_id");
  const pool = await poolPromise;

  const result = await pool.request()
    .input("user_id", sql.Int, userId)
    .input("language_id", sql.Int, parsedLanguageId)
    .query(`
      DELETE FROM dbo.User_Languages
      OUTPUT DELETED.language_id
      WHERE user_id = @user_id
        AND language_id = @language_id
    `);

  if (result.recordset.length === 0) {
    throw httpError(404, "Language not found on profile");
  }

  return await getProfile(userId);
}

async function createExperience(userId, data) {
  const companyName = nullableString(data.company_name);
  const position = nullableString(data.position);
  const description = nullableString(data.description);
  const startDate = nullableDate(data.start_date, "start_date");
  const endDate = nullableDate(data.end_date, "end_date");

  if (!companyName && !position) {
    throw httpError(400, "company_name or position is required");
  }

  const pool = await poolPromise;
  const result = await pool.request()
    .input("user_id", sql.Int, userId)
    .input("company_name", sql.NVarChar(255), companyName ?? null)
    .input("position", sql.NVarChar(255), position ?? null)
    .input("description", sql.NVarChar(sql.MAX), description ?? null)
    .input("start_date", sql.Date, startDate ?? null)
    .input("end_date", sql.Date, endDate ?? null)
    .query(`
      INSERT INTO dbo.User_Experiences
        (user_id, company_name, position, description, start_date, end_date)
      OUTPUT INSERTED.id, INSERTED.company_name, INSERTED.position, INSERTED.description, INSERTED.start_date, INSERTED.end_date
      VALUES
        (@user_id, @company_name, @position, @description, @start_date, @end_date)
    `);

  return {
    message: "Experience added successfully",
    experience: result.recordset[0]
  };
}

async function updateExperience(userId, experienceId, data) {
  const parsedExperienceId = positiveInt(experienceId, "experience_id");
  const fields = {
    company_name: nullableString(data.company_name),
    position: nullableString(data.position),
    description: nullableString(data.description),
    start_date: nullableDate(data.start_date, "start_date"),
    end_date: nullableDate(data.end_date, "end_date")
  };

  if (!hasAnyDefined(fields)) {
    throw httpError(400, "At least one experience field is required");
  }

  const pool = await poolPromise;

  const currentResult = await pool.request()
    .input("id", sql.Int, parsedExperienceId)
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT company_name, position, description, start_date, end_date
      FROM dbo.User_Experiences
      WHERE id = @id AND user_id = @user_id
    `);

  if (currentResult.recordset.length === 0) {
    throw httpError(404, "Experience not found");
  }

  const current = currentResult.recordset[0];

  const result = await pool.request()
    .input("id", sql.Int, parsedExperienceId)
    .input("user_id", sql.Int, userId)
    .input("company_name", sql.NVarChar(255), fields.company_name !== undefined ? fields.company_name : current.company_name)
    .input("position", sql.NVarChar(255), fields.position !== undefined ? fields.position : current.position)
    .input("description", sql.NVarChar(sql.MAX), fields.description !== undefined ? fields.description : current.description)
    .input("start_date", sql.Date, fields.start_date !== undefined ? fields.start_date : current.start_date)
    .input("end_date", sql.Date, fields.end_date !== undefined ? fields.end_date : current.end_date)
    .query(`
      UPDATE dbo.User_Experiences
      SET company_name = @company_name,
          position = @position,
          description = @description,
          start_date = @start_date,
          end_date = @end_date
      OUTPUT INSERTED.id, INSERTED.company_name, INSERTED.position, INSERTED.description, INSERTED.start_date, INSERTED.end_date
      WHERE id = @id AND user_id = @user_id
    `);

  return {
    message: "Experience updated successfully",
    experience: result.recordset[0]
  };
}

async function deleteExperience(userId, experienceId) {
  const parsedExperienceId = positiveInt(experienceId, "experience_id");
  const pool = await poolPromise;

  const result = await pool.request()
    .input("id", sql.Int, parsedExperienceId)
    .input("user_id", sql.Int, userId)
    .query(`
      DELETE FROM dbo.User_Experiences
      OUTPUT DELETED.id
      WHERE id = @id AND user_id = @user_id
    `);

  if (result.recordset.length === 0) {
    throw httpError(404, "Experience not found");
  }

  return {
    message: "Experience deleted successfully"
  };
}

async function createEducation(userId, data) {
  const university = nullableString(data.university);
  const department = nullableString(data.department);
  const gpa = nullableNumber(data.gpa, "gpa");
  const startDate = nullableDate(data.start_date, "start_date");
  const endDate = nullableDate(data.end_date, "end_date");

  if (!university && !department) {
    throw httpError(400, "university or department is required");
  }

  const pool = await poolPromise;
  const result = await pool.request()
    .input("user_id", sql.Int, userId)
    .input("university", sql.NVarChar(255), university ?? null)
    .input("department", sql.NVarChar(255), department ?? null)
    .input("gpa", sql.Decimal(3, 2), gpa ?? null)
    .input("start_date", sql.Date, startDate ?? null)
    .input("end_date", sql.Date, endDate ?? null)
    .query(`
      INSERT INTO dbo.User_Educations
        (user_id, university, department, gpa, start_date, end_date)
      OUTPUT INSERTED.id, INSERTED.university, INSERTED.department, INSERTED.gpa, INSERTED.start_date, INSERTED.end_date
      VALUES
        (@user_id, @university, @department, @gpa, @start_date, @end_date)
    `);

  return {
    message: "Education added successfully",
    education: result.recordset[0]
  };
}

async function updateEducation(userId, educationId, data) {
  const parsedEducationId = positiveInt(educationId, "education_id");
  const fields = {
    university: nullableString(data.university),
    department: nullableString(data.department),
    gpa: nullableNumber(data.gpa, "gpa"),
    start_date: nullableDate(data.start_date, "start_date"),
    end_date: nullableDate(data.end_date, "end_date")
  };

  if (!hasAnyDefined(fields)) {
    throw httpError(400, "At least one education field is required");
  }

  const pool = await poolPromise;

  const currentResult = await pool.request()
    .input("id", sql.Int, parsedEducationId)
    .input("user_id", sql.Int, userId)
    .query(`
      SELECT university, department, gpa, start_date, end_date
      FROM dbo.User_Educations
      WHERE id = @id AND user_id = @user_id
    `);

  if (currentResult.recordset.length === 0) {
    throw httpError(404, "Education not found");
  }

  const current = currentResult.recordset[0];

  const result = await pool.request()
    .input("id", sql.Int, parsedEducationId)
    .input("user_id", sql.Int, userId)
    .input("university", sql.NVarChar(255), fields.university !== undefined ? fields.university : current.university)
    .input("department", sql.NVarChar(255), fields.department !== undefined ? fields.department : current.department)
    .input("gpa", sql.Decimal(3, 2), fields.gpa !== undefined ? fields.gpa : current.gpa)
    .input("start_date", sql.Date, fields.start_date !== undefined ? fields.start_date : current.start_date)
    .input("end_date", sql.Date, fields.end_date !== undefined ? fields.end_date : current.end_date)
    .query(`
      UPDATE dbo.User_Educations
      SET university = @university,
          department = @department,
          gpa = @gpa,
          start_date = @start_date,
          end_date = @end_date
      OUTPUT INSERTED.id, INSERTED.university, INSERTED.department, INSERTED.gpa, INSERTED.start_date, INSERTED.end_date
      WHERE id = @id AND user_id = @user_id
    `);

  return {
    message: "Education updated successfully",
    education: result.recordset[0]
  };
}

async function deleteEducation(userId, educationId) {
  const parsedEducationId = positiveInt(educationId, "education_id");
  const pool = await poolPromise;

  const result = await pool.request()
    .input("id", sql.Int, parsedEducationId)
    .input("user_id", sql.Int, userId)
    .query(`
      DELETE FROM dbo.User_Educations
      OUTPUT DELETED.id
      WHERE id = @id AND user_id = @user_id
    `);

  if (result.recordset.length === 0) {
    throw httpError(404, "Education not found");
  }

  return {
    message: "Education deleted successfully"
  };
}

module.exports = {
  getProfile,
  updateProfile,
  listSkills,
  addSkill,
  removeSkill,
  listLanguages,
  addOrUpdateLanguage,
  removeLanguage,
  createExperience,
  updateExperience,
  deleteExperience,
  createEducation,
  updateEducation,
  deleteEducation
};
