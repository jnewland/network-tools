FROM ruby:2.7.0-buster
# throw errors if Gemfile has been modified since Gemfile.lock
# to update
# docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.7.0-buster bundle install
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    geoip-bin \
    geoip-database-extra \
    graphviz \
    jq \
    nmap

COPY Gemfile Gemfile.lock ./
RUN bundle install

ADD . /usr/src/app/
ENV LANG C.UTF-8