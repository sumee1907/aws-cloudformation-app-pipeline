const express = require("express");

const app = express();
const port = process.env.PORT || 3000;

app.get("/health", (request, response) => {
  response.status(200).json({
    status: "healthy"
  });
});

app.get("/time", (request, response) => {
  const now = new Date();

  const currentTime = now.toLocaleString("en-US", {
    dateStyle: "full",
    timeStyle: "long",
    timeZone: "America/New_York"
  });

  response.status(200).json({
    message: "Hello World!",
    currentTime
  });
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Backend listening on port ${port}`);
});