const express = require("express");

const {
  show,
  update,
  addSkill,
  removeSkill,
  addLanguage,
  updateLanguage,
  removeLanguage,
  createExperience,
  updateExperience,
  deleteExperience,
  createEducation,
  updateEducation,
  deleteEducation
} = require("../controllers/profileController");
const { authenticate } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", authenticate, show);
router.put("/", authenticate, update);
router.post("/skills", authenticate, addSkill);
router.delete("/skills/:skillId", authenticate, removeSkill);
router.post("/languages", authenticate, addLanguage);
router.put("/languages/:languageId", authenticate, updateLanguage);
router.delete("/languages/:languageId", authenticate, removeLanguage);
router.post("/experiences", authenticate, createExperience);
router.put("/experiences/:experienceId", authenticate, updateExperience);
router.delete("/experiences/:experienceId", authenticate, deleteExperience);
router.post("/educations", authenticate, createEducation);
router.put("/educations/:educationId", authenticate, updateEducation);
router.delete("/educations/:educationId", authenticate, deleteEducation);

module.exports = router;
