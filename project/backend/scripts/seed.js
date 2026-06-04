/*
 * Demo seed script — OPTIONAL, run manually with `npm run seed`.
 *
 * Inserts a small set of demo professors, students, jobs and applications so
 * the app looks populated in a demo. It is IDEMPOTENT: rows are only inserted
 * if they don't already exist (matched by a natural key), so it is safe to run
 * repeatedly.
 *
 * It reuses the app's own DB config (config/db.js) and bcrypt hashing, so the
 * seeded users can actually log in. Demo credentials are documented in
 * scripts/SEED_CREDENTIALS.md.
 *
 * This script does NOT modify any existing backend behavior.
 */
const bcrypt = require("bcrypt");
const { sql, poolPromise } = require("../config/db");

const DEMO_PASSWORD = "DemoPass1";

const PROFESSORS = [
  { email: "prof.demo1@yildiz.edu.tr", firstName: "Ayşe", lastName: "Kaya" },
  { email: "prof.demo2@yildiz.edu.tr", firstName: "Mehmet", lastName: "Demir" },
];

const STUDENTS = [
  { email: "student.demo1@std.yildiz.edu.tr", firstName: "Zeynep", lastName: "Yıldız" },
  { email: "student.demo2@std.yildiz.edu.tr", firstName: "Can", lastName: "Öztürk" },
  { email: "student.demo3@std.yildiz.edu.tr", firstName: "Elif", lastName: "Şahin" },
];

// Jobs are assigned to professors by index (0 or 1).
const JOBS = [
  { prof: 0, category: "Research Assistant", dept: "Bilgisayar Mühendisliği", position: "Yapay Zeka Araştırma Asistanı", deadlineInDays: 30, description: "Derin öğrenme projelerinde veri hazırlama ve model eğitimi konularında destek." },
  { prof: 0, category: "Lab Assistant", dept: "Bilgisayar Mühendisliği", position: "Veritabanı Laboratuvarı Asistanı", deadlineInDays: 21, description: "Lisans veritabanı laboratuvarında öğrencilere SQL ve tasarım desteği." },
  { prof: 0, category: "Course Assistant", dept: "Elektronik ve Haberleşme Mühendisliği", position: "Sinyaller ve Sistemler Ders Asistanı", deadlineInDays: 45, description: "Haftalık problem oturumları ve ödev değerlendirme." },
  { prof: 1, category: "Research Assistant", dept: "Makine Mühendisliği", position: "Termodinamik Araştırma Asistanı", deadlineInDays: 60, description: "Isı transferi deneyleri ve rapor hazırlığı." },
  { prof: 1, category: "Lab Assistant", dept: "Makine Mühendisliği", position: "Malzeme Laboratuvarı Asistanı", deadlineInDays: 14, description: "Çekme ve sertlik testlerinde laboratuvar desteği." },
  { prof: 1, category: "Course Assistant", dept: "Endüstri Mühendisliği", position: "Olasılık ve İstatistik Ders Asistanı", deadlineInDays: 38, description: "Ders saatleri ve sınav gözetmenliği." },
  { prof: 0, category: "Research Assistant", dept: "Bilgisayar Mühendisliği", position: "Mobil Uygulama Araştırma Asistanı", deadlineInDays: 52, description: "Flutter tabanlı prototiplerin geliştirilmesi ve test edilmesi." },
];

// (jobIndex, studentIndex, status)
const APPLICATIONS = [
  { job: 0, student: 0, status: "approved" },
  { job: 0, student: 1, status: "pending" },
  { job: 1, student: 0, status: "pending" },
  { job: 2, student: 2, status: "rejected" },
  { job: 3, student: 1, status: "approved" },
  { job: 6, student: 2, status: "pending" },
  { job: 6, student: 0, status: "pending" },
];

function isoDateInDays(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10); // YYYY-MM-DD
}

async function getOrCreateUser(pool, { email, role, firstName, lastName }) {
  const existing = await pool
    .request()
    .input("email", sql.NVarChar, email)
    .query("SELECT user_id FROM dbo.Users WHERE email = @email");
  if (existing.recordset.length > 0) {
    return { id: existing.recordset[0].user_id, created: false };
  }
  const hash = await bcrypt.hash(DEMO_PASSWORD, 10);
  const res = await pool
    .request()
    .input("email", sql.NVarChar, email)
    .input("password_hash", sql.NVarChar, hash)
    .input("role", sql.NVarChar, role)
    .input("first_name", sql.NVarChar, firstName)
    .input("last_name", sql.NVarChar, lastName)
    .query(`
      INSERT INTO dbo.Users
        (email, password_hash, role, first_name, last_name, is_verified)
      OUTPUT INSERTED.user_id
      VALUES
        (@email, @password_hash, @role, @first_name, @last_name, 1)
    `);
  return { id: res.recordset[0].user_id, created: true };
}

