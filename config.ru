require 'bundler'
require_relative 'config/setup'

#run Garlix::App.new
puts Garlix::App.router.to_s
