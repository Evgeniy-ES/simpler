module Simpler
  class Router
    class Route

      attr_reader :controller, :action
      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
      end

      def match?(method, path)
        path = find_path(path.split('.')[0].split('/'))
        @method == method && path.match(@path)
      end

      def find_path_need(i, path_need, element_old)
        if i == 2
          path_need + "/:id"
        else
          path_need + "/:" + element_old + "_id"
        end
      end

      def find_path(path)
        path = path.split('?')[0] if path.include? '?'
        path_need = ""
        element_old = ""
        for i in 1..path.length - 1 do
          element = path[i]
          if i%1==0 && i.to_i.even?
            path_need = find_path_need(i, path_need, element_old)
          else
            path_need = path_need + "/" + element
            element_old = element
          end
        end
        path_need
      end

    end
  end
end
