const {
  registerUser,
  verifyEmail,
  resendVerificationEmail,
  loginUser,
  logoutUser,
  forgotPassword,
  resetPassword,
  changePassword
} = require("../services/authService");

async function register(req, res) {

  try {

    const result = await registerUser(req.body);

    return res.status(201).json(result);

  } catch (err) {

    console.error("REGISTER ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Register failed"
    });

  }

}

async function verify(req, res) {

  try {

    const result = await verifyEmail(req.body);

    return res.status(200).json(result);

  } catch (err) {

    console.error("VERIFY EMAIL ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Email verification failed"
    });

  }

}

async function login(req, res) {

  try {

    const result = await loginUser(req.body);

    return res.status(200).json(result);

  } catch (err) {

    console.error("LOGIN ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Login failed"
    });

  }

}

async function resendVerification(req, res) {

  try {

    const result = await resendVerificationEmail(req.body);

    return res.status(200).json(result);

  } catch (err) {

    console.error("RESEND VERIFICATION ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Resend verification failed"
    });

  }

}

async function logout(req, res) {

  try {

    const result = await logoutUser();

    return res.status(200).json(result);

  } catch (err) {

    console.error("LOGOUT ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Logout failed"
    });

  }

}

async function forgot(req, res) {

  try {

    const result = await forgotPassword(req.body);

    return res.status(200).json(result);

  } catch (err) {

    console.error("FORGOT PASSWORD ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Forgot password failed"
    });

  }

}

async function reset(req, res) {

  try {

    const result = await resetPassword(req.body);

    return res.status(200).json(result);

  } catch (err) {

    console.error("RESET PASSWORD ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Reset password failed"
    });

  }

}

async function change(req, res) {

  try {

    const result = await changePassword(req.user.user_id, req.body);

    return res.status(200).json(result);

  } catch (err) {

    console.error("CHANGE PASSWORD ERROR:", err);

    return res.status(err.status || 500).json({
      error: err.message || "Change password failed"
    });

  }

}

module.exports = {
  register,
  verify,
  resendVerification,
  login,
  logout,
  forgot,
  reset,
  change
};
