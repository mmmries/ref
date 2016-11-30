FROM hqmq/alpine-elixir:0.1
MAINTAINER Michael Ries <michael@riesd.com>

ENV MIX_ENV=prod PORT=4000
ADD mix.exs mix.lock ./
RUN mix do deps.get --only prod, deps.compile
ADD config ./config
ADD lib ./lib
ADD priv ./priv
ADD web ./web
RUN mix do compile
RUN mix phoenix.digest

CMD mix run --no-deps-check --no-halt
