FROM ruby:2.6.5

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  apt-get update -qq && \
  apt-get install -y build-essential \
  default-libmysqlclient-dev \
  nodejs \
  default-mysql-client \
  redis-tools && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  lsof \
  vim

ENV APP_ROOT /opt/webapp
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock startup.sh /tmp/
RUN cd /tmp && gem update && bundle
RUN gem install foreman

RUN npm install -g yarn
COPY package.json yarn.lock /tmp/
RUN cd /tmp && yarn

ADD . $APP_ROOT
RUN cp -a /tmp/node_modules $APP_ROOT

RUN chmod 750 startup.sh
CMD ["/opt/webapp/startup.sh"]

ARG RAILS_MASTER_KEY
