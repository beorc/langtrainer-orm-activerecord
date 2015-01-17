require 'rails_helper'

RSpec.describe Unit::AdvanceSnapshot, :type => :model do
  set_fixture_class advance_snapshots: Unit::AdvanceSnapshot
  fixtures :advance_snapshots

  let(:snapshot) { advance_snapshots(:test) }
  subject { snapshot }

  it { should be_valid }

  it { should belong_to(:unit_advance) }
  it { should have_one(:user) }
  it { should have_one(:unit) }
  it { should have_one(:course) }

  it { should validate_presence_of(:unit_advance) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:snapshot) }
  it { should validate_uniqueness_of(:date).scoped_to(:unit_advance_id) }

  it { should serialize(:snapshot) }
end
