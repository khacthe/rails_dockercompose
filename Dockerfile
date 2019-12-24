FROM ruby:2.6.5

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  apt-get update -qq && \
  apt-get install -y build-essential \
  default-libmysqlclient-dev \
  nodejs \
  default-mysql-client \
  xvfb \
  redis-tools && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  lsof \
  vim

ENV APP_ROOT /opt/webapp
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock startup.sh /tmp/
RUN cd /tmp && bundle
RUN gem install foreman

#ARG ENV="staging"
#ENV RAILS_ENV $ENV
#RUN bundle exec rake db:migrate

ARG RAILS_MASTER_KEY
