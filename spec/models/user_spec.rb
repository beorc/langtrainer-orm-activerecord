require 'rails_helper'

RSpec.describe User, :type => :model do
  fixtures :users

  let(:user) { users(:test) }
  subject { user }

  it { should be_valid }

  it { should validate_uniqueness_of :token }

  it { should have_many :trainings }

  describe '.fetch_or_create_by!' do
    it 'should set up token' do
      expect(User.fetch_or_create_by!('test token')).to be_persisted
    end

    it 'should raise exception if token is blank' do
      expect { User.fetch_or_create_by!(nil) }.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end

  describe '.fetch' do
    context 'given no token' do
      let(:token) { nil }

      it 'should set up token' do
        expect(User.fetch(token).token).to be_present
      end

      it 'return not persisted user' do
        expect(User.fetch(token)).to_not be_persisted
      end
    end

    context 'given not existing token' do
      let(:token) { 'not existing' }

      it 'should set up token' do
        expect(User.fetch(token).token).to be_present
      end

      it 'should set up different token' do
        expect(User.fetch(token).token).to_not eq token
      end

      it 'return not persisted user' do
        expect(User.fetch(token)).to_not be_persisted
      end
    end

    context 'given present token' do
      let(:token) { user.token }

      it 'should return user by token' do
        expect(User.fetch(token).token).to eq(token)
      end
    end
  end
end
