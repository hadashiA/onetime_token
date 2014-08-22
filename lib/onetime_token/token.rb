module OnetimeToken
  class Token
    attr_reader :name, :secret

    class << self
      def generate_for(model, name, options={})
        token = nil
        while token.nil? || redis.exists(token.key)
          secret = SecureRandom.urlsafe_base64(15)
          token = new(model_class, name, secret)
        end

        properties = (options[:properties] || {})
        properties[:id] = model.id

        redis.pipelined do
          redis.set token.key, JSON.dump(properties)
          expires_in = (options[:expires_in] || 2.months)
          redis.expire token.key, expires_in
        end
      end
    end

    def initialize(model_class, name, secret)
      @model_class = model_class
      @name        = name
      @secret      = secret
    end

    def delete
      redis_pool.del key
    end

    def fetch_model_id
      fetch_properties[:id]
    end

    private

    def key
      @key ||= "#{@model_class.model_name.plural}/#{@name}/#{@secret}"
    end

    def fetch_properties
      @properties ||=
        if serialized_value = redis_pool.get(key)
          JSON.parse(serialized_value, symbolize_names: true)
        else
          {}
        end
    end
  end
end
