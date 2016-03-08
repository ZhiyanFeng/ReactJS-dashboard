module Rpush
  module Daemon
    class Feeder
      extend Reflectable

      def self.start
        @stop = false

        if Rpush.config.embedded
          Thread.new { feed_forever }
        elsif Rpush.config.push
          enqueue_notifications
        else
          feed_forever
        end
      end

      def self.stop
        @stop = true
        interrupt_sleep
      end

      def self.interrupt_sleep
        interruptible_sleeper.interrupt_sleep
      end

      protected

      def self.feed_forever
        loop do
          enqueue_notifications
          interruptible_sleeper.sleep(Rpush.config.push_poll)
          break if stop?
        end

        Rpush::Daemon.store.release_connection
      end

      # :nocov:
      def self.stop?
        @stop
      end

      def self.enqueue_notifications
        begin
          idle = Rpush::Daemon::AppRunner.idle.map(&:app)
          return if idle.empty?
          notifications = Rpush::Daemon.store.deliverable_notifications(idle)
          Rpush::Daemon::AppRunner.enqueue(notifications)
        rescue StandardError => e
          Rpush.logger.error(e)
          reflect(:error, e)
        end
      end

      def self.interruptible_sleeper
        return @interruptible_sleeper if @interruptible_sleeper

        @interruptible_sleeper = InterruptibleSleep.new
        if Rpush.config.wakeup
          @interruptible_sleeper.enable_wake_on_udp Rpush.config.wakeup[:bind], Rpush.config.wakeup[:port]
        end

        @interruptible_sleeper
      end
    end
  end
end
