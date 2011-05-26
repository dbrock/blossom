require "rubygems"

spec = Gem::Specification.load("blossom.gemspec")
spec.version = Blossom::LOCAL_VERSION
spec
