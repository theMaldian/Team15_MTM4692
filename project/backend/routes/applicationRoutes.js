const express = require("express");

const {
  listMine,
  withdraw,
  updateStatus
} = require("../controllers/applicationController");
const {
  authenticate,
  requireRole
} = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/my", authenticate, requireRole("student"), listMine);
router.delete("/:applicationId", authenticate, requireRole("student"), withdraw);
router.patch("/:applicationId/status", authenticate, requireRole("professor"), updateStatus);

module.exports = router;
