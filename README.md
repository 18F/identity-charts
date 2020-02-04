This code is used to provide charts for login.gov top line metrics.
The codebase is broken into 2 parts:

- *The charts server*: This displays reports on a carousel of graphs at a kiosk. It is built to be deployed to cloud.gov.
- *The charts reporter*: This downloads data from CloudWatch metrics and pushes them to the chart server.

To setup the server, run the following from the `login-chars-server` dir:

```shell
createdb login-charts-server
yarn install
```

The install script will install the necessary dependencies and run the migrations.

To start the server run `API_TOKEN=123abc yarn start`.

To setup the reporter, first add the following to `login-charts-reporter/.env`:

```shell
API_TOKEN=123abc
REPORTS_URL='http://localhost:3000/reports
```

To download reports from CloudWatch you will need AWS credentials in your environment.
If you are on the login team the easiest way to do this is likely setting your AWS profile, e.g.

```shell
export AWS_PROFILE=identity
```

After everything is setup run `ruby loop.rb` in `login-charts-reporter` to start pushing data to the server.
Once it has uploaded its first round of data everything should be visible on https://localhost:3000
