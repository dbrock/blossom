Gem::Specification.new do |gem|
  gem.name = "blossom"
  gem.version = "1.0.0alpha4"
  gem.author = "Daniel Brockman"
  gem.email = "daniel@gointeractive.se"
  gem.summary = "Quick-start web development with Haml, Sass and Compass."
  gem.homepage = "http://github.com/dbrock/blossom"
  gem.executable = "blossom"
  gem.files = ["lib/blossom.rb", "bin/blossom"]
  gem.add_dependency("sinatra", "~> 1.0")
  gem.add_dependency("haml", "~> 3.0")
  gem.add_dependency("compass", "~> 0.10")
  gem.add_dependency("rack-normalize-domain", "~> 0.0.1")
  gem.add_dependency("hassle", "~> 0.0.1")
end
