require "rubygems"

local = Gem::Specification.load("blossom-local.gemspec")
release = Gem::Specification.load("blossom.gemspec")

desc "Build and install #{local.full_name}."
task "install" => ["build-local", "uninstall"] do
  sh "sudo gem install #{local.file_name} --local"
end

desc "Uninstall #{local.full_name}."
task "uninstall" do
  sh "sudo gem uninstall blossom -v #{local.version} || true"
end

task "build-local" do
  sh "gem build blossom-local.gemspec"
end

desc "Build and release #{release.full_name}."
task "release" => ["build-release"] do
  sh "gem push #{release.file_name}"
end

task "build-release" do
  sh "gem build blossom.gemspec"
end

desc "Remove all *.gem files."
task "clean" do
  sh "rm *.gem"
end
