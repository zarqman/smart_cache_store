# SmartCacheStore

SmartCacheStore provides variations on ActiveSupport's MemCacheStore and RedisCacheStore to make the default configurations more production ready. It does this by setting better defaults and using a few more ENVs.


##### Redis -- SmartRedisCache

Set by default:

    url:                ENV['REDIS_URL']
    namespace:          ENV['REDIS_NAMESPACE']
    expires_in:         1.day
    race_condition_ttl: 5.seconds
    pool_size:          ENV['RAILS_MAX_THREADS'] || 5
    connect_timeout:    2
    read_timeout:       1
    write_timeout:      1
    reconnect_attempts: 1
    reconnect_delay:    0.2

`:url` should be a uri, like: `redis://localhost:6379/0`. For two or more uris, combine with a comma: `redis://host-a,redis://host-b`.

Any of these may still be specified directly, as well as all other support parameters for RedisCacheStore or the Redis gem.


##### Memcache -- SmartMemCache

Set by default:

    url:                ENV['MEMCACHE_SERVERS']
    namespace:          ENV['MEMCACHE_NAMESPACE']
    expires_in:         1.day
    race_condition_ttl: 5.seconds
    failover:           true
    pool_size:          ENV['RAILS_MAX_THREADS'] || 5

MemCacheStore's legacy initializer with `*addresses` as the first parameter, and the RedisCacheStore compatible `:url` are supported.

`:url` or *addresses should be a uri, like: `memcached://localhost:11211`. For two or more uris, combine with a comma: `memcached://host-a,memcached://host-b`.


### Other features

SmartMemCache's increment() and decrement() are also enhanced to be able to act on previously unset keys.


## Usage

In `environment/[env].rb`:

#### Redis

    # basic:
    config.cache_store = :smart_redis_cache
    # with parameters:
    config.cache_store = :smart_redis_cache, {url: 'redis://localhost:1234/9'}

#### Memcache

    # basic:
    config.cache_store = :smart_mem_cache
    # with parameters:
    config.cache_store = :smart_mem_cache, 'memcached://localhost:1234'
    config.cache_store = :smart_mem_cache, 'memcached://localhost:1234', {expires_in: 1.hour}
    config.cache_store = :smart_mem_cache, {url: 'memcached://localhost:1234', expires_in: 1.hour}



## Installation
Add this line to your application's Gemfile:

```ruby
gem "smart_cache_store"
```

And then execute:
```bash
$ bundle
```


## Contributing

1. Fork it ( https://github.com/zarqman/smart_cache_store/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
