require 'rails_helper'

RSpec.describe TokenService do
  let(:key) { 'abcdefghijklmnopqrstuvwxyz' }
  let(:user) { FactoryGirl.build(:user, email: 'alice@example.org') }

  before do
    allow(User).to receive(:where).with(email: user.email).and_return([user])
  end

  it 'encrypts and decrypts the current user' do
    token = described_class.new_token(key, user, 1000)
    expect(described_class.user_from_token(key, token)).to eq(user)
  end

  it 'returns nil if the token is invalid' do
    expect(described_class.user_from_token(key, 'xxx')).to be nil
    expect(described_class.user_from_token(key, Base64.encode64('x_x'))).to be nil
  end
end
