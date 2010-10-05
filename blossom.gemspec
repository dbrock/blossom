Gem::Specification.new do |gem|
  gem.name = 'blossom'
  gem.version = '0.0.2'
  gem.authors = ['Daniel Brockman']
  gem.email = ['daniel@brockman.se']
  gem.summary = 'Quick-start web development with Haml, Sass and Compass.'
  gem.files = ['lib/blossom.rb']
  gem.add_dependency('sinatra', '~> 1.0.0')
  gem.add_dependency('haml', '~> 3.0.0')
  gem.add_dependency('compass', '~> 0.10.0')
  gem.add_dependency('rack-strip-www', '~> 0.1.0')
  gem.add_dependency('hassle', '~> 0.0.1')
end
