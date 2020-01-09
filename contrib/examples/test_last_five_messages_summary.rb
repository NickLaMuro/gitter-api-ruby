#!/usr/bin/env ruby
#
# For the first two rooms of the configured user:
#
#   - Print the room name
#   - Underline it
#   - Print the username and message text for the last five chats in said room
#
# Trims messages to 50 chars just to keep it as a summary
#
# To view with colors, run with `COLOR=1`
#

lib = File.expand_path(File.join("..", "..", "..", "lib"), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative File.join(*%w[.. scripts load_client_from_token_file])

def display *values
  opts = values.pop if values.last.is_a? Hash
  mod  = "\e[1;36m"
  mod  = "\e[1m"    if opts && opts[:bold]

  if ENV.has_key? "COLOR"
    [mod] << values << "\e[0m"
  else
    values
  end.join
end

client.rooms.first(2).each do |room|
  puts display(room.name, :bold => true)
  puts "-" * room.name.size

  msgs = room.messages(:limit => 5)
             .map {|msg| "#{display '@', msg.user.username}: #{msg.text[0, 50]}..." }

  puts msgs
  puts
end
