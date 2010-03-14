module Rack
  module Sesame
    ##
    # Proxies requests from the Rack endpoint to a specified remote Sesame
    # 2.0 HTTP API endpoint using the `RDF::Sesame` library.
    #
    # @see http://rdf.rubyforge.org/sesame/
    class Proxy < Endpoint
      attr_reader :server

      ##
      # @param  [RDF::URI, String, #to_s] url
      # @param  [Hash{Symbol => Object}]  options
      def initialize(url, options = {})
        require 'rdf/sesame' unless defined?(::RDF::Sesame)
        @server  = RDF::Sesame::Server.new(url, options)
        @options = options
      end

      ##
      # `GET /protocol`
      def protocol(env)
        respond_with(server.protocol.to_s)
      end

      ##
      # `GET /repositories`
      def repositories(env)
        body = {
          :head    => {:vars     => [:uri, :id, :title, :readable, :writable]},
          :results => {:bindings => []},
        }

        server.each_repository do |repository|
          body[:results][:bindings] << {
            :uri      => {:type => :uri,     :value => repository.uri.to_s},
            :id       => {:type => :literal, :value => repository.id},
            :title    => {:type => :literal, :value => repository.title},
            :readable => {
              :type     => :'typed-literal',
              :value    => repository.readable?.to_s,
              :datatype => RDF::XSD.boolean.to_s,
            },
            :writable => {
              :type     => :'typed-literal',
              :value    => repository.writable?.to_s,
              :datatype => RDF::XSD.boolean.to_s,
            },
          }
        end

        respond_with(body.to_json, {
          'Content-Type'        => 'application/sparql-results+json; charset=utf-8',
          'Content-Disposition' => 'attachment; filename=repositories.srj',
          'Vary'                => 'accept',
        })
      end

      ##
      # `GET /repositories/:name`
      def repository_query(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}")
      end

      ##
      # `GET /repositories/:name/statements`
      def repository_statements(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}/statements")
      end

      ##
      # `GET /repositories/:name/contexts`
      def repository_contexts(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}/contexts")
      end

      ##
      # `GET /repositories/:name/size`
      def repository_size(env, repository_name)
        respond_with(server.repository(repository_name).count.to_s)
      end

      ##
      # `GET /repositories/:name/namespaces`
      def repository_namespaces(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}/namespaces")
      end
    end
  end
end
