require 'json/ext'
require 'dry/inflector'

require_relative 'garlix/app'
require_relative 'garlix/controller'

module Garlix
  class Halt < StandardError; end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end
end
