# encoding: utf-8
module RestApiDoc
  module Config
    def template_dir(f = nil)
      @template_dir ||= File.join(File.dirname(__FILE__), 'template')
      form_file_name @template_dir, f
    end
    
    def config_template_dir(f = nil)
      @template_dir ||= File.join(File.dirname(__FILE__), 'config')
      form_file_name @template_dir, f
    end
    
    def asset_dir
      @asset_dir ||= File.join(File.dirname(__FILE__), 'template/assets')
    end

    def config_dir(f = nil)
      @config_dir ||= File.join(::Rails.root.to_s, 'config/restapi_doc')
      form_file_name @config_dir, f
    end

    def target_dir(f = nil)
      @target_dir ||= File.join(::Rails.root.to_s, 'public/apidoc/')
      form_file_name @target_dir, f 
    end

    def controller_dir(f = nil)
      @controller_dir ||= File.join(::Rails.root.to_s, 'app/controllers/')
      form_file_name @controller_dir, f
    end

    def temp_dir(f = nil)
      @temp_dir ||= "#{Dir.mktmpdir("apidoc")}/"
      form_file_name @temp_dir, f
    end

    def form_file_name(dir, file)
      case file
      when NilClass then dir
      when String then File.join(dir, file)
      else raise ArgumentError, "Invalid argument #{file}"
      end
    end
  end
end