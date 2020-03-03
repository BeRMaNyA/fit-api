# frozen_string_literal: true

require "rack"
require "json/ext"
require "dry/inflector"

require "fit_api/version"
require "fit_api/router"
require "fit_api/controller"

module FitApi
  def self.builder
    @builder ||= Rack::Builder.new
  end

  def self.use(middleware, *args, &block)
    builder.use(middleware, *args, &block)
  end

  def self.app
    builder.run Router.method(:call)
    builder.to_app
  end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end
end
