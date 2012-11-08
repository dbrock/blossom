require 'rubygems'

gemspec = Gem::Specification.load('blossom.gemspec')

task 'default' => 'install'

task 'build' do
  sh 'gem build blossom.gemspec'
end

desc "Build and install #{gemspec.full_name}."
task 'install' => ['build', 'uninstall'] do
  sh "sudo gem install #{gemspec.file_name} --local"
end

desc "Uninstall #{gemspec.full_name}."
task 'uninstall' do
  sh "sudo gem uninstall blossom -v #{gemspec.version} || true"
end

desc "Build and release #{gemspec.full_name}."
task 'release' => ['build'] do
  sh "gem push #{gemspec.file_name}"
end

desc 'Remove all *.gem files.'
task 'clean' do
  sh 'rm *.gem'
end
