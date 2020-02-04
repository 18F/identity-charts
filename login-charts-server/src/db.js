const environment = process.env.NODE_ENV || "development";
const config = require("../knexfile.js")[environment];
const knex = require("knex")(config);

const DEFAULT_REPORT_NAMES = [
  "authentications_today_by_hour",
  "authentications_this_week_by_hour",
  "authentications_today",
  "alb_4xx_errors",
  "alb_5xx_errors",
];

const fetchReports = (report_names = DEFAULT_REPORT_NAMES) => {
  reportFetches = report_names.map(report_name => fetchReport(report_name));
  return Promise.all(reportFetches).then(reports => {
    result = {};
    reports.forEach(report => {
      result[report.name] = report.data;
    });
    return result;
  });
};

const fetchReport = report_name => {
  return knex("reports")
    .first("name", "data")
    .where({ name: report_name })
    .orderBy("created_at", "desc");
};

const createOrUpdateReport = report => {
  return knex("reports")
    .where({ name: report.name })
    .count("id")
    .then(countTuples => {
      const count = countTuples[0].count;
      if (count > 0) {
        return updateReport(report);
      } else {
        return insertReport(report);
      }
    });
};

const updateReport = report => {
  return knex("reports")
    .where({ name: report.name })
    .update({ data: report.data });
};

const insertReport = report => {
  return knex("reports").insert({
    name: report.name,
    data: report.data,
  });
};

module.exports = {
  fetchReports,
  createOrUpdateReport,
};
