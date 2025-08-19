#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Setup database (create if not exists, then migrate)
bundle exec rake db:create db:migrate

