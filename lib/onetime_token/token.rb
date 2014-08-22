module OnetimeToken
  class Token
    attr_reader :name, :secret

    class << self
      def generate_for(model, name, options={})
        redis = OnetimeToken.redis_pool

        token = nil
        while token.nil? || redis.exists(token.key)
          secret = SecureRandom.urlsafe_base64(15)
          token = new(model.class, name, secret)
        end

        properties = (options[:properties] || {})
        properties[:id] = model.id

        redis.pipelined do
          redis.set token.key, JSON.dump(properties)
          expires_in = (options[:expires_in] || 3600 * 24 * 60)
          redis.expire token.key, expires_in
        end

        token
      end
    end

    def initialize(model_class, name, secret)
      @model_class = model_class
      @name        = name
      @secret      = secret
    end

    def delete
      OnetimeToken.redis_pool.del key
    end

    def properties
      @properties ||=
        if serialized_value = OnetimeToken.redis_pool.get(key)
          JSON.parse(serialized_value, symbolize_names: true)
        else
          {}
        end
    end

    def model_id
      properties[:id]
    end

    def key
      @key ||= "#{@model_class.name.downcase}_#{@name}/#{@secret}"
    end
  end
end
