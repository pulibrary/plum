FROM ruby:2.3.1-alpine

MAINTAINER Eliot Jordan <eliot.jordan@gmail.com>
# Adapted from centurylink/alpine-rails

ENV FITS_VERSION=0.8.5
ENV FITS_DOWNLOAD_URL="http://projects.iq.harvard.edu/files/fits/files/fits-${FITS_VERSION}.zip"

ENV BUILD_PACKAGES="curl curl-dev ruby-dev build-base" \
    DEV_PACKAGES="git zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev sqlite-dev postgresql-dev" \
    RUBY_PACKAGES="ruby ruby-io-console ruby-json yaml nodejs" \
    GEO_PACKAGES="cairo-dev pango-dev" \
    JAVA_PACKAGES="openjdk8-jre" \
    RAILS_VERSION="5.0.0.1"

RUN \
  apk --update --upgrade add $BUILD_PACKAGES $RUBY_PACKAGES $DEV_PACKAGES $JAVA_PACKAGES $GEO_PACKAGES && \
  apk add gdal-dev --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
  gem install -N bundler && \
  rm -rf /var/cache/apk/*

RUN \
  git clone https://github.com/propublica/simple-tiles.git && \
    cd simple-tiles && \
    sh configure && \
    make && \
    make install

ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"

WORKDIR /usr/src/fits
RUN \
  curl $FITS_DOWNLOAD_URL > fits.zip && \
    unzip fits.zip && \
    chmod a+x fits-$FITS_VERSION/*.sh && \
    cd fits-$FITS_VERSION/ && \
    mv *.properties *.sh lib tools xml /usr/local/bin

WORKDIR /usr/src
RUN \
  gem install -N nokogiri && \
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

RUN git clone https://github.com/pulibrary/plum.git
WORKDIR /usr/src/plum

RUN bundle install && rake db:migrate

ADD redis.yml /usr/src/plum/config/redis.yml
ADD solr.yml /usr/src/plum/config/solr.yml
ADD fedora.yml /usr/src/plum/config/fedora.yml

EXPOSE 3000

CMD rails s -b 0.0.0.0