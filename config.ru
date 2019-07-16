require 'byebug'

require_relative 'lib/garlix'
require_relative 'config/routes'

puts Garlix::App.router.to_s
