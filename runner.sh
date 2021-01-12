#!/usr/bin/env bash

while [[ 42 ]];do
  bundle exec ruby watcher.rb
  sleep $((3600 * 12))
done