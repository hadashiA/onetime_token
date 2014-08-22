require 'onetime_token/version'

require 'connection_pool'
require 'redis/namespace'

module OnetimeToken
  class << self
    def configure
      yield self
    end

    def redis_pool
      @redis
    end

    def redis=(connection_options)
      @redis =
        if connection_options.is_a?(ConnectionPool)
          connection_options
        else
          pool_options = connection_options.delete(:pool)
          pool_options.reverse_merge!(timeout: 1, size: 1)
          ConnectionPool::Wrapper.new(pool_options) do
            namespace = connection_options.delete(:namespace) || 'onetime_token'
            client = Redis.new(connection_options)
            Redis::Namespace.new(namespace, redis: client)
          end
        end
    end
  end
end
