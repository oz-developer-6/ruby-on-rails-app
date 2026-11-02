require 'rails_helper'

RSpec.describe Marking, type: :model do
  let(:school) { School.create!(name: 'Kingsway Academy', code: 'KA-01') }
  let(:student) { Student.create!(school: school, first_name: 'Ian', last_name: 'Malcolm', email: 'ian@ka.edu', enrollment_number: 'KA-10') }
  let(:homework) { Homework.create!(school: school, title: 'Chaos Theory Notes', subject: 'Mathematics', max_score: 100, due_date: Date.tomorrow) }

  describe 'validations' do
    subject { described_class.new(homework: homework, student: student, status: 'pending') }

    it 'is valid with pending status and no score' do
      expect(subject).to be_valid
    end

    it 'allows valid status values' do
      %w[pending marked resubmission_required].each do |valid_status|
        subject.status = valid_status
        subject.score = 75 if valid_status == 'marked'
        expect(subject).to be_valid
      end
    end

    it 'rejects invalid status values' do
      subject.status = 'unknown_status'
      expect(subject).not_to be_valid
      expect(subject.errors[:status]).to include('is not included in the list')
    end

    it 'rejects scores higher than homework max score' do
      subject.status = 'marked'
      subject.score = 105
      expect(subject).not_to be_valid
      expect(subject.errors[:score]).to include('cannot exceed maximum score of 100')
    end

    it 'rejects negative scores' do
      subject.score = -5
      expect(subject).not_to be_valid
      expect(subject.errors[:score]).to include('must be greater than or equal to 0')
    end

    it 'requires score if marked' do
      subject.status = 'marked'
      subject.score = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:score]).to include('must be provided when marking status is marked')
    end

    it 'enforces uniqueness per student and homework' do
      subject.save!
      duplicate = described_class.new(homework: homework, student: student, status: 'pending')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:student_id]).to include('has already been taken')
    end

    it 'prevents marking students from a different school' do
      other_school = School.create!(name: 'Queensway High', code: 'QH-01')
      other_student = Student.create!(school: other_school, first_name: 'Other', last_name: 'Student', email: 'other@qh.edu', enrollment_number: 'QH-01')

      invalid_marking = described_class.new(homework: homework, student: other_student, status: 'pending')
      expect(invalid_marking).not_to be_valid
      expect(invalid_marking.errors[:student]).to include('must belong to the same school as the homework')
    end
  end

  describe 'grading logic and state transitions' do
    let(:marking) { described_class.create!(homework: homework, student: student, status: 'pending') }

    it 'calculates percentage and grade letters accurately' do
      marking.mark!(95, 'Outstanding analysis')
      expect(marking.percentage).to eq(95.0)
      expect(marking.passed?).to be true
      expect(marking.grade_letter).to eq('A')
      expect(marking.marked_at).to be_present

      marking.mark!(82)
      expect(marking.grade_letter).to eq('B')

      marking.mark!(73)
      expect(marking.grade_letter).to eq('C')

      marking.mark!(61)
      expect(marking.grade_letter).to eq('D')

      marking.mark!(42)
      expect(marking.passed?).to be false
      expect(marking.grade_letter).to eq('F')
    end

    it 'transitions to resubmission required' do
      marking.mark!(30, 'Please review chapter 4')
      marking.require_resubmission!('Need more explanations on step 3')

      expect(marking.resubmission_required?).to be true
      expect(marking.score).to be_nil
      expect(marking.feedback).to eq('Need more explanations on step 3')
    end
  end
end
