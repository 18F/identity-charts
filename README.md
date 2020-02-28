This code is used to provide charts for login.gov top line metrics.
The codebase is broken into 2 parts:

To setup the server, run the following from the `login-chars-server` dir:

```shell
bundle install
rake db:create && rake db:migrate
```

To start the server run `rackup`.

To download reports from CloudWatch you will need AWS credentials in your environment.
If you are on the login team the easiest way to do this is likely setting your AWS profile, e.g.

```shell
export AWS_PROFILE=identity
```
