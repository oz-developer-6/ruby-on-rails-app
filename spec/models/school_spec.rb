require 'rails_helper'

RSpec.describe School, type: :model do
  describe 'validations' do
    subject { described_class.new(name: 'Oakridge High', code: 'OAK-01', address: '123 Pine St') }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'requires a code' do
      subject.code = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:code]).to include("can't be blank")
    end

    it 'enforces unique names case-insensitively' do
      subject.save!
      duplicate = described_class.new(name: 'oakridge high', code: 'OAK-02')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'enforces unique codes case-insensitively' do
      subject.save!
      duplicate = described_class.new(name: 'Other School', code: 'oak-01')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:code]).to include('has already been taken')
    end

    it 'normalizes the code to uppercase' do
      school = described_class.create!(name: 'Pine Academy', code: '  pine-01  ')
      expect(school.code).to eq('PINE-01')
    end
  end

  describe 'associations and cascading destruction' do
    let(:school) { described_class.create!(name: 'Greenwood School', code: 'GW-01') }
    let!(:student) { Student.create!(school: school, first_name: 'Alice', last_name: 'Smith', email: 'alice@gw.edu', enrollment_number: 'GW-S1') }
    let!(:homework) { Homework.create!(school: school, title: 'Math 101', subject: 'Math', max_score: 100, due_date: Date.tomorrow) }
    let!(:marking) { Marking.create!(homework: homework, student: student, status: 'pending') }

    it 'destroys associated students, homeworks, and markings when destroyed' do
      expect { school.destroy }.to change(Student, :count).by(-1)
        .and change(Homework, :count).by(-1)
        .and change(Marking, :count).by(-1)
    end
  end

  describe 'statistics methods' do
    let(:school) { described_class.create!(name: 'Riverdale Academy', code: 'RD-01') }
    let(:student1) { Student.create!(school: school, first_name: 'Bob', last_name: 'Stone', email: 'bob@rd.edu', enrollment_number: 'RD-S1') }
    let(:student2) { Student.create!(school: school, first_name: 'Carol', last_name: 'Danvers', email: 'carol@rd.edu', enrollment_number: 'RD-S2') }
    let(:homework) { Homework.create!(school: school, title: 'Physics Quiz', subject: 'Physics', max_score: 100, due_date: Date.tomorrow) }

    before do
      Marking.create!(homework: homework, student: student1, score: 90, status: 'marked')
      Marking.create!(homework: homework, student: student2, score: 70, status: 'marked')
    end

    it 'calculates the student count' do
      expect(school.student_count).to eq(2)
    end

    it 'calculates the homework count' do
      expect(school.homework_count).to eq(1)
    end

    it 'computes average score across completed markings' do
      expect(school.average_score).to eq(80.0)
    end

    it 'returns 100.0 completion rate when all markings are completed' do
      expect(school.completion_rate_percentage).to eq(100.0)
    end

    it 'calculates partial completion rate correctly' do
      student3 = Student.create!(school: school, first_name: 'Dave', last_name: 'Miller', email: 'dave@rd.edu', enrollment_number: 'RD-S3')
      Marking.create!(homework: homework, student: student3, status: 'pending')
      expect(school.completion_rate_percentage).to eq(66.7)
    end
  end
end
