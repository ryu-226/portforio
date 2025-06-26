FROM ruby:3.1.4

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update -qq && \
    apt-get install -y nodejs yarn postgresql-client

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

COPY . .

ENTRYPOINT ["./entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
