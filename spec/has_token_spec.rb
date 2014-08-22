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

  describe 'Model#verify_:name_token' do
    let(:token) do
      user.generate_email_confirmation_token
    end

    context 'valid token secret' do
      let(:secret) do
        token.secret
      end

      it "should be true" do
        expect(user.verify_email_confirmation_token secret).to be_truthy
      end

      it "should expire stored data" do
        expect {
          user.verify_email_confirmation_token secret
        }.to change{ OnetimeToken.redis_pool.get token.key }.to(nil)
      end
    end

    context 'invalid token secret' do
      let(:secret) do
        'soaieowao'
      end

      it "should be false" do
        expect(user.verify_email_confirmation_token secret).to be_falsey
      end

      it "should expire stored data" do
        expect {
          user.verify_email_confirmation_token secret
        }.to_not change{ OnetimeToken.redis_pool.get token.key }
      end
    end
  end
end
