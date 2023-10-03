# syntax=docker/dockerfile:1
FROM ruby:3.2 AS base

RUN apt-get update -qq &&\
  apt-get install -y npm &&\
  npm install -g yarn

# instalação das gems necessárias
WORKDIR /app
ADD Gemfile ./
RUN bundle install

# ambiente de desenvolvimento
FROM base AS develop
WORKDIR /app/api-rails

# instalação das dependências do Rails
ADD src/Gemfile src/Gemfile.lock ./
RUN\
  bundle config set --local --with development &&\
  bundle install

# copia do código fonte
COPY src/ ./

ENTRYPOINT ["bin/sh"]

# ambiente de produção
FROM develop AS production

EXPOSE 3000
WORKDIR /app/api-rails

ENTRYPOINT ["bin/rails", "server"]

