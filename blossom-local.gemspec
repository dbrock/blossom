require "rubygems"

spec = Gem::Specification.load("blossom.gemspec")
spec.version = "#{spec.version}.99.local"
spec
