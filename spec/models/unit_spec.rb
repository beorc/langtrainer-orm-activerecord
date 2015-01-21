require 'rails_helper'

RSpec.describe Unit, :type => :model do
  fixtures :units

  let(:unit) { units(:first) }
  subject { unit }

  it { should be_valid }

  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:course) }
  it { should validate_uniqueness_of(:slug).scoped_to(:course_id) }

  it { should belong_to(:course) }
  it { should have_many(:steps) }
  it { should have_many(:trainings) }
end
