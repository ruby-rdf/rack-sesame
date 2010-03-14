require 'rack'
require 'rdf'

module Rack
  module Sesame
    autoload :Endpoint, 'rack/sesame/endpoint'
    autoload :VERSION,  'rack/sesame/version'
  end
end
