const { randomInt } = require("node:crypto");

function getRoleFromEmail(email) {

  const normalizedEmail =
    email.toLowerCase().trim();

  if (normalizedEmail.endsWith("@std.yildiz.edu.tr")) {
    return "student";
  }

  if (normalizedEmail.endsWith("@yildiz.edu.tr")) {
    return "professor";
  }

  return null;

}

function generateVerificationCode() {

  return randomInt(100000, 1000000).toString();

}

module.exports = {
  getRoleFromEmail,
  generateVerificationCode
};
