require 'spec_helper'

describe OnetimeToken::Token do
  after do
    OnetimeToken.redis_pool.keys.each{|key| OnetimeToken.redis_pool.del(key) }
  end

  let(:user) do
    double :user, id: 101
  end

  describe '.generate_for' do
    let(:token) do
       OnetimeToken::Token.generate_for(user, :email_confirmation)
    end

    it "should return secret string" do
      expect(token.secret.length).to be <= 20
    end

    it "should save to redis a secret string" do
      expect(OnetimeToken.redis_pool.get token.key).to_not be_nil
    end

    it "should expires in 2 months after" do
      expect(OnetimeToken.redis_pool.ttl token.key).to eq(3600 * 24 * 60)
    end

    context 'specified expiration date' do
      let(:token) do
        OnetimeToken::Token.generate_for(user, :email_confirmation, expires_in: 60)
      end

      it "expires in specify date after" do
        expect(OnetimeToken.redis_pool.ttl token.key).to eq(60)
      end
    end
  end

  describe '#key' do
    let(:token) do
      OnetimeToken::Token.generate_for(user, :email_confirmation)
    end

    it "should containg token name and secret" do
      expect(token.key).to be_include(token.secret)
      expect(token.key).to be_include('email_confirmation')
    end
  end

  describe '#delete' do
    let(:token) do
      OnetimeToken::Token.generate_for(user, :email_confirmation)
    end

    it "should remove stored data" do
      expect {
        token.delete
      }.to change{ OnetimeToken.redis_pool.get(token.key) }.to(nil)
    end
  end

  describe '#model_id' do
    let(:token) do
      OnetimeToken::Token.generate_for(user, :email_confirmation)
    end

    it "should fetch model the specified id" do
      expect(token.model_id).to eq(user.id)
    end
  end

  describe '#properties' do
    let(:token) do
      OnetimeToken::Token.generate_for(user, :email_confirmation)
    end

    it "should fetch model the specified id" do
      expect(token.properties).to eq(id: user.id)
    end

    context 'sotre properties' do
      let(:token) do
        OnetimeToken::Token.generate_for(user, :alter_email,
          properties: { alter_email: 'hoge@example.com' })
      end

      it "should fetch properteis" do
        expect(token.properties).to eq(id: user.id, alter_email: 'hoge@example.com')
      end
    end
  end
end
