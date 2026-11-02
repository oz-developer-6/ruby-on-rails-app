require 'rails_helper'

RSpec.describe Homework, type: :model do
  let(:school) { School.create!(name: 'Beacon Academy', code: 'BA-01') }

  describe 'validations' do
    subject do
      described_class.new(
        school: school,
        title: 'Calculus Assignment 1',
        subject: 'Mathematics',
        max_score: 100,
        due_date: Date.tomorrow
      )
    end

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a title' do
      subject.title = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it 'requires a subject' do
      subject.subject = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:subject]).to include("can't be blank")
    end

    it 'requires a positive max score' do
      subject.max_score = 0
      expect(subject).not_to be_valid
      expect(subject.errors[:max_score]).to include('must be greater than 0')
    end

    it 'requires a due date' do
      subject.due_date = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:due_date]).to include("can't be blank")
    end
  end

  describe 'status and computation methods' do
    let(:homework) do
      described_class.create!(
        school: school,
        title: 'Biology Experiment',
        subject: 'Biology',
        max_score: 50,
        due_date: Date.yesterday
      )
    end

    let!(:student1) { Student.create!(school: school, first_name: 'George', last_name: 'Lucas', email: 'george@ba.edu', enrollment_number: 'BA-01') }
    let!(:student2) { Student.create!(school: school, first_name: 'Hannah', last_name: 'Abbott', email: 'hannah@ba.edu', enrollment_number: 'BA-02') }

    it 'detects if homework is overdue' do
      expect(homework).to be_overdue
    end

    it 'calculates average score and percentage' do
      Marking.create!(homework: homework, student: student1, score: 40, status: 'marked')
      Marking.create!(homework: homework, student: student2, score: 50, status: 'marked')

      expect(homework.average_score).to eq(45.0)
      expect(homework.average_percentage).to eq(90.0)
    end

    it 'assigns homework to all school students' do
      fresh_homework = described_class.create!(
        school: school,
        title: 'World War II Summary',
        subject: 'History',
        max_score: 100,
        due_date: Date.tomorrow
      )

      expect { fresh_homework.assign_to_all_school_students! }.to change(Marking, :count).by(2)
      expect(fresh_homework.markings.pluck(:status)).to all(eq('pending'))
    end
  end
end
