ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default, ENV['RACK_ENV'])

require_relative '../lib/garlix'

Dir.glob('./app/{serializers,models,controllers}/*.rb', &method(:require))

require_relative 'routes'

