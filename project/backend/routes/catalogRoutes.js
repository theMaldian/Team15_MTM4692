const express = require("express");

const {
  skills,
  languages
} = require("../controllers/catalogController");
const { authenticate } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/skills", authenticate, skills);
router.get("/languages", authenticate, languages);

module.exports = router;
