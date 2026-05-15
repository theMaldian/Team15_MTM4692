const {
  createJob,
  listActiveJobsForStudent,
  listJobsForProfessor,
  getJobById,
  updateJob,
  closeJob,
  applyToJob,
  listApplicantsForProfessor
} = require("../services/jobService");

async function create(req, res) {
  try {
    const result = await createJob(req.user.user_id, req.body);

    return res.status(201).json(result);
  } catch (err) {
    console.error("CREATE JOB ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Create job failed"
    });
  }
}

async function listActive(req, res) {
  try {
    const result = await listActiveJobsForStudent(req.user.user_id);

    return res.status(200).json(result);
  } catch (err) {
    console.error("LIST ACTIVE JOBS ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "List active jobs failed"
    });
  }
}

async function listMine(req, res) {
  try {
    const result = await listJobsForProfessor(req.user.user_id);

    return res.status(200).json(result);
  } catch (err) {
    console.error("LIST PROFESSOR JOBS ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "List professor jobs failed"
    });
  }
}

async function show(req, res) {
  try {
    const result = await getJobById(req.user.user_id, req.user.role, req.params.jobId);

    return res.status(200).json(result);
  } catch (err) {
    console.error("GET JOB ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Get job failed"
    });
  }
}

async function update(req, res) {
  try {
    const result = await updateJob(req.user.user_id, req.params.jobId, req.body);

    return res.status(200).json(result);
  } catch (err) {
    console.error("UPDATE JOB ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Update job failed"
    });
  }
}

async function close(req, res) {
  try {
    const result = await closeJob(req.user.user_id, req.params.jobId);

    return res.status(200).json(result);
  } catch (err) {
    console.error("CLOSE JOB ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Close job failed"
    });
  }
}

async function apply(req, res) {
  try {
    const result = await applyToJob(req.user.user_id, req.params.jobId);

    return res.status(201).json(result);
  } catch (err) {
    console.error("APPLY TO JOB ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Apply to job failed"
    });
  }
}

async function listApplicants(req, res) {
  try {
    const result = await listApplicantsForProfessor(req.user.user_id, req.params.jobId);

    return res.status(200).json(result);
  } catch (err) {
    console.error("LIST JOB APPLICANTS ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "List job applicants failed"
    });
  }
}

module.exports = {
  create,
  listActive,
  listMine,
  show,
  update,
  close,
  apply,
  listApplicants
};
