require("dotenv").config();
const { EmailClient } = require("@azure/communication-email");

function requiredEnv(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

const client = new EmailClient(requiredEnv("ACS_CONNECTION_STRING"));

async function sendVerificationMail(to, code) {
  const poller = await client.beginSend({
    senderAddress: requiredEnv("MAIL_FROM"),
    content: {
      subject: "Your verification code",
      plainText: `Your verification code is: ${code}. This code expires in 10 minutes.`,
      html: `
        <div style="font-family: Arial, sans-serif;">
          <h2>Email Verification</h2>
          <p>Your verification code is:</p>
          <h1 style="letter-spacing: 4px;">${code}</h1>
          <p>This code expires in 10 minutes.</p>
        </div>
      `
    },
    recipients: {
      to: [{ address: to }]
    }
  });

  return await poller.pollUntilDone();
}

async function sendPasswordResetMail(to, code) {
  const poller = await client.beginSend({
    senderAddress: requiredEnv("MAIL_FROM"),
    content: {
      subject: "Your password reset code",
      plainText: `Your password reset code is: ${code}. This code expires in 10 minutes.`,
      html: `
        <div style="font-family: Arial, sans-serif;">
          <h2>Password Reset</h2>
          <p>Your password reset code is:</p>
          <h1 style="letter-spacing: 4px;">${code}</h1>
          <p>This code expires in 10 minutes.</p>
        </div>
      `
    },
    recipients: {
      to: [{ address: to }]
    }
  });

  return await poller.pollUntilDone();
}

module.exports = {
  sendVerificationMail,
  sendPasswordResetMail
};
