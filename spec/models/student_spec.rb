require 'rails_helper'

RSpec.describe Student, type: :model do
  let(:school) { School.create!(name: 'Northwood High', code: 'NW-01') }

  describe 'validations' do
    subject do
      described_class.new(
        school: school,
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@northwood.edu',
        enrollment_number: 'NW-2026-001'
      )
    end

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a first name' do
      subject.first_name = ''
      expect(subject).not_to be_valid
      expect(subject.errors[:first_name]).to include("can't be blank")
    end

    it 'requires a last name' do
      subject.last_name = ''
      expect(subject).not_to be_valid
      expect(subject.errors[:last_name]).to include("can't be blank")
    end

    it 'validates email format' do
      subject.email = 'invalid-email'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include('is invalid')
    end

    it 'enforces unique emails case-insensitively' do
      subject.save!
      duplicate = described_class.new(
        school: school,
        first_name: 'Jane',
        last_name: 'Doe',
        email: 'JOHN.DOE@NORTHWOOD.EDU',
        enrollment_number: 'NW-2026-002'
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end

    it 'enforces unique enrollment numbers' do
      subject.save!
      duplicate = described_class.new(
        school: school,
        first_name: 'Jane',
        last_name: 'Smith',
        email: 'jane.smith@northwood.edu',
        enrollment_number: 'nw-2026-001'
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:enrollment_number]).to include('has already been taken')
    end
  end

  describe 'instance methods' do
    let(:student) do
      described_class.create!(
        school: school,
        first_name: 'Emma',
        last_name: 'Watson',
        email: 'emma@northwood.edu',
        enrollment_number: 'NW-100'
      )
    end

    let(:homework1) { Homework.create!(school: school, title: 'English Essay', subject: 'English', max_score: 100, due_date: Date.tomorrow) }
    let(:homework2) { Homework.create!(school: school, title: 'Chemistry Lab', subject: 'Science', max_score: 50, due_date: Date.tomorrow) }
    let(:homework3) { Homework.create!(school: school, title: 'History Paper', subject: 'History', max_score: 100, due_date: Date.tomorrow) }

    it 'provides full name concatenation' do
      expect(student.full_name).to eq('Emma Watson')
    end

    it 'computes average score across marked assignments' do
      Marking.create!(homework: homework1, student: student, score: 85, status: 'marked')
      Marking.create!(homework: homework2, student: student, score: 45, status: 'marked')
      expect(student.average_score).to eq(65.0)
    end

    it 'computes completion rate percentage' do
      Marking.create!(homework: homework1, student: student, score: 90, status: 'marked')
      Marking.create!(homework: homework2, student: student, status: 'pending')
      expect(student.completion_rate_percentage).to eq(50.0)
    end

    it 'counts passed markings' do
      Marking.create!(homework: homework1, student: student, score: 75, status: 'marked')
      Marking.create!(homework: homework2, student: student, score: 10, status: 'marked')
      expect(student.passed_markings_count).to eq(1)
    end
  end
end
