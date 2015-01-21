require 'rails_helper'

RSpec.describe User, :type => :model do
  fixtures :users

  let(:user) { users(:test) }
  subject { user }

  it { should be_valid }

  it { should validate_uniqueness_of :token }

  it { should have_many :trainings }
  it { should have_many :snapshots }

  it 'should generate token' do
    expect(User.create!.token).to be_present
  end
end
