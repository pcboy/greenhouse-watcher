FROM ruby:2.6
RUN groupadd -r app -g 1000 && useradd -u 1000 -r -g app -m -d /app -s /sbin/nologin -c "App user" app && \
    chmod 755 /app
WORKDIR /app

USER app

COPY Gemfile Gemfile.lock watcher.rb watcher.yml runner.sh ./
RUN gem install bundler
RUN bundle install

ENTRYPOINT ["./runner.sh"]
