const {
  listApplicationsForStudent,
  withdrawApplication,
  updateApplicationStatus
} = require("../services/jobService");

async function listMine(req, res) {
  try {
    const result = await listApplicationsForStudent(req.user.user_id);

    return res.status(200).json(result);
  } catch (err) {
    console.error("LIST STUDENT APPLICATIONS ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "List student applications failed"
    });
  }
}

async function updateStatus(req, res) {
  try {
    const result = await updateApplicationStatus(
      req.user.user_id,
      req.params.applicationId,
      req.body.status
    );

    return res.status(200).json(result);
  } catch (err) {
    console.error("UPDATE APPLICATION STATUS ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Update application status failed"
    });
  }
}

async function withdraw(req, res) {
  try {
    const result = await withdrawApplication(req.user.user_id, req.params.applicationId);

    return res.status(200).json(result);
  } catch (err) {
    console.error("WITHDRAW APPLICATION ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Withdraw application failed"
    });
  }
}

module.exports = {
  listMine,
  withdraw,
  updateStatus
};
