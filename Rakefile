require "#{File.dirname(__FILE__)}/lib/blossom"

task :build do
  sh "gem build blossom.gemspec"
end

task :uninstall do
  sh "sudo gem uninstall blossom -v #{Blossom::VERSION} || true"
end

task :install => [:build, :uninstall] do
  sh "sudo gem install blossom-#{Blossom::VERSION}.gem --local"
end
