require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "restapi_doc"
    gem.summary = %Q{REST API doc generates an easy way to create a twitter style document for your RESTful interface}
    gem.description = %Q{REST API doc generates an easy way to create a twitter style document for your RESTful interface.  
                        Leveraging Twitter Bootstrap to create an easy to read document for your RESTful api. }
    gem.email = "kevinjhaight@gmail.com"
    gem.homepage = "http://github.com/alayho/restapi_doc"
    gem.authors = ["Kevin Haight"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "restapi_doc #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end