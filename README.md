# Ref

> A server to host AI competitions and watch the games unfold

# Deploying

This project is deployed with docker. You can see the Dockerfile for details or you can run your own using the [public docker image]().

To build a new docker image follow these steps:
* make your own `config/prod.secret.exs` file with your server secrets
* change the host in `config/prod.exs`
* compile assets: `brunch build --production`
* build the docker: `docker build -t hqmq/ref:latest .`

The image exposes port 4000 so when you run the docker container make sure you map that to something public.

Personally I do this with an nginx config on the docker host like this:

```
upstream ref {
  server 127.0.0.1:4000 fail_timeout=5s;
}

server {
  server_name games.riesd.com;
  listen 80;
  root /home/ec2-user/www;
  try_files $uri/index.html $uri.html $uri @app;
  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_pass http://ref;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
```
