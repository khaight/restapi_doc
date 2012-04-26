# encoding: utf-8
require_relative 'method_doc'

module RestApiDoc
  class ParsingException < Exception;
  end
  class ResourceDoc

    attr_reader :name, :resource_location, :controller_name, :class_block, :function_blocks, :resource_header, :resource_methods, :description

    # Initializes ResourceDoc.
    def initialize(name, action_methods, controller_location, options = {})
      @name = name
      @class_block = nil
      @function_blocks = []
      @resource_methods = action_methods
      @resource_header = ""
      @standard_methods = options[:standard_methods] || [:put, :post, :get, :delete]
      @resource_location = resource_location
      @controller_location = controller_location
      @description = nil
      @controller_name = File.basename(controller_location)
    end

    # parse the controller
    def parse_apidoc!(class_template, method_template)
      lines = IO.readlines(@controller_location)
      begin
        @class_block, @function_blocks = ResourceDoc.parse_controller_doc(@name, lines)
      rescue ParsingException => ex
        puts "error #{ex} while parsing #{@controller_location}"
        exit
      end
      if !@class_block.nil?
        @description = @class_block.content
      end
      
      @resource_methods.each do | req_m |
          req_m << @function_blocks.select{|f| f.defname == req_m[0]}.first
      end
    end

    # This method parses the doc
    def self.parse_controller_doc(name, lines)
      current_api_block = nil
      current_scope = :none
      in_class = false
      class_block = nil
      function_blocks = []
      order = 1
      lines.each_with_index do |line, line_no|
        line.gsub!(/^ *#/, '') # strip the starting '#' on the line
        case line
          when /=begin apidoc/
            # if we get apidoc tag inside class definition, then they are for a method
            current_scope = !in_class ? :class : :function
            current_api_block = MethodDoc.new(name, current_scope, order)
          when /=end/
            if current_api_block.nil?
              raise ParsingException, "#{line_no} - No starttag for '=end' found"
            end
          when /class/ # keep track of whether a resource or an api is being annotated
            in_class = true
            if !current_api_block.nil?
            case current_scope
              when :class
                class_block = current_api_block
              when :function
                function_blocks << current_api_block
              else
                raise ParsingException, "logic error: unknown current scope #{current_scope}"
            end
            
            current_api_block = nil
            current_scope = :none
            order += 1
          end
          when /def/
            if !current_api_block.nil?
              current_api_block.defname = line.gsub('def ', '').strip
              
              case current_scope
                when :class
                  class_block = current_api_block
                when :function
                  function_blocks << current_api_block
                else
                  raise ParsingException, "logic error: unknown current scope #{current_scope}"
              end
              
              current_api_block = nil
              current_scope = :none
              order += 1
            end
          else
            if current_api_block # process lines only if they are apidoc comments
              current_scope = current_api_block.process_line(line, current_scope)
            end
        end
      end
      [class_block, function_blocks]
    end
  end
end