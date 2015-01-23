require 'rails_helper'

RSpec.describe Step, :type => :model do
  fixtures :steps

  let(:step) { steps(:first) }
  subject { step }

  it { should be_valid }

  it { should validate_presence_of(:ru_answers) }
  it { should validate_presence_of(:en_answers) }
  it { should have_many(:units) }

  describe '#question' do
    context 'given the step without explicit question' do
      it 'should return first answer' do
        expect(subject.question(:ru)).to eq 'первый'
        expect(subject.question(:en)).to eq 'first'
      end
    end

    context 'given the step with explicit question' do
      before(:each) do
        subject.ru_question = 'вопрос'
        subject.en_question = 'question'
        subject.save!
      end

      it 'should return explicit question' do
        expect(subject.question(:ru)).to eq 'вопрос'
        expect(subject.question(:en)).to eq 'question'
      end
    end
  end

  describe '#title' do
    it 'should return first english question' do
      expect(subject.title).to eq subject.question(:en)
    end
  end

  describe '#right_answer?' do
    it 'should return true for right answer' do
      expect(subject.right_answer?(:en, 'first')).to eq true
    end

    it 'should return false for wrong answer' do
      expect(subject.right_answer?(:en, 'первый')).to eq false
    end
  end
end
