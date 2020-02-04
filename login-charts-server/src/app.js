const bodyParser = require("body-parser");
const express = require("express");
const fs = require("fs");
const morgan = require("morgan");
const db = require("./db");
const handlebars = require("handlebars");

const app = express();
app.use(morgan("common"));
app.use(bodyParser.json());
app.use(express.static("public"));

const metaRefreshHost = () => {
  if (process.env.NODE_ENV == "production") {
    return "https://login-charts-server.app.cloud.gov/";
  } else {
    return "http://localhost:3000/";
  }
};

TEMPLATES = ["./templates/alb_errors.html", "./templates/authentications.html"];

app.get("/", (req, res) => {
  const currentTemplateIndex =
    Math.floor(new Date() / 1000 / 60) % TEMPLATES.length;

  const html = fs.readFileSync(TEMPLATES[currentTemplateIndex]).toString();
  const template = handlebars.compile(html);

  return db
    .fetchReports()
    .then(reports => {
      data = { host: metaRefreshHost(), reports: JSON.stringify(reports) };
      res.send(template(data));
    })
    .catch(err => {
      console.error(err);
      res.status(500).send("Error");
    });
});

app.post("/reports", (req, res) => {
  if (!process.env.API_TOKEN) {
    return res.status(500).send("API_TOKEN unset");
  }
  if (req.header("X-API-TOKEN") != process.env.API_TOKEN) {
    return res.status(401).send("Not authorized");
  }
  return Promise.resolve()
    .then(() => {
      return {
        name: req.body.report.name,
        data: req.body.report.data,
      };
    })
    .then(report => {
      return db.createOrUpdateReport(report);
    })
    .then(() => {
      res.status(201).send("Success");
    })
    .catch(err => {
      console.error(err);
      res.status(500).send("Error");
    });
});

module.exports = app;
