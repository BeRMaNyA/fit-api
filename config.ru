require_relative 'config/setup'
require_relative 'config/routes'

logger = Logger.new('log/app.log')
use Rack::CommonLogger, logger

run Garlix::App.new
