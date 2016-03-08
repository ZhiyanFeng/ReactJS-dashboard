class PGError < StandardError; end if !defined?(PGError)
class Mysql; class Error < StandardError; end; end if !defined?(Mysql)
module Mysql2; class Error < StandardError; end; end if !defined?(Mysql2)
module ActiveRecord; end
class ActiveRecord::JDBCError < StandardError; end if !defined?(::ActiveRecord::JDBCError)

# :nocov:
if !defined?(::SQLite3::Exception)
  module SQLite3
    class Exception < StandardError; end
  end
end

module Rpush
  module Daemon
    module Store
      class ActiveRecord
        module Reconnectable
          ADAPTER_ERRORS = [::ActiveRecord::StatementInvalid, PGError, Mysql::Error,
                            Mysql2::Error, ::ActiveRecord::JDBCError, SQLite3::Exception]

          def with_database_reconnect_and_retry
            begin
              ::ActiveRecord::Base.connection_pool.with_connection do
                yield
              end
            rescue *ADAPTER_ERRORS => e
              Rpush.logger.error(e)
              database_connection_lost
              retry
            end
          end

          def database_connection_lost
            Rpush.logger.warn("Lost connection to database, reconnecting...")
            attempts = 0
            loop do
              begin
                Rpush.logger.warn("Attempt #{attempts += 1}")
                reconnect_database
                check_database_is_connected
                break
              rescue *ADAPTER_ERRORS => e
                Rpush.logger.error(e)
                sleep_to_avoid_thrashing
              end
            end
            Rpush.logger.warn("Database reconnected")
          end

          def reconnect_database
            ::ActiveRecord::Base.clear_all_connections!
            ::ActiveRecord::Base.establish_connection
          end

          def check_database_is_connected
            # Simply asking the adapter for the connection state is not sufficient.
            Rpush::Notification.count
          end

          def sleep_to_avoid_thrashing
            sleep 2
          end
        end
      end
    end
  end
end
