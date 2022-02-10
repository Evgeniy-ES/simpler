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
      @type = "html" if @type.nil?
      @request_type = env['REQUEST_METHOD']
      puts("env['QUERY_STRING'] = #{env['QUERY_STRING']}")
      @request.env['simpler.params'] = find_params(env['PATH_INFO'].split('.')[0], env['QUERY_STRING'].split('.')[0])
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

    def record_params(query_string)
      params = {}
      if query_string != nil
        i=0
        query_string = query_string.split('=')
        while i < query_string.length - 1  do
          params[query_string[i]] = query_string[i+1]
          i = i + 2
      	end
      end
      params
    end

    def find_params(path, query_string)
      params = record_params(query_string)
      path = path.split('?')[0] if path.include? '?'
      path = path.split('/')

      i = 0
      hash_value =""
      path.each do |element|
        if i%1==0 && i.to_i.even?
          params[hash_value] = element if i > 0
        else
          hash_value = find_hash_value(i, element)
        end
       i = i+1
      end
      params
    end

    def find_hash_value(i, element)
      if i == 1
        'id'.to_sym
      else
        (element + "_id").to_sym
      end
    end

    def params
     @request.params.merge!(@request.env['simpler.params'])
    end

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
