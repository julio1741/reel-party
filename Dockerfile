FROM ruby:3.2.8

ENV BUNDLER_VERSION=2.4.22

# 👇 Agrega las librerías necesarias para psych y otras gems nativas
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libyaml-dev \
  libpq-dev \
  nodejs \
  yarn \
  postgresql-client

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:$BUNDLER_VERSION
RUN bundle install

COPY . .

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3100"]
