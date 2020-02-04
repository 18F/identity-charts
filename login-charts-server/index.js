const app = require("./src/app.js");
const port = process.env.PORT || 3000;

app.listen(port, err => {
  if (!err) {
    console.log(`Chart server listening on port ${port}!`);
  } else {
    console.error(err);
  }
});
