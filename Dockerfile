FROM hexpm/elixir:1.5.1-erlang-20.0.5-alpine-3.12.0

ENV MIX_ENV=prod PORT=4000
ADD mix.exs mix.lock ./
RUN mix do local.hex --force, local.rebar --force
RUN mix do deps.get --only prod, deps.compile
ADD config ./config
ADD lib ./lib
ADD priv ./priv
ADD web ./web
RUN mix do compile

COPY brunch-config.js package.json package-lock.json ./
RUN apk add --no-cache nodejs npm
RUN npm install --quiet --no-progress
RUN node_modules/brunch/bin/brunch build --production
RUN mix phoenix.digest

CMD mix run --no-deps-check --no-halt
