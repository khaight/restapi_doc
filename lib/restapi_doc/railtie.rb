# encoding: utf-8
require 'rails'
module RestApiDoc
  class Railtie < Rails::Railtie
    rake_tasks do
      puts "RAKE TASK"
      load 'restapi_doc/tasks/restapi_doc_tasks.rake'
    end
  end
end