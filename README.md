This code is used to provide charts for login.gov top line metrics.
The codebase is broken into 2 parts:

To setup the server, run the following from the `login-chars-server` dir:

```shell
bundle install
rake db:create && rake db:migrate
```

In order for the app to properly query AWS resources you will need to set the following in a .env file.

```shell
HOST_NAME='http://localhost:4567' # The URL where the app is running. Default should work locally.
LOGIN_S3_BUCKET='login-gov.reports.55555555555-us-west-2' # The name of the S3 bucket where reports are saved
LOGIN_ALB_LOAD_BALANCER_NAME='app/login-idp-alb-prod/123abc' # The name of the prod load balancer dimension for CloudWatch metrics
```

To start the server run `rackup`.

To download reports from CloudWatch you will need AWS credentials in your environment.
If you are on the login team the easiest way to do this is likely setting your AWS profile, e.g.

```shell
export AWS_PROFILE=identity
```
