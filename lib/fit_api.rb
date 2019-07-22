require 'rack'
require 'json/ext'
require 'dry/inflector'

require 'fit_api/app'
require 'fit_api/controller'

module FitApi
  def self.inflector
    @inflector ||= Dry::Inflector.new
  end
end
