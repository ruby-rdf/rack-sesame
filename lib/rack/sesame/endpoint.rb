module Rack
  module Sesame
    ##
    # Sesame 2.0 HTTP API-compatible endpoint middleware for Rack.
    #
    # @see http://www.openrdf.org/doc/sesame2/system/ch08.html
    class Endpoint
      def initialize(options = {})
        @options
      end

      def call(env)
        path, method = env['PATH_INFO'], env['REQUEST_METHOD'].downcase.to_sym

        case path
          when %r(^/protocol$)
            case method
              when :get then protocol(env)
              else not_allowed
            end

          when %r(^/repositories$)
            case method
              when :get then repositories(env)
              else not_allowed
            end

          when %r(^/repositories/([^/]+)/?$)
            case method
              when :get  then repository_query(env, $1)
              when :post then repository_query(env, $1)
              else not_allowed
            end

          when %r(^/repositories/([^/]+)/statements$)
            case method
              when :get    then repository_statements(env, $1)
              when :post   then repository_statements(env, $1)
              when :put    then repository_statements(env, $1)
              when :delete then repository_statements(env, $1)
              else not_allowed
            end

          when %r(^/repositories/([^/]+)/contexts$)
            case method
              when :get then repository_contexts(env, $1)
              else not_allowed
            end

          when %r(^/repositories/([^/]+)/size$)
            case method
              when :get then repository_size(env, $1)
              else not_allowed
            end

          when %r(^/repositories/([^/]+)/namespaces$)
            case method
              when :get    then repository_namespaces(env, $1)
              when :delete then repository_namespaces(env, $1)
              else not_allowed
            end

          else not_found
        end
      end

      def respond_with(body, headers = {})
        [200, {'Content-Type' => 'text/plain; charset=utf-8'}.merge(headers), body.to_s]
      end

      def bad_request(message = nil)
        http_error(400, message)
      end

      def forbidden(message = nil)
        http_error(403, message)
      end

      def not_found(message = nil)
        http_error(404, message)
      end

      def not_allowed(message = nil)
        http_error(405, message)
      end

      def not_acceptable(message = nil)
        http_error(406, message)
      end

      def unsupported_media_type(message = nil)
        http_error(415, message)
      end

      def http_error(code, message = nil)
        [code, {'Content-Type' => 'text/plain; charset=utf-8'},
          message || [code, Rack::Utils::HTTP_STATUS_CODES[code]].join(' ') << "\n"]
      end
    end # Endpoint
  end # Sesame
end # Rack
