require 'rails_helper'

RSpec.describe Step, :type => :model do
  fixtures :steps

  let(:step) { steps(:first) }
  subject { step }

  it { should be_valid }

  it { should validate_presence_of(:ru) }
  it { should validate_presence_of(:en) }
  it { should have_many(:units) }
end
