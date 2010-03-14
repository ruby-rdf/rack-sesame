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
        repositories = server.repositories

        body = {
          :head    => {:vars     => [:uri, :id, :title, :readable, :writable]},
          :results => {:bindings => []},
        }
        repositories.each do |id, repository|
          body[:results][:bindings] << {
            :uri      => {:type => :uri,     :value => repository.uri.to_s},
            :id       => {:type => :literal, :value => (repository.id rescue id).to_s},
            :title    => {:type => :literal, :value => (repository.title rescue '').to_s},
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
        respond_with_json(body, 'repositories')
      end

      ##
      # `GET /repositories/:name`
      def repository_query(env, repository_name)
        respond_with("TODO: GET /repositories/#{repository_name}") # TODO
      end

      ##
      # `GET /repositories/:name/statements`
      def repository_statements(env, repository_name)
        statements = server.repository(repository_name).statements

        respond_with_ntriples(statements, 'statements')
      end

      ##
      # `GET /repositories/:name/contexts`
      def repository_contexts(env, repository_name)
        contexts = server.repository(repository_name).contexts

        body = {
          :head    => {:vars     => [:contextID]},
          :results => {:bindings => []},
        }
        contexts.each do |context|
          body[:results][:bindings] << {
            :contextID => case context
              when RDF::Node
                {:type => :bnode, :value => context.id.to_s}
              when RDF::URI
                {:type => :uri,   :value => context.to_s}
            end
          }
        end
        respond_with_json(body, 'contexts')
      end

      ##
      # `GET /repositories/:name/size`
      def repository_size(env, repository_name)
        size = server.repository(repository_name).count

        respond_with(size.to_s)
      end

      ##
      # `GET /repositories/:name/namespaces`
      def repository_namespaces(env, repository_name)
        namespaces = server.repository(repository_name).namespaces rescue {}

        body = {
          :head    => {:vars     => [:prefix, :namespace]},
          :results => {:bindings => []},
        }
        namespaces.each do |prefix, namespace|
          body[:results][:bindings] << {
            :prefix    => {:type => :literal, :value => prefix.to_s},
            :namespace => {:type => :literal, :value => namespace.to_s},
          }
        end
        respond_with_json(body, 'namespaces')
      end

      def respond_with_json(results, filename = 'results')
        respond_with(results.to_json, {
          'Content-Type'        => 'application/sparql-results+json; charset=utf-8',
          'Content-Disposition' => "attachment; filename=#{filename}.srj",
          'Vary'                => 'accept',
        })
      end

      def respond_with_ntriples(statements, filename = 'statements')
        body = RDF::NTriples::Writer.buffer do |writer|
          statements.each { |statement| writer << statement }
        end
        respond_with(body, {
          'Content-Type'        => 'text/plain; charset=utf-8',
          'Content-Disposition' => "attachment; filename=#{filename}.nt",
          'Vary'                => 'accept',
        })
      end
    end
  end
end
