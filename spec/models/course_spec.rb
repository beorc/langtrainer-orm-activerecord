require 'rails_helper'

RSpec.describe Course, :type => :model do
  fixtures :courses

  let(:course) { courses(:test) }
  subject { course }

  it { should be_valid }

  it { should validate_presence_of :slug }
  it { should validate_uniqueness_of :slug }
  it { should have_many :units }
  it { should have_many :steps }
end
