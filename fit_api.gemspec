require File.expand_path("../lib/fit_api/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'fit_api'
  s.summary     = 'Lightweight framework for building APIs'
  s.description = 'fit-api is a Rack based framework for building JSON APIs'
  s.author      = 'Bernardo Castro'
  s.email       = 'bernacas@gmail.com'
  s.version     = FitApi.version
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.license     = 'MIT'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- spec/*`.split("\n")
  s.required_ruby_version = '>= 2.2.0'
  s.add_dependency 'rack', '~> 2.0'
  s.add_dependency 'dry-inflector', '~> 0.1'
end
