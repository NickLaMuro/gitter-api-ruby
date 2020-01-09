gitter-api-ruby
===============

A ruby client for the [gitter][] API.

Includes an `ActiveRecord`-like interface with models that are parsed from
the responses, as well as a lower level request/json-response interface.


Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'gitter-api-ruby'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install gitter-api-ruby
```


Usage
-----

### Client Setup

The `Gitter::API::Client` is the main http component, and is in charge of auth
and configuration of the base endpoint.

In most cases, only a token is needed for the client instance:

``` ruby
client = Gitter::API::Client.new :token => "1a2b3c4d5e6f7a8b9c0d"
```

### Configuration

There are a few tunables that can be configured globally, or for each instance
of `Gitter::API::Client`:

``` ruby
Config.api_prefix
#=> "/v1"
Config.api_url
#=> "https://api.gitter.im"
Config.ssl_verify
#=> false

Config.api_prefix = "/api/v1"
client = Gitter::API::Client.new :api_uri => URI("http://localhost:4000")
client.api_prefix
#=> "/api/v1"
client.api_url
#=> "https://api.gitter.im"
client.ssl_verify
#=> false
```

### Making requests

`Gitter::API::Client` provides `ActiveRecord`-like response objects for each of
it's high level methods found on the client itself, as well as what is
available from the returned objects:

```ruby
# Fetching the configured user:
client.user
#=> #<Gitter::API::User:0x00007ff49b293c01 ... >

# Fetch rooms/private chats for the configured user
client.user.rooms
client.rooms # equivalent with the above, but memoized to the client object
#=> #<Gitter::API::Room::Collection:0x00007ff49b293c02 ... >

# API Collections are Enumerable
client.rooms.map(&:uri)
#=> ["gitterHQ/sandbox", "gitterHQ/api"]

client.rooms.first
#=> #<Gitter::API::Room:0x00007ff49b293c03 ... >

# Advanced example:
#
# print the first 50 chars of the last 5 messages from each room
client.rooms.each do |room|
  puts room.name
  puts "-" * room.name.size

  puts room.messages(:limit => 5).map {|msg| "@#{msg.user.username}: #{msg.text[0, 50]}..." }
  puts
end
#=> gitterHQ/api
#=> ----------------
#=> @alice: Hey...
#=> @bob: Hi...
#=> @alice: I stole your identity...
#=> @bob: Oh... that isn't good...
#=> @bob: Good thing I am a fictional user, huh...
#=>
#=> gitterHQ/sandbox
#=> ------------
#=> ...
```

Not everything is currently implemented by the client, but for everything else,
the raw `.get`, `.post`, and `.put` methods of the client are available to
execute requests on those missing endpoints:

```ruby
# Note:  `/v1/users/me` (plural form) is a dummy route... do not use
client.get "/v1/user/me"
#=> { "user" => "NickLaMuro", "id" => ... }

# Bulk "mark messages as read" for a particular room to reduce number of http
# requests
#
# https://developer.gitter.im/docs/user-resource#mark-unread-items-as-read
#
# (currently not a high level method for this, only for single messages)
room          = client.rooms.first
msg_ids       = room.unread_messages.map(&:id)
payload       = { "chat" => msg_ids }
mark_read_uri = "/v1/user/#{client.user.id}/rooms/#{room.id}/unreadItems"

client.post mark_read_uri, payload
```


### Developer Setup

Clone as you would...

This plugin requires zero dependencies to work with (besides what is included
with ruby for a while now), so there is nothing required to install and get
setup.

However, to work with the gitter API, you will need on of two things:

- A local running copy of [gitter-webapp][]
- An API key from the public instance of [gitter][]

The first option has a pretty lengthy setup process, so that will not be
covered here, but a viable option if you don't want to make a mess of a
community room while doing your testing.

For the section option, it doesn't take much:

1. Grab your API key from https://developer.gitter.im/apps
2. Save it as a one line file in top level of this repo: `.gitter.token`
3. Run `rake console`

From there, `client` is a configured `Gitter::API::Client` instance for you to
start testing with.


TODO
----

- Implement missing top-level functions (user bans, leave rooms, etc.)
- Support app client keys (is this different at all?)
- Add integration tests (run a local copy of gitter)
- CI testing


[gitter]:        https://gitter.im
[gitter-webapp]: https://gitlab.com/gitlab-org/gitter/webapp
