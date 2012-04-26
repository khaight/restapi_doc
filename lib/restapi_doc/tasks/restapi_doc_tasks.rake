# encoding: utf-8
include RestApiDoc

namespace :restapi_doc do

  desc "Generate the config files"
  task :setup do
    create_structure
  end

  desc "Generate the api documentation"
  task :generate do
    remove_structure
    resources = get_resources do |controller, controller_url, controller_location|
    end
    if !resources.empty?
      puts "Generating API documentation..."
      generate_doc(resources)
      move_document
      puts "Completed API documentation generation"
    end
  end
  
  desc "Generate the config files"
  task :clean do
    remove_structure
  end
end