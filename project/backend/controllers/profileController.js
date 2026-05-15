const {
  getProfile,
  updateProfile,
  addSkill,
  removeSkill,
  addOrUpdateLanguage,
  removeLanguage,
  createExperience,
  updateExperience,
  deleteExperience,
  createEducation,
  updateEducation,
  deleteEducation
} = require("../services/profileService");

async function show(req, res) {
  try {
    const result = await getProfile(req.user.user_id);

    return res.status(200).json(result);
  } catch (err) {
    console.error("GET PROFILE ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Get profile failed"
    });
  }
}

async function update(req, res) {
  try {
    const result = await updateProfile(req.user.user_id, req.user.role, req.body);

    return res.status(200).json(result);
  } catch (err) {
    console.error("UPDATE PROFILE ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Update profile failed"
    });
  }
}

function handler(action, errorMessage, status = 200) {
  return async function profileHandler(req, res) {
    try {
      const result = await action(req);

      return res.status(status).json(result);
    } catch (err) {
      console.error(`${errorMessage.toUpperCase()} ERROR:`, err);

      return res.status(err.status || 500).json({
        error: err.message || `${errorMessage} failed`
      });
    }
  };
}

module.exports = {
  show,
  update,
  addSkill: handler(req => addSkill(req.user.user_id, req.body), "add skill"),
  removeSkill: handler(req => removeSkill(req.user.user_id, req.params.skillId), "remove skill"),
  addLanguage: handler(req => addOrUpdateLanguage(req.user.user_id, req.body), "add language"),
  updateLanguage: handler(req => addOrUpdateLanguage(req.user.user_id, {
    ...req.body,
    language_id: req.params.languageId
  }), "update language"),
  removeLanguage: handler(req => removeLanguage(req.user.user_id, req.params.languageId), "remove language"),
  createExperience: handler(req => createExperience(req.user.user_id, req.body), "create experience", 201),
  updateExperience: handler(req => updateExperience(req.user.user_id, req.params.experienceId, req.body), "update experience"),
  deleteExperience: handler(req => deleteExperience(req.user.user_id, req.params.experienceId), "delete experience"),
  createEducation: handler(req => createEducation(req.user.user_id, req.body), "create education", 201),
  updateEducation: handler(req => updateEducation(req.user.user_id, req.params.educationId, req.body), "update education"),
  deleteEducation: handler(req => deleteEducation(req.user.user_id, req.params.educationId), "delete education")
};
