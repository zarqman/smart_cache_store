# requires gems: redis, connection_pool
#
# REDIS_URL (or :url) can have one or multiple urls:
#   redis://localhost:1234
#   redis://host-a,redis://host-b   # automatically uses Redis::Distributed


require 'active_support/cache/redis_cache_store'

module ActiveSupport
  module Cache
    class SmartRedisCache < RedisCacheStore

      # known options:
      #   ActiveSupport::Cache - universal options
      #     :namespace{nil}, :compress{true}, :compress_threshold{1k}, :coder, :expires_in{0}
      #     :race_condition_ttl{0}, :skip_nil{false}
      #   ActiveSupport::Cache::Store
      #     pool: {:size{5}, :timeout{5}}
      #   ActiveSupport::Cache::RedisCacheStore
      #     :error_handler
      #   Redis
      #     :host, :port, :db, :username, :password, :url, :path
      #     ssl_params: {:ca_file, :cert, :key}
      #     :sentinels, :role
      #     :replica
      #     :timeout (sets next 3), :connect_timeout, :read_timeout, :write_timeout
      #     :reconnect_attempts
      def initialize(**args)
        args.reverse_merge!(
          namespace:          ENV['REDIS_NAMESPACE'],
          expires_in:         1.day,
          race_condition_ttl: 5.seconds,
          connect_timeout:    2,
          read_timeout:       1,
          write_timeout:      1,
        )
        if ActiveSupport.version >= '7.1.0.a'
          args[:pool] ||= {}
          args[:pool][:size] ||= Integer(ENV.fetch('RAILS_MAX_THREADS'){ 5 })
        else
          args[:pool_size] ||= Integer(ENV.fetch('RAILS_MAX_THREADS'){ 5 })
        end
        if Redis::VERSION >= '5'
          args.reverse_merge!(
            # when an array, contains delay for each reconnect attempt
            reconnect_attempts: [0.2]
          )
        else
          args.reverse_merge!(
            reconnect_attempts: 1,
            reconnect_delay:    0.2,
          )
        end
        args[:url] ||= ENV['REDIS_URL'] unless args.key?(:redis) || args.key?(:url)
        args[:url] = args[:url].split(',') if args[:url].is_a?(String)
        super(**args)
      end

    end
  end
end
