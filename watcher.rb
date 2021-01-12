# -*- encoding : utf-8 -*-
#
#          DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                  Version 2, December 2004
#
#  Copyright (C) 2004 Sam Hocevar
#  14 rue de Plaisance, 75014 Paris, France
#  Everyone is permitted to copy and distribute verbatim or modified
#  copies of this license document, and changing it is allowed as long
#  as the name is changed.
#  DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#
#
#  David Hagege <david.hagege@gmail.com>
#

require "greenhouse_io"
require "active_support/core_ext/hash/indifferent_access"
require "yaml"
require "pony"
require "awesome_print"

gh = GreenhouseIo::JobBoard.new
config = HashWithIndifferentAccess.new(YAML.load_file("watcher.yml")).deep_symbolize_keys

last_updated_at = File.exists?("watcher.log") ? JSON.parse(File.read("watcher.log")) : {}

config[:organizations].each do |org|
  last_updated_at[org] ||= 0
  ap last_updated_at
  jobs = gh.jobs(organization: org)["jobs"].map do |x|
    {
      url: x["absolute_url"],
      location: x["location"]["name"],
      title: x["title"],
      updated_at: DateTime.parse(x["updated_at"]).to_time.to_i,
    }
  end.select { |j| j[:updated_at] > last_updated_at[org] }
  next if jobs.empty?

  last_updated_at[org] = jobs.map { |j| j[:updated_at] }.max

  if config[:filters]
    if location = config[:filters][:location]
      jobs.select! { |j| j[:location] =~ Regexp.new(location) }
    end
    if title = config[:filters][:title]
      jobs.select! { |j| j[:title] =~ Regexp.new(title) }
    end
  end
  ap jobs

  unless jobs.empty?
    Pony.mail(
      to: config[:mail][:to],
      from: config[:mail][:from],
      subject: "New jobs at #{org}",
      body: "New jobs at #{org}:\n#{jobs.map { |j| "#{j[:title]} - #{j[:location]}: #{j[:url]}" }.join("\n")}",
      html_body: "New jobs at #{org}:<br>#{jobs.map { |j| "<a href=#{j[:url]}>#{j[:title]} - #{j[:location]}</a>" }.join("<br>")}",
      via: config[:mail][:pony_via],
      via_options: config[:mail][:pony_via_options],
    )
  end

  open("watcher.log", "w") do |f|
    f.write(JSON.pretty_generate(last_updated_at))
  end
end
