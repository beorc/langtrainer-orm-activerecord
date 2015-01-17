require 'rails_helper'

RSpec.describe Unit::Advance, :type => :model do
  set_fixture_class advances: Unit::Advance
  fixtures :advances

  let(:advance) { advances(:first) }
  subject { advance }

  it { should be_valid }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:unit) }
  it { should validate_presence_of(:language_id) }
  it { should validate_presence_of(:native_language_id) }
  it { should validate_uniqueness_of(:unit).scoped_to([:user_id, :language_id, :native_language_id]) }

  it { should have_many(:snapshots) }
  it { should serialize(:steps) }

  Unit::Advance::BOXES_NUMBER.times do |i|
    it { should serialize("box_#{i}".to_sym) }
  end

  describe '#step_passed!' do
    it 'should increment the steps_passed' do
      expect{subject.step_passed!}.to change(subject, :steps_passed).by(1)
    end
  end

  describe '#word_helped!' do
    it 'should increment the words_helped' do
      expect{subject.word_helped!}.to change(subject, :words_helped).by(1)
    end
  end

  describe '#step_helped!' do
    it 'should increment the steps_helped' do
      expect{subject.step_helped!}.to change(subject, :steps_helped).by(1)
    end
  end

  describe '#wrong_answer!' do
    it 'should increment the wrong_answers' do
      expect{subject.wrong_answer!}.to change(subject, :wrong_answers).by(1)
    end
  end

  describe '#revised!' do
    it 'should change revised to true' do
      expect{subject.revised!}.to change(subject, :revised).to(true)
    end
  end

  describe '#step_revised!' do
    it 'should increment the revised_steps_number' do
      expect{subject.step_revised!}.to change(subject, :revised_steps_number).by(1)
    end
  end

  describe '#advance!' do
    it 'should increment the current_step' do
      expect{subject.advance!}.to change(subject, :current_step).by(1)
    end
  end

  describe '#create_snapshot!' do
    it 'should create new snaphot' do
      expect{subject.create_snapshot!}.to change(subject.snapshots, :length).by(1)
    end
  end

  describe '#fetch_step' do
    before(:each) do
      subject.send(:ensure_steps)
      subject.send(:init_boxes)
    end

    it 'should have steps' do
      expect(subject.steps).to be_present
    end

    it 'should have steps' do
      expect(subject.box_0).to be_present
    end

    context 'given the not revised advance' do
      it 'should call fetch_regular_step' do
        expect(subject).to receive(:fetch_regular_step)
        subject.fetch_step
      end

      it 'should return a step' do
        expect(subject.fetch_step).to be_a Step
      end
    end

    context 'given the revised advance' do
      let(:advance) { advances(:revised) }

      it 'should call fetch_step_from_boxes' do
        expect(subject).to receive(:fetch_step_from_boxes)
        subject.fetch_step
      end

      it 'should return a step' do
        expect(subject.fetch_step).to be_a Step
      end
    end
  end
end
