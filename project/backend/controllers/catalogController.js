const {
  listSkills,
  listLanguages
} = require("../services/profileService");

async function skills(req, res) {
  try {
    const result = await listSkills();

    return res.status(200).json(result);
  } catch (err) {
    console.error("LIST SKILLS ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "List skills failed"
    });
  }
}

async function languages(req, res) {
  try {
    const result = await listLanguages();

    return res.status(200).json(result);
  } catch (err) {
    console.error("LIST LANGUAGES ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "List languages failed"
    });
  }
}

module.exports = {
  skills,
  languages
};
