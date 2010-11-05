require 'rack' # @see http://rubygems.org/gems/rack
require 'rdf'  # @see http://rubygems.org/gems/rdf
require 'json' # @see http://rubygems.org/gems/json_pure

module Rack
  module Sesame
    autoload :Endpoint, 'rack/sesame/endpoint'
    autoload :Proxy,    'rack/sesame/proxy'
    autoload :VERSION,  'rack/sesame/version'
  end
end
