require 'rails_helper'

RSpec.describe Step, :type => :model do
  fixtures :steps

  let(:step) { steps(:first) }
  subject { step }

  it { should be_valid }

  it { should validate_presence_of(:ru_answers) }
  it { should validate_presence_of(:en_answers) }
  it { should have_many(:units) }
end
