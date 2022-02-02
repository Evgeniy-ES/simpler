require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :type
    HASH_TYPE = {'text' => 'text/plain', 'html' => 'text/html'}

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @type = env['PATH_INFO'].split('.')[1]
      @request_type = env['REQUEST_METHOD']
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response(action)

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = HASH_TYPE[@type]
    end

    def write_response(action)
      body = render_body(action)

      @response.write(body)
    end

    def render_body(action)
      find_status(action)
      View.new(@request.env).render(binding)
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

    def find_status(action)
      if action == "not_found_page"
        @response.status = 404
      else
        puts("@request_type = #{@request_type}")
        @response.status = 201 if @request_type == "POST"
      end
    end

  end
end
