FROM ruby:3.1.0

WORKDIR /app

COPY . .
RUN bundle lock --add-platform x86_64-linux
RUN bundle install
