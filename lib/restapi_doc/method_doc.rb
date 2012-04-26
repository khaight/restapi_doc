# encoding: utf-8
module RestApiDoc
  class MethodDoc
    attr_accessor :scope, :method_order, :content, :request, :response, :output, :params, :defname, :response_formats, :requires_authentication, :request_url,  :account_password_required, :http_responses
    
    def initialize(resource_name, type, order)
      @resource_name = resource_name
      @scope = type
      @method_order = order
      @content = ""
      @request = ""
      @response = ""
      @output = ""
      @params = []
      @response_formats = []
      @http_responses= []
      @requires_authentication = "No"
      @account_password_required = "No"
      @defname = nil
      @request_url = nil
    end

    def process_line(line, current_scope)
      new_scope = current_scope
      case current_scope
      when :response
        if line =~ /::response-end::/
          new_scope = :function
        else
          @response << line
        end
      when :request
        if line =~ /::request-end::/
          new_scope = :function
        else
          @request << line
        end
      when :output # append output
        if line =~ /::output-end::/
          new_scope = :function
        else
          @output << line
        end
      when :class, :function
        result = line.scan(/(\w+)\:\:\s*(.+)/)
        if not result.empty?
          key, value = result[0]
          case key
          when "response", "request"
            new_scope = key.to_sym
          when "output"
            new_scope = key.to_sym
          when "param"
            @params << value
          when "http_response"
            @http_responses << value
          when "response_format"
            @response_formats << value
          when "requires_authentication"
            @requires_authentication = value
          when "request_url"
            @request_url = value
          when "account_password_required"
            @account_password_required = value
          else # user wants this new shiny variable whose name is the key with value = value
            instance_variable_set("@#{key}".to_sym, value)
            define_singleton_method(key.to_sym) { value } # define accessor for the templates to read it
          end
        else
          # add line to block
          @content << line
        end
      else
        raise ParsingException, "logic error: unknown current scope #{current_scope}"
      end
      new_scope
    end

    def get_binding
      binding
    end

  end
end