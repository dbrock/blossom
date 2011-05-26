require "#{File.dirname(__FILE__)}/lib/blossom"

local_name = "blossom-#{Blossom::LOCAL_VERSION}"
global_name = "blossom-#{Blossom::VERSION}"

desc "Build and install #{local_name}."
task :install => [:build_local, :uninstall] do
  sh "sudo gem install #{local_name}.gem --local"
end

desc "Uninstall #{local_name}."
task :uninstall do
  sh "sudo gem uninstall blossom -v #{Blossom::LOCAL_VERSION} || true"
end

task :build_local do
  sh "gem build blossom-local.gemspec"
end

desc "Build and release #{global_name}."
task :release => [:build] do
  sh "gem push #{global_name}.gem"
end

task :build do
  sh "gem build blossom.gemspec"
end
