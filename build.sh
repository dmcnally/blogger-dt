#!/usr/bin/env bash
echo "Building ..."

bundle check || bundle install
bundle exec rails db:create db:migrate db:seed development:db:seed db:test:prepare
