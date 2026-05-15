const express = require("express");

const {
  create,
  listActive,
  listMine,
  show,
  update,
  close,
  apply,
  listApplicants
} = require("../controllers/jobController");
const {
  authenticate,
  requireRole
} = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/active", authenticate, requireRole("student"), listActive);
router.get("/my", authenticate, requireRole("professor"), listMine);
router.get("/:jobId/applicants", authenticate, requireRole("professor"), listApplicants);
router.get("/:jobId", authenticate, show);
router.put("/:jobId", authenticate, requireRole("professor"), update);
router.patch("/:jobId/close", authenticate, requireRole("professor"), close);
router.post("/:jobId/apply", authenticate, requireRole("student"), apply);
router.post("/", authenticate, requireRole("professor"), create);

module.exports = router;
