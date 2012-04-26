# encoding: utf-8
require 'haml'
require 'yaml'
require 'fileutils'
require File.expand_path('../restapi_doc/resource_doc', __FILE__)
require File.expand_path('../restapi_doc/config', __FILE__)
require File.expand_path('../restapi_doc/railtie', __FILE__) if defined?(Rails)

module RestApiDoc
  VERSION = File.read(File.expand_path("../VERSION", File.dirname(__FILE__)))
  
  include Config
  include FileUtils
  
  def create_structure
    File.directory?(config_dir) || mkdir(config_dir)
    Dir["#{config_template_dir}/*.*"].each do |template_file|
      target_file = config_dir(File.basename(template_file))
      cp template_file, config_dir if not File.exist? target_file
    end
  end
      
  # Reads 'rake routes' output and gets the controller info
  def get_controller_info
    controller_info = {}
    routes = Dir.chdir(::Rails.root.to_s) { `rake routes` }
    routes.split("\n").each do |entry|
      method, url, controller_action = entry.split.slice(-3, 3)
      controller, action = controller_action.split('#')
      controller_info[controller] ||= []
      controller_info[controller] << [action, method, url]
    end
    controller_info
  end
  
  # Create resources
  def get_resources
    controller_info = get_controller_info
    resources = []
    controller_info.each do |controller, action_entries|
      controller_location = controller_dir(controller + '_controller.rb')
      controller_base_routes = action_entries
      resources << ResourceDoc.new(controller, action_entries, controller_location)
    end
    resources
  end
  
  # Generates views and their index in a temp directory
  def generate_doc(resource_docs)
    generate_index_templates(resource_docs)
    copy_assets!
  end
  
  # Creates index template for all resources
  def generate_index_templates(resource_docs)
    restapi_config = YAML.load(File.read("#{config_dir}/restapi_doc.yml"))
    resource_docs.each { |resource| resource.parse_apidoc }
    template = IO.read(template_dir('index.html.haml'))
    parsed = Haml::Engine.new(template).render(Object.new, :project_info => restapi_config, :resource_docs => resource_docs)
    File.open(temp_dir("index.html"), 'w') { |file| file.write parsed }
    
    # Generate detail files
    resource_docs.each do | resource_doc|
     generate_resource_detail_file!(resource_doc)
    end
  end
  
  # Generate detail files for resource method
  def generate_resource_detail_file!(resource_doc)
    restapi_config = YAML.load(File.read("#{config_dir}/restapi_doc.yml"))
    Dir.mkdir(temp_dir + "/resources") if (!File.directory?(temp_dir + "/resources"))
    Dir.mkdir(temp_dir + "/resources/" + resource_doc.name) if (!File.directory?(temp_dir + "/resources/" + resource_doc.name))
    resource_doc.resource_methods.each do | method|
      template = IO.read(template_dir('detail.html.haml'))
      parsed = Haml::Engine.new(template).render(Object.new, :project_info => restapi_config, :name => resource_doc.name , :rmethod => method)
      File.open(temp_dir + "/resources/" + resource_doc.name + "/" + method[0] + ".html", 'w') { |file| file.write parsed }
    end
  end
  
  # Move document to public
  def move_document
    Dir.mkdir(target_dir) if (!File.directory?(target_dir))
    # Only want to move the .html, .css, .png and .js files, not the .haml templates.
    html_css_files = temp_dir("*.{html,css,js,png}")
    Dir[html_css_files].each { |f| mv f, target_dir }
    mv temp_dir + "/resources", target_dir, :force => true if (File.directory?(temp_dir + "/resources"))
    mv temp_dir + "/assets", target_dir, :force => true if (File.directory?(temp_dir + "/assets"))
  end
  
  def copy_assets!
    # Copy over assets
    cp_r asset_dir, temp_dir
  end
  
  # Removes the generated files
  def remove_structure
    rm_rf target_dir
  end
end