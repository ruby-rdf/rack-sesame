module Rack
  module Sesame
    ##
    # Proxies requests from the Rack endpoint to a specified remote Sesame
    # 2.0 HTTP API endpoint using the `RDF::Sesame` library.
    #
    # @see http://rdf.rubyforge.org/sesame/
    class Proxy < Endpoint
      attr_reader :server

      def initialize(url, options = {})
        require 'rdf/sesame' unless defined?(::RDF::Sesame)

        @server  = RDF::Sesame::Server.new(url, options)
        @options = options
      end

      def protocol(env)
        respond_with(server.protocol.to_s)
      end

      def repositories(env)
        respond_with("TODO: GET /repositories")
      end

      def repository_query(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}")
      end

      def repository_statements(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}/statements")
      end

      def repository_contexts(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}/contexts")
      end

      def repository_size(env, repository_name)
        respond_with(server.repository(repository_name).count.to_s)
      end

      def repository_namespaces(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}/namespaces")
      end
    end
  end
end
