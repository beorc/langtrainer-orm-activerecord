require 'rails_helper'

RSpec.describe Training, :type => :model do
  fixtures [:users, :units, :steps, :steps_units, :trainings]

  let(:training) { trainings(:first) }
  subject { training }

  it { should be_valid }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:unit) }
  it { should validate_presence_of(:language_id) }
  it { should validate_presence_of(:native_language_id) }
  it { should validate_uniqueness_of(:unit).scoped_to([:user_id, :language_id, :native_language_id]) }

  Training.each_box_number do |i|
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

  describe '#step_revised!' do
    it 'should increment the revised_steps_number' do
      expect{subject.step_revised!}.to change(subject, :revised_steps_number).by(1)
    end
  end

  describe '#enshure_snapshot' do
    it 'should create today snapshot' do
      expect{subject.ensure_snapshot}.to change(subject.snapshots, :length).by(1)
    end
  end

  describe '#ensure_boxes' do
    before(:each) do
      subject.ensure_boxes
    end

    it 'should set up step ids into first box' do
      expect(subject.box_0).to be_present
    end
  end

  describe '#fetch_step!' do
    before(:each) do
      subject.send(:ensure_boxes)
    end

    context 'given the not revised training' do
      it 'should call fetch_regular_step' do
        expect(subject).to receive(:current_step)
        subject.fetch_step!
      end

      it 'should return a step' do
        expect(subject.fetch_step!).to be_a Step
      end
    end
  end

  describe 'given initialized boxes' do
    let(:step_id) { subject.current_step_id }

    before(:each) do
      subject.ensure_boxes
      subject.box_0.delete(step_id)
    end

    describe '#put_current_step_to_first_box!' do
      it 'should move current step id to the first box' do
        subject.box_3.push(step_id)
        subject.push_current_step_to_first_box!
        expect(subject.box_0).to include(step_id)
      end
    end

    describe '#put_current_step_to_next_box!' do
      context 'when current step is not in the last box' do
        it 'should move current step id to the next box' do
          subject.box_3.push(step_id)
          subject.push_current_step_to_next_box!
          expect(subject.box_4).to include(step_id)
        end
      end

      context 'when current step is in the last box' do
        it 'should not touch current step' do
          subject.box_4.push(step_id)
          subject.push_current_step_to_next_box!
          expect(subject.box_4).to include(step_id)
        end
      end
    end
  end
end
