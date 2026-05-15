const express = require("express");

const {
  register,
  verify,
  resendVerification,
  login,
  logout,
  forgot,
  reset,
  change
} = require("../controllers/authController");
const { authenticate } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/register", register);
router.post("/verify-email", verify);
router.post("/verify", verify);
router.post("/email-verification", verify);
router.post("/verification", verify);
router.post("/resend-verification", resendVerification);
router.post("/login", login);
router.post("/logout", logout);
router.post("/forgot-password", forgot);
router.post("/reset-password", reset);
router.post("/change-password", authenticate, change);

module.exports = router;
