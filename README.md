# OnetimeToken

Generate a temporary token of secret associated with ActiveRecord. it is stored in redis.
You will be able to verify whether the token is correct.

## Installation

Add this line to your application's Gemfile:

    gem 'onetime_token'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onetime_token

## Usage

```ruby
OnetimeToken.configure do |config|
  config.redis = {
    url: 'redis://localhost:6379'
    deiver: :redis # e.g :hireds
    pool: {
      size: 1,
      timeout: 1,
    }
  }
end
```

```ruby
class User < ActiveRecord::Base
  extend OnetimeToken

  has_onetime_token :email_confirmation, expires_in: 1.hours
end
```

```ruby
user = User.find(1)
token = user.generate_email_confirmation_token
token.secret #=> 9eyZsVbrr4jLiVcERI7V6gmo

User.find_by_email_confirmation_token('9eyZsVbrr4jLiVcERI7V6gmo')
#=> #<User id: 1>

user = User.find(1)
user.verify_email_confirmation_token('9eyZsVbrr4jLiVcERI7V6gmo')
#=> true

User.find_by_email_confirmation_token('9eyZsVbrr4jLiVcERI7V6gmo')
#=> nil
```

## Contributing

1. Fork it ( https://github.com/f-kubotar/onetime_token/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
