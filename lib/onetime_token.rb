require 'json'

require 'connection_pool'
require 'redis/namespace'

require 'onetime_token/token'
require 'onetime_token/has_token'

module OnetimeToken
  class << self
    def extended(base)
      base.extend HasToken
    end

    def configure
      yield self
    end

    def redis_pool
      @redis
    end

    def redis=(connection_options)
      @redis =
        if connection_options.is_a?(Redis) ||
            connection_options.is_a?(Redis::Namespace)
          connection_options
        else
          pool_options = {timeout: 1, size: 1}.
            merge(connection_options.delete(:pool) || {})
          ConnectionPool::Wrapper.new(pool_options) do
            namespace = connection_options.delete(:namespace) || 'onetime_token'
            client = Redis.new(connection_options)
            Redis::Namespace.new(namespace, redis: client)
          end
        end
    end
  end
end
