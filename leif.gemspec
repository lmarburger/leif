lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'leif/version'

Gem::Specification.new do |spec|
  spec.name        = 'leif'
  spec.version     = Leif::VERSION
  spec.summary     = 'Explore the CloudApp API'
  spec.description = 'A hypermedia browser for the CloudApp Collection+JSON API.'
  spec.authors     = ['Larry Marburger']
  spec.email       = 'larry@marburger.cc'
  spec.homepage    = 'https://github.com/cloudapp/leif'
  spec.licenses    = ['MIT']

  spec.add_dependency 'faraday',            '~> 0.8.8'
  spec.add_dependency 'faraday_middleware', '~> 0.9.0'
  spec.add_dependency 'highline',           '~> 1.6.19'
  spec.add_development_dependency 'ronn'

  spec.bindir      = 'bin'
  spec.executables = ['leif']

  spec.files =  %w(LICENSE README.md leif.gemspec)
  spec.files += Dir.glob('bin/*')
  spec.files += Dir.glob('lib/**/*.rb')
  spec.files += Dir.glob('man/*')

  spec.required_rubygems_version = '>= 1.3.6'
end
