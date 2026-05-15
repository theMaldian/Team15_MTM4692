const express = require("express");

const authRoutes = require("./routes/authRoutes");
const applicationRoutes = require("./routes/applicationRoutes");
const catalogRoutes = require("./routes/catalogRoutes");
const jobRoutes = require("./routes/jobRoutes");
const profileRoutes = require("./routes/profileRoutes");

const app = express();

app.use(express.json());

app.use("/auth", authRoutes);
app.use("/applications", applicationRoutes);
app.use("/", catalogRoutes);
app.use("/jobs", jobRoutes);
app.use("/profile", profileRoutes);

const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
