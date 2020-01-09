require 'gitter/api'

# Include `gitter/api` and automatically configure a client method on the top
# level of the script (or IRB session) from `.gitter.token` if present in the
# current working directory.
#
# Token file should be a single line with nothing but the token in it
#
#   $ cat .gitter.token
#   1a2b3c4d5e6f7a8b9c0d
#
# NOTE: This isn't intended for production use, and only meant for developer tools
# and example testing scripts.
#

token_file = ".gitter.token"

if File.exist? token_file
  token  = File.read token_file
  client = Gitter::API::Client.new :token => token.strip

  TOPLEVEL_BINDING.receiver.instance_variable_set :@client, client
  TOPLEVEL_BINDING.receiver.define_singleton_method :client do
    @client
  end
end
