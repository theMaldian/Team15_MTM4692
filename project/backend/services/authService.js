const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const { sql, poolPromise } = require("../config/db");

const {
  sendVerificationMail,
  sendPasswordResetMail
} = require("./mailService");

const {
  getRoleFromEmail,
  generateVerificationCode
} = require("../utils/authUtils");

function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

function requiredEnv(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

function createAuthToken(user) {
  return jwt.sign(
    {
      user_id: user.user_id,
      role: user.role,
      email: user.email
    },
    requiredEnv("JWT_SECRET"),
    { expiresIn: process.env.JWT_EXPIRES_IN || "1d" }
  );
}

async function ensurePasswordResetTable(pool) {
  await pool.request().query(`
    IF OBJECT_ID('dbo.Password_Reset', 'U') IS NULL
    BEGIN
      CREATE TABLE dbo.Password_Reset (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        reset_token NVARCHAR(255) NOT NULL,
        expires_at DATETIME2 NOT NULL,
        used_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT FK_PasswordReset_Users
          FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
      );

      CREATE INDEX IX_PasswordReset_UserId
      ON dbo.Password_Reset(user_id);
    END
  `);
}

async function registerUser(data) {

  const {
    email,
    password,
    first_name,
    last_name
  } = data;

  if (typeof email !== "string" || typeof password !== "string") {
    throw httpError(400, "Email and password are required");
  }

  const normalizedEmail = email.toLowerCase().trim();

  if (!normalizedEmail || !password) {
    throw httpError(400, "Email and password are required");
  }

  const role = getRoleFromEmail(normalizedEmail);

  if (!role) {
    throw httpError(400, "Invalid email domain");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    const existingUser = await transaction.request()
      .input("email", normalizedEmail)
      .query(`
        SELECT user_id
        FROM dbo.Users
        WHERE email = @email
      `);

    if (existingUser.recordset.length > 0) {
      throw httpError(409, "Email already registered");
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const userResult = await transaction.request()
      .input("email", normalizedEmail)
      .input("password", hashedPassword)
      .input("role", role)
      .input("first_name", first_name || null)
      .input("last_name", last_name || null)
      .query(`
        INSERT INTO dbo.Users
          (email, password_hash, role, first_name, last_name)

        OUTPUT INSERTED.user_id

        VALUES
          (@email, @password, @role, @first_name, @last_name)
      `);

    const userId = userResult.recordset[0].user_id;
    const code = generateVerificationCode();

    await transaction.request()
      .input("user_id", userId)
      .input("code", code)
      .input("expires", new Date(Date.now() + 1000 * 60 * 10))
      .query(`
        INSERT INTO dbo.Email_Verification
          (user_id, verification_token, expires_at)

        VALUES
          (@user_id, @code, @expires)
      `);

    await sendVerificationMail(normalizedEmail, code);
    await transaction.commit();
    transactionOpen = false;

    return {
      message: "User registered. Verification code sent.",
      role
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("REGISTER ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }

}

async function verifyEmail(data) {
  const { email, code } = data;

  if (typeof email !== "string" || typeof code !== "string") {
    throw httpError(400, "Email and verification code are required");
  }

  const normalizedEmail = email.toLowerCase().trim();
  const normalizedCode = code.trim();

  if (!normalizedEmail || !normalizedCode) {
    throw httpError(400, "Email and verification code are required");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    const userResult = await transaction.request()
      .input("email", normalizedEmail)
      .query(`
        SELECT user_id, email, role, is_verified
        FROM dbo.Users
        WHERE email = @email
      `);

    if (userResult.recordset.length === 0) {
      throw httpError(404, "User not found");
    }

    const user = userResult.recordset[0];

    if (user.is_verified) {
      await transaction.commit();
      transactionOpen = false;

      return {
        message: "Email already verified"
      };
    }

    const verificationResult = await transaction.request()
      .input("user_id", user.user_id)
      .input("code", normalizedCode)
      .query(`
        SELECT TOP 1 id, expires_at
        FROM dbo.Email_Verification
        WHERE user_id = @user_id
          AND verification_token = @code
          AND verified_at IS NULL
        ORDER BY created_at DESC
      `);

    if (verificationResult.recordset.length === 0) {
      throw httpError(400, "Invalid verification code");
    }

    const verification = verificationResult.recordset[0];

    if (new Date(verification.expires_at).getTime() < Date.now()) {
      throw httpError(400, "Verification code expired");
    }

    await transaction.request()
      .input("user_id", user.user_id)
      .query(`
        UPDATE dbo.Users
        SET is_verified = 1,
            updated_at = SYSDATETIME()
        WHERE user_id = @user_id
      `);

    await transaction.request()
      .input("verification_id", verification.id)
      .query(`
        UPDATE dbo.Email_Verification
        SET verified_at = SYSDATETIME(),
            updated_at = SYSDATETIME()
        WHERE id = @verification_id
      `);

    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Email verified successfully"
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("VERIFY EMAIL ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function resendVerificationEmail(data) {
  const { email } = data;

  if (typeof email !== "string") {
    throw httpError(400, "Email is required");
  }

  const normalizedEmail = email.toLowerCase().trim();

  if (!normalizedEmail) {
    throw httpError(400, "Email is required");
  }

  const pool = await poolPromise;
  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    const userResult = await transaction.request()
      .input("email", normalizedEmail)
      .query(`
        SELECT user_id, is_verified
        FROM dbo.Users
        WHERE email = @email
      `);

    if (userResult.recordset.length === 0) {
      throw httpError(404, "User not found");
    }

    const user = userResult.recordset[0];

    if (user.is_verified) {
      throw httpError(400, "Email is already verified");
    }

    const code = generateVerificationCode();

    await transaction.request()
      .input("user_id", user.user_id)
      .input("code", code)
      .input("expires", new Date(Date.now() + 1000 * 60 * 10))
      .query(`
        INSERT INTO dbo.Email_Verification
          (user_id, verification_token, expires_at)

        VALUES
          (@user_id, @code, @expires)
      `);

    await sendVerificationMail(normalizedEmail, code);
    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Verification code sent"
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("RESEND VERIFICATION ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function loginUser(data) {
  const { email, password } = data;

  if (typeof email !== "string" || typeof password !== "string") {
    throw httpError(400, "Email and password are required");
  }

  const normalizedEmail = email.toLowerCase().trim();

  if (!normalizedEmail || !password) {
    throw httpError(400, "Email and password are required");
  }

  const pool = await poolPromise;

  const userResult = await pool.request()
    .input("email", normalizedEmail)
    .query(`
      SELECT user_id, role, email, password_hash, is_verified, first_name, last_name
      FROM dbo.Users
      WHERE email = @email
    `);

  if (userResult.recordset.length === 0) {
    throw httpError(401, "Invalid email or password");
  }

  const user = userResult.recordset[0];
  const passwordMatches = await bcrypt.compare(password, user.password_hash);

  if (!passwordMatches) {
    throw httpError(401, "Invalid email or password");
  }

  if (!user.is_verified) {
    throw httpError(403, "Please verify your email before logging in");
  }

  const token = createAuthToken(user);

  return {
    message: "Login successful",
    token,
    user: {
      user_id: user.user_id,
      role: user.role,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name
    }
  };
}

async function logoutUser() {
  return {
    message: "Logout successful. Please discard the token on the client."
  };
}

async function forgotPassword(data) {
  const { email } = data;

  if (typeof email !== "string" || !email.trim()) {
    throw httpError(400, "Email is required");
  }

  const normalizedEmail = email.toLowerCase().trim();
  const pool = await poolPromise;
  await ensurePasswordResetTable(pool);

  const userResult = await pool.request()
    .input("email", normalizedEmail)
    .query(`
      SELECT user_id, email
      FROM dbo.Users
      WHERE email = @email
    `);

  if (userResult.recordset.length === 0) {
    return {
      message: "If this email exists, a password reset code was sent."
    };
  }

  const user = userResult.recordset[0];
  const code = generateVerificationCode();

  await pool.request()
    .input("user_id", user.user_id)
    .input("code", code)
    .input("expires", new Date(Date.now() + 1000 * 60 * 10))
    .query(`
      INSERT INTO dbo.Password_Reset
        (user_id, reset_token, expires_at)
      VALUES
        (@user_id, @code, @expires)
    `);

  await sendPasswordResetMail(user.email, code);

  return {
    message: "If this email exists, a password reset code was sent."
  };
}

async function resetPassword(data) {
  const { email, code, new_password } = data;

  if (
    typeof email !== "string" ||
    typeof code !== "string" ||
    typeof new_password !== "string"
  ) {
    throw httpError(400, "Email, code, and new_password are required");
  }

  const normalizedEmail = email.toLowerCase().trim();
  const normalizedCode = code.trim();

  if (!normalizedEmail || !normalizedCode || !new_password) {
    throw httpError(400, "Email, code, and new_password are required");
  }

  const pool = await poolPromise;
  await ensurePasswordResetTable(pool);

  const transaction = new sql.Transaction(pool);
  let transactionOpen = false;

  await transaction.begin();
  transactionOpen = true;

  try {
    const userResult = await transaction.request()
      .input("email", normalizedEmail)
      .query(`
        SELECT user_id
        FROM dbo.Users
        WHERE email = @email
      `);

    if (userResult.recordset.length === 0) {
      throw httpError(400, "Invalid or expired reset code");
    }

    const user = userResult.recordset[0];

    const resetResult = await transaction.request()
      .input("user_id", user.user_id)
      .input("code", normalizedCode)
      .query(`
        SELECT TOP 1 id, expires_at
        FROM dbo.Password_Reset
        WHERE user_id = @user_id
          AND reset_token = @code
          AND used_at IS NULL
        ORDER BY created_at DESC
      `);

    if (resetResult.recordset.length === 0) {
      throw httpError(400, "Invalid or expired reset code");
    }

    const reset = resetResult.recordset[0];

    if (new Date(reset.expires_at).getTime() < Date.now()) {
      throw httpError(400, "Invalid or expired reset code");
    }

    const hashedPassword = await bcrypt.hash(new_password, 10);

    await transaction.request()
      .input("user_id", user.user_id)
      .input("password", hashedPassword)
      .query(`
        UPDATE dbo.Users
        SET password_hash = @password,
            updated_at = SYSDATETIME()
        WHERE user_id = @user_id
      `);

    await transaction.request()
      .input("reset_id", reset.id)
      .query(`
        UPDATE dbo.Password_Reset
        SET used_at = SYSDATETIME()
        WHERE id = @reset_id
      `);

    await transaction.commit();
    transactionOpen = false;

    return {
      message: "Password reset successfully"
    };
  } catch (err) {
    if (transactionOpen) {
      try {
        await transaction.rollback();
      } catch (rollbackErr) {
        console.error("RESET PASSWORD ROLLBACK ERROR:", rollbackErr);
      }
    }

    throw err;
  }
}

async function changePassword(userId, data) {
  const { current_password, new_password } = data;

  if (typeof current_password !== "string" || typeof new_password !== "string") {
    throw httpError(400, "current_password and new_password are required");
  }

  if (!current_password || !new_password) {
    throw httpError(400, "current_password and new_password are required");
  }

  const pool = await poolPromise;

  const userResult = await pool.request()
    .input("user_id", userId)
    .query(`
      SELECT user_id, password_hash
      FROM dbo.Users
      WHERE user_id = @user_id
    `);

  if (userResult.recordset.length === 0) {
    throw httpError(404, "User not found");
  }

  const user = userResult.recordset[0];
  const passwordMatches = await bcrypt.compare(current_password, user.password_hash);

  if (!passwordMatches) {
    throw httpError(401, "Current password is incorrect");
  }

  const hashedPassword = await bcrypt.hash(new_password, 10);

  await pool.request()
    .input("user_id", user.user_id)
    .input("password", hashedPassword)
    .query(`
      UPDATE dbo.Users
      SET password_hash = @password,
          updated_at = SYSDATETIME()
      WHERE user_id = @user_id
    `);

  return {
    message: "Password changed successfully"
  };
}

module.exports = {
  registerUser,
  verifyEmail,
  resendVerificationEmail,
  loginUser,
  logoutUser,
  forgotPassword,
  resetPassword,
  changePassword
};
