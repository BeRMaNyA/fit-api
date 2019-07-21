require 'rack'
require 'json/ext'
require 'dry/inflector'

require 'fit_api'
require 'fit_api/app'
require 'fit_api/controller'

module FitApi
  class Halt < StandardError; end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end
end
