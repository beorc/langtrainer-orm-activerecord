require 'rails_helper'

RSpec.describe StepsUnit, :type => :model do
  fixtures [:units, :steps, :steps_units]

  let(:steps_unit) { steps_units(:first) }
  subject { steps_unit }

  it { should be_valid }
end
