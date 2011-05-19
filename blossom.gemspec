require "#{File.dirname(__FILE__)}/lib/blossom"

Gem::Specification.new do |gem|
  gem.name = 'blossom'
  gem.version = Blossom::VERSION
  gem.authors = ['Daniel Brockman']
  gem.email = ['daniel@gointeractive.se']
  gem.summary = 'Quick-start web development with Haml, Sass and Compass.'
  gem.homepage = 'http://github.com/dbrock/blossom'
  gem.files = ['lib/blossom.rb', 'bin/blossom']
  gem.executables = ['blossom']
  gem.add_dependency('sinatra', '~> 1.0')
  gem.add_dependency('haml', '~> 3.0')
  gem.add_dependency('compass', '~> 0.10')
  gem.add_dependency('rack-strip-www', '~> 0.2')
  gem.add_dependency('hassle')
end
