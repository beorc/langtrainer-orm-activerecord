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
      expect(User.fetch_or_create_by!(nil).token).to be_present
    end
  end
end
