require 'spec_helper'

class User
  extend OnetimeToken

  attr_reader :id

  has_onetime_token :email_confirmation
  has_onetime_token :alter_email, expires_in: 60

  def self.find_by(attributes)
    new attributes
  end

  def initialize(attributes={})
    @id = attributes[:id]
  end
end

describe OnetimeToken::HasToken do
  after do
    OnetimeToken.redis_pool.keys.each{|key| OnetimeToken.redis_pool.del key }
  end

  let(:user) do
    User.new(id: 101)
  end

  describe '.has_onetime_token' do
    it 'specified expiration date' do
      token = user.generate_alter_email_token(properties: {email: 'hoge@example.com'})
      expect(token.properties[:email]).to eq('hoge@example.com')
    end
  end

  describe 'Model.find_by_:name_token' do
    let(:token) do
      user.generate_email_confirmation_token
    end

    it "should find by sotred model id" do
      expect(User).to receive(:find_by).with(id: user.id)
      User.find_by_email_confirmation_token(token.secret)
    end
  end

  describe 'Model.expire_:name_token' do
    let(:token) do
      user.generate_email_confirmation_token
    end

    it "should delete sotred data" do
      expect {
        User.expire_email_confirmation_token(token.secret)
      }.to change{ OnetimeToken.redis_pool.get(token.key) }.to(nil)
    end
  end

  describe 'Model#verify_:name_token' do
    let(:token) do
      user.generate_email_confirmation_token
    end

    it "should veirfy token" do
      expect(user.verify_email_confirmation_token token.secret).to be_truthy
    end

    it 'should not verify invalid secret' do
      expect(user.verify_email_confirmation_token 'owaieowaoiaowwo').to be_falsey
    end
  end
end
