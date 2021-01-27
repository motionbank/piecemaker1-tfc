FROM ruby:1.9.3
MAINTAINER Motion Bank

WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y libpq5 libpq-dev nodejs
RUN bundle install
RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "thin", "start", "-R", "config.ru", "-e", "$RAILS_ENV", "-p", "3000"]
