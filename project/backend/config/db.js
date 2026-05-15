require("dotenv").config();
const sql = require("mssql");

function requiredEnv(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

function envBoolean(name, defaultValue) {
  const value = process.env[name];

  if (value === undefined) {
    return defaultValue;
  }

  return value.toLowerCase() === "true";
}

const dbPort = Number(process.env.DB_PORT || 1433);

if (!Number.isInteger(dbPort)) {
  throw new Error("DB_PORT must be a valid integer");
}

const config = {
  user: requiredEnv("DB_USER"),
  password: requiredEnv("DB_PASSWORD"),
  server: requiredEnv("DB_SERVER"),
  database: requiredEnv("DB_DATABASE"),
  port: dbPort,
  options: {
    encrypt: envBoolean("DB_ENCRYPT", true),
    trustServerCertificate: envBoolean("DB_TRUST_CERT", false)
  }
};

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    console.log("DB connected");
    return pool;
  })
  .catch(err => {
    console.error("DB connection failed:", err);
    throw err;
  });

module.exports = { sql, poolPromise };
