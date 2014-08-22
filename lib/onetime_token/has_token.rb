module OnetimeToken
  module HasToken
    def has_onetime_token(name, options={})
      define_singleton_method :"find_by_#{name}_token" do |secret|
        token = Token.new(self, name, secret)
        if stored_model_id = token.model_id
          find_by(id: stored_model_id)
        end
      end

      define_method :"generate_#{name}_token" do |_options={}|
        Token.generate_for self, name, _options
      end

      define_method :"#{name}_token_properties" do |secret|
        token = Token.new(self.class, name, secret)
        token.properties
      end

      define_method(:"verify_#{name}_token") do |secret|
        token = Token.new(self.class, name, secret)
        if id && id == token.model_id
          token.expire
          true
        else
          false
        end
      end
    end
  end
end
