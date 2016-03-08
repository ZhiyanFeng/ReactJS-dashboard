module Rpush
  module Daemon
    module Dispatcher
      class Http
        def initialize(app, delivery_class, options = {})
          @app = app
          @delivery_class = delivery_class
          @http = Net::HTTP::Persistent.new('rpush')
        end

        def dispatch(notification, batch)
          @delivery_class.new(@app, @http, notification, batch).perform
        end

        def cleanup
          @http.shutdown
        end
      end
    end
  end
end
