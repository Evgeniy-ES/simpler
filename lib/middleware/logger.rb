require 'logger'

class AppLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:logved] || STDOUT)
    @app = app
  end

  def call(env)
   status, headers, response = @app.call(env)
   @logger.info(record_log(status, headers, env))
   [status, headers, response]
  end

  def record_log(status, headers, env)
    type_and_path = 'Request: ' + env['REQUEST_METHOD'] + " " + env['REQUEST_URI'] + "\n"
    controller_name = "Handler: " + env['PATH_INFO'].split('.')[0].split('/')[1].capitalize +
      "Controller" + "#" + env['simpler.action'] + "\n"
    params = "Params: " + env['simpler.params'].to_s + "\n"
    type = env['REQUEST_URI'].split('.')[1]
    type = "html" if type.nil?
    response_s = "Response: " + status.to_s + " " + headers['Content-Type']  + " " + env['PATH_INFO'] + "/" +
    env['simpler.action'] + "." + type + ".erb"
    type_and_path + controller_name + params + response_s
  end
end
