require 'rails_helper'

RSpec.describe Training::Snapshot, :type => :model do
  set_fixture_class training_snapshots: Training::Snapshot
  fixtures [:trainings, :training_snapshots]

  let(:snapshot) { training_snapshots(:first) }
  subject { snapshot }

  it { should be_valid }

  it { should belong_to(:training) }
  it { should have_one(:user) }
  it { should have_one(:unit) }
  it { should have_one(:course) }

  it { should validate_presence_of(:training) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:snapshot) }
  it { should validate_uniqueness_of(:date).scoped_to(:training_id) }

  it { should serialize(:snapshot) }
end
