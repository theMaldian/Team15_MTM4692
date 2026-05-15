const jwt = require("jsonwebtoken");

function requiredEnv(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      error: "Authorization token required"
    });
  }

  const token = authHeader.slice("Bearer ".length).trim();

  try {
    req.user = jwt.verify(token, requiredEnv("JWT_SECRET"));
    return next();
  } catch (err) {
    return res.status(401).json({
      error: "Invalid or expired token"
    });
  }
}

function requireRole(role) {
  return function roleMiddleware(req, res, next) {
    if (!req.user || req.user.role !== role) {
      return res.status(403).json({
        error: `${role} role required`
      });
    }

    return next();
  };
}

module.exports = {
  authenticate,
  requireRole
};
