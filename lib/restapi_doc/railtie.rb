# encoding: utf-8
require 'rails'
module RestApiDoc
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'restapi_doc/tasks/restapi_doc_tasks.rake'
    end
  end
end