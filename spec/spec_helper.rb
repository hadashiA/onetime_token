require File.expand_path('../../lib/onetime_token', __FILE__)

OnetimeToken.configure do |config|
  config.redis = {
    url: 'redis://localhost:6379'
  }
end

class User
  attr_reader :id

  def self.find_by(attributes={})
    new(attributes)
  end

  def initialize(attributes={})
    @id = attributes[:id]
  end
end