async function getOrCreateJob(pool, userId, job) {
  const existing = await pool
    .request()
    .input("user_id", sql.Int, userId)
    .input("position", sql.NVarChar, job.position)
    .query(
      "SELECT job_id FROM dbo.Jobs WHERE user_id = @user_id AND position = @position"
    );
  if (existing.recordset.length > 0) {
    return { id: existing.recordset[0].job_id, created: false };
  }
  const res = await pool
    .request()
    .input("user_id", sql.Int, userId)
    .input("job_category", sql.NVarChar, job.category)
    .input("department_name", sql.NVarChar, job.dept)
    .input("position", sql.NVarChar, job.position)
    .input("description", sql.NVarChar, job.description)
    .input("deadline", sql.Date, isoDateInDays(job.deadlineInDays))
    .query(`
      INSERT INTO dbo.Jobs
        (user_id, job_category, department_name, position, description, deadline)
      OUTPUT INSERTED.job_id
      VALUES
        (@user_id, @job_category, @department_name, @position, @description, @deadline)
    `);
  return { id: res.recordset[0].job_id, created: true };
}

async function getOrCreateApplication(pool, jobId, userId, status) {
  // NOTE: the Job_Applicants primary key column is `id`; the backend only
  // aliases it as `application_id` in its SELECT queries.
  const existing = await pool
    .request()
    .input("job_id", sql.Int, jobId)
    .input("user_id", sql.Int, userId)
    .query(
      "SELECT id FROM dbo.Job_Applicants WHERE job_id = @job_id AND user_id = @user_id"
    );
  let appId;
  let created = false;
  if (existing.recordset.length > 0) {
    appId = existing.recordset[0].id;
  } else {
    const res = await pool
      .request()
      .input("job_id", sql.Int, jobId)
      .input("user_id", sql.Int, userId)
      .query(`
        INSERT INTO dbo.Job_Applicants (job_id, user_id)
        OUTPUT INSERTED.id
        VALUES (@job_id, @user_id)
      `);
    appId = res.recordset[0].id;
    created = true;
  }
  if (status && status !== "pending") {
    await pool
      .request()
      .input("id", sql.Int, appId)
      .input("status", sql.NVarChar, status)
      .query(
        "UPDATE dbo.Job_Applicants SET status = @status WHERE id = @id"
      );
  }
  return { id: appId, created };
}

async function main() {
  const pool = await poolPromise;
  if (!pool) {
    throw new Error(
      "No DB connection (check .env / Azure SQL firewall before seeding)."
    );
  }

  console.log("Seeding demo data...");

  const profIds = [];
  for (const p of PROFESSORS) {
    const r = await getOrCreateUser(pool, { ...p, role: "professor" });
    profIds.push(r.id);
    console.log(`  professor ${p.email}: ${r.created ? "created" : "exists"} (id ${r.id})`);
  }

  const studentIds = [];
  for (const s of STUDENTS) {
    const r = await getOrCreateUser(pool, { ...s, role: "student" });
    studentIds.push(r.id);
    console.log(`  student ${s.email}: ${r.created ? "created" : "exists"} (id ${r.id})`);
  }

  const jobIds = [];
  for (const j of JOBS) {
    const r = await getOrCreateJob(pool, profIds[j.prof], j);
    jobIds.push(r.id);
    console.log(`  job "${j.position}": ${r.created ? "created" : "exists"} (id ${r.id})`);
  }

  for (const a of APPLICATIONS) {
    const r = await getOrCreateApplication(
      pool,
      jobIds[a.job],
      studentIds[a.student],
      a.status
    );
    console.log(
      `  application job#${jobIds[a.job]} <- student#${studentIds[a.student]} [${a.status}]: ${r.created ? "created" : "exists"}`
    );
  }

  console.log("\nDone. Demo password for every seeded user: " + DEMO_PASSWORD);
  console.log("See scripts/SEED_CREDENTIALS.md for the full list.");
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Seed failed:", err.message || err);
    process.exit(1);
  });
