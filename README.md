# Ref

> A server to host AI competitions and watch the games unfold

# Deploying

This project is deployed with docker. You can see the Dockerfile for details or you can run your own using the [public docker image]().

To build a new docker image follow these steps:
* make your own `config/prod.secret.exs` file with your database credentials
  * currently ref doesn't use a database so this only the `secret_key_base` is actually used
* change the host in `config/prod.exs`
* compile assets: `brunch build --production`
* build the docker: `docker build -t hqmq/ref:latest .`

The image exposes port 4000 so when you run the docker container make sure you map that to something public.
