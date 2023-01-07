# requires gems: dalli, connection_pool
#
# MEMCACHE_SERVERS can be either
#   server1:11211,server2
# or
#   memcached://user:pass@server1:11211,...
# default: localhost:11211


require 'active_support/cache/mem_cache_store'

module ActiveSupport
  module Cache
    class SmartMemCache < MemCacheStore

      # known options:
      #   ActiveSupport::Cache - universal options
      #     :namespace{nil}, :compress{true}, :compress_threshold{1k}, :expires_in{0}, :race_condition_ttl{0}
      #   ActiveSupport::Cache::Store
      #     :pool{5}, :pool_timeout{5}
      #   Dalli::Client
      #     :failover{true}, :serializer{Marshall}, :compressor{zlib}, :cache_nils{false}
      #     :namespace{nil}, :expires_in{0}, :compress{false} (separate from AS::C's same options above)
      #     :threadsafe{true} (using ConnPool turns this off automatically)
      def initialize(*addresses, **args)
        args.reverse_merge!(
          namespace:          ENV['MEMCACHE_NAMESPACE'],
          expires_in:         1.day,
          race_condition_ttl: 5.seconds,
          failover:           true,
          pool:               ENV.fetch('RAILS_MAX_THREADS'){ 5 }.to_i,
        )
        args.reverse_merge!(pool_size: args.delete(:pool)) if ActiveSupport.version < '7.1.0.a'
        addresses.push Array(args.delete(:url)) if addresses.empty? && args.key?(:url)
        super(*addresses, args)
      end


      if ActiveSupport.version < '7.1.0.a'
        # MemCacheStore#increment docs say it will init any invalid value to 0.
        # In reality, it will only increment a pre-existing, raw value. everything else returns nil or an error.
        # This fixes init of missing value on both increment() and decrement().
        # Preexisting, invalid values still return errors.

        def increment(name, amount = 1, options = nil)
          options = merged_options(options)
          instrument(:increment, name, amount: amount) do
            rescue_error_with nil do
              @data.then { |c| c.incr(normalize_key(name, options), amount, options[:expires_in], amount) }
            end
          end
        end

        def decrement(name, amount = 1, options = nil)
          options = merged_options(options)
          instrument(:decrement, name, amount: amount) do
            rescue_error_with nil do
              @data.then { |c| c.decr(normalize_key(name, options), amount, options[:expires_in], 0) }
            end
          end
        end

      end

    end
  end
end
