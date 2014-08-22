require File.expand_path('../../lib/onetime_token', __FILE__)

OnetimeToken.configure do |config|
  config.redis = {
    url: 'redis://localhost:6379'
  }
end
