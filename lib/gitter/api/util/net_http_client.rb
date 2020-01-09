require "net/http"

module Net # :nodoc:
  class HTTP # :nodoc:
    # == Net::HTTP::RestClientModule
    #
    # A wrapper library for NetHTTP to create a simplistic "Rest Client" class
    #
    # Simply `include Net::HTTP::RestClientModule` into a class, and make sure
    # on initialization a `uri` method/accessor with a `URI` object is created.
    #
    #     class MyRestClient
    #       include Net::HTTP::RestClientModule
    #
    #       attr_accessor :uri
    #
    #       def initialize
    #         @uri = URI("http://example.com")
    #       end
    #
    #       # override this if needed, otherewise true by default
    #       def ssl_verify
    #         !!ENV["SHOULD_SSL_VERIFY"]
    #       end
    #     end
    #
    #     # calling
    #     MyRestClient.new.get  "/foo/bar"
    #     MyRestClient.new.post "/foo/bar"
    #     MyRestClient.new.put  "/foo/bar"
    #
    #--
    #
    # TODO:  Make query_params a little more generic
    # TODO:  Create a gem for this simple lib
    #
    module RestClientModule

      # +Net::HTTP+ Connection object for the client object
      #
      # Will conigure it based off of the +uri+ method/accessor of current
      # instance if one has not been instanciated yet.
      #
      def connection
        return @connection if defined? @connection

        verify_ssl = respond_to?(:ssl_verify) ? ssl_verify : true

        @connection             = Net::HTTP.new(uri.host, uri.port)
        @connection.use_ssl     = true                      if uri.scheme == "https"
        @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE unless verify_ssl

        @connection
      end

      # Send a +GET+ request to the configured +connection+
      #
      # ==== Parameters
      #
      # [*path* (String)]          URL path for the request
      # [*query_params* (Hash)]    Query params to add to the path
      # [*request_headers* (Hash)] Request specific headers
      #
      def get path, query_params = {}, request_headers = {}
        if query_params.delete_if { |_,v| v.nil? }.empty?
          get_uri = path
        else
          uri_class = uri.scheme == "https" ? URI::HTTPS : URI::HTTP
          get_uri   = uri_class.build :host  => uri.host,
                                      :path  => path,
                                      :query => URI.encode_www_form(query_params)
        end

        get_headers = headers request_headers
        get_request = Net::HTTP::Get.new get_uri, get_headers

        connection_do get_request
      end

      # Send a +POST+ request to the configured +connection+
      #
      # ==== Parameters
      #
      # [*path* (String)]          URL path for the request
      # [*payload* (Hash)]         Request body
      # [*request_headers* (Hash)] Request specific headers
      #
      def post path, payload, request_headers = {}
        post_headers      = headers request_headers
        post_request      = Net::HTTP::Post.new path, post_headers
        post_request.body = payload

        connection_do post_request
      end

      # Send a +PUT+ request to the configured +connection+
      #
      # ==== Parameters
      #
      # [*path* (String)]          URL path for the request
      # [*payload* (Hash)]         Request body
      # [*request_headers* (Hash)] Request specific headers
      #
      def put path, payload, request_headers = {}
        put_headers      = headers request_headers
        put_request      = Net::HTTP::Put.new path, put_headers
        put_request.body = payload

        connection_do put_request
      end

      private

      # Helper for executing a request and building a response
      def connection_do req
        # puts "connection_do: #{req.method} #{req.path}"  # debugging...
        response = connection.start {|http| http.request req }
        response_builder response
      end

      # Helper for building headers for a request
      def headers request_headers = {}
        default_headers.dup.merge request_headers
      end

      # :doc:
      #
      # Format and return a response
      #
      # Default return value is the +Net::HTTP::Request+ body, but the
      # +response_builder+ method can be overwritten to configure out the data
      # for a request is returned
      def response_builder response
        response.body
      end

      # :doc:
      #
      # Default headers for each request
      #
      # Can be overwritten in the included class to allow for specific headers
      # to be added to every request (Auth headers, Accept headers, etc.)
      def default_headers
        {}
      end
    end
  end
end
