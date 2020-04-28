#!/usr/bin/env ruby
#
# For each group (ORG) that a user is a part of, determine the number of
# messages sent for a given PATTERN (or all time if left empty
#
# Prints the count for each room and the total for all
#
# Borrows some code I wrote for searching gitter to get the message count via
# the archives endpoint:
#
#   https://gist.github.com/NickLaMuro/efbd1bcb5781e50d4546008eb3544c26
#
# Requires `oga` ruby gem to be installed
#

lib = File.expand_path(File.join("..", "..", "..", "lib"), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative File.join(*%w[.. scripts load_client_from_token_file])
require 'oga'
require 'optparse'

options = {}

OptionParser.new do |opt|
  opt.banner = "Usage: #{File.basename $0} ORG [DATE_PATTERN]"

  opt.separator ""
  opt.separator "Count number of messages for a given gitter.im ORG"
  opt.separator ""

  opt.separator ""
  opt.separator "Examples"
  opt.separator ""
  opt.separator "  Count all messages in ManageIQ for the month of March, 2020"
  opt.separator ""
  opt.separator "    $ #{File.basename $0} ManageIQ 2020/03"
  opt.separator ""
  opt.separator "  Count all messages in ManageIQ for the month of April, 2020"
  opt.separator ""
  opt.separator "    $ #{File.basename $0} ManageIQ 2020/04"
  opt.separator ""
  opt.separator "  Count all messages in ManageIQ for all time (not recommended"
  opt.separator ""
  opt.separator "    $ #{File.basename $0} ManageIQ"
  opt.separator ""
  opt.separator ""
end.parse!

host         = "https://gitter.im/"
group_name   = ARGV.shift
group_data   = {}
date_pattern = ARGV.shift.to_s

raise "Please provide a group for your user to filter on!" unless group_name

if date_pattern == ""
  warn "It is highly recommended you have a data_pattern that filters by YYYY/MM at"
  warn "least, otherwise you might be making a lot of requests for your group."
end

client.groups.each do |group|
  total_group_messages = 0

  next if group.name != group_name

  puts "Messages for #{group.name}:"
  puts "Messages for #{group.name}:".gsub(/./, "=")
  puts

  exit

  group.rooms.each do |room|
    path            = "/#{room.name}/archives"
    link_regexp     = /href="(#{path}\/#{date_pattern}[^"]*)"/
    archives_list   = Net::HTTP.get URI("#{host}#{path}")
    archive_paths   = archives_list.scan(link_regexp).map(&:first)
    total_room_msgs = 0

    archive_paths.each do |archive|
      document         = Oga.parse_html Net::HTTP.get(URI("#{host}#{archive}"))
      date_msg_count   = document.css('.chat-item__content').count
      total_room_msgs += date_msg_count

      puts "  #{archive}: #{date_msg_count}"
    end

    puts " #{room.name} Total:  #{total_room_msgs}"

    group_data[room.name] = total_room_msgs
    total_group_messages     += total_room_msgs
  end

  puts
  puts
  puts "Grand Total for #{date_pattern.inspect}:  #{total_group_messages}"
end


require 'json'
File.write 'data.json', group_data.to_json
