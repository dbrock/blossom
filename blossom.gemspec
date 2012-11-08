Gem::Specification.new do |gem|
  gem.name = "blossom"
  gem.version = "0.1.4"
  gem.author = "Daniel Brockman"
  gem.email = "daniel@gointeractive.se"
  gem.summary = "Quick-start web development with Haml, Sass and Compass."
  gem.homepage = "http://github.com/dbrock/blossom"
  gem.executable = "blossom"
  gem.add_dependency("sinatra", "~> 1.0")
  gem.add_dependency("sass", "~> 3.1.1")
  gem.add_dependency("haml", "~> 3.1.1")
  gem.add_dependency("compass", "~> 0.10")
  gem.files = %w[bin/blossom lib/blossom.rb]
  gem.add_dependency("rack-normalize-domain", "~> 0.0.1")
end
