FROM ruby:2.3.1-alpine

MAINTAINER Eliot Jordan <eliot.jordan@gmail.com>
# Adapted from centurylink/alpine-rails

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base" \
    DEV_PACKAGES="git zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev sqlite-dev postgresql-dev" \
    RUBY_PACKAGES="ruby ruby-io-console ruby-json yaml nodejs" \
    RAILS_VERSION="5.0.0.1"

RUN \
  apk --update --upgrade add $BUILD_PACKAGES $RUBY_PACKAGES $DEV_PACKAGES && \
  gem install -N bundler  && \
  rm -rf /var/cache/apk/*
  
RUN gem install -N nokogiri && \
  gem install -N rails --version "$RAILS_VERSION" && \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \

  # cleanup and settings
  bundle config --global build.nokogiri  "--use-system-libraries" && \
  bundle config --global build.nokogumbo "--use-system-libraries" && \
  find / -type f -iname \*.apk-new -delete && \
  rm -rf /var/cache/apk/* && \
  rm -rf /usr/lib/lib/ruby/gems/*/cache/* && \
  rm -rf ~/.gem

WORKDIR /usr/src

RUN git clone https://github.com/pulibrary/pulmap.git

WORKDIR /usr/src/pulmap

RUN git checkout 213-remove-rubyracer && \
  bundle install && \
  cp config/database.yml.tmpl config/database.yml && \
  sed -i 's/localhost:5672/rabbitmq:5672/g' config/pulmap.yml && \
  rake db:migrate

ENV WORKERS GeoblacklightEventHandler

# Add default env variable referencing our solr container
# Depends on --link my_solr_container:solr
ENV SOLR_URL http://solr:8983/solr/geoblacklight

VOLUME /usr/src/pulmap/tmp

EXPOSE 3000

CMD rake sneakers:run & rails server -b 0.0.0.0
