require 'rails_helper'

RSpec.describe 'Database Constraints and Transactions', type: :integration do
  let(:school) { School.create!(name: 'Cambridge High', code: 'CH-100') }
  let(:student) { Student.create!(school: school, first_name: 'Arthur', last_name: 'Dent', email: 'arthur@galaxy.org', enrollment_number: 'EN-42') }
  let(:homework) { Homework.create!(school: school, title: 'Hitchhiker Guide Review', subject: 'Literature', max_score: 100, due_date: Date.tomorrow) }

  describe 'foreign key constraints' do
    it 'raises foreign key violation when creating student with non-existent school_id' do
      expect do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO students (school_id, first_name, last_name, email, enrollment_number, created_at, updated_at) VALUES (999999, 'Ghost', 'Student', 'ghost@nowhere.com', 'EN-999', datetime('now'), datetime('now'))"
        )
      end.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it 'raises foreign key violation when creating marking with non-existent homework_id' do
      expect do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO markings (homework_id, student_id, status, created_at, updated_at) VALUES (888888, #{student.id}, 'pending', datetime('now'), datetime('now'))"
        )
      end.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end

  describe 'database unique constraints' do
    it 'raises unique index violation when inserting duplicate school code at database level' do
      expect do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO schools (name, code, created_at, updated_at) VALUES ('Other School', '#{school.code}', datetime('now'), datetime('now'))"
        )
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'raises unique index violation when inserting duplicate homework and student marking pair' do
      Marking.create!(homework: homework, student: student, status: 'pending')

      expect do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO markings (homework_id, student_id, status, created_at, updated_at) VALUES (#{homework.id}, #{student.id}, 'pending', datetime('now'), datetime('now'))"
        )
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'transaction rollback on operational failures' do
    it 'rolls back entire batch when one marking in transaction fails' do
      other_student = Student.create!(school: school, first_name: 'Ford', last_name: 'Prefect', email: 'ford@galaxy.org', enrollment_number: 'EN-43')

      initial_count = Marking.count

      expect do
        ActiveRecord::Base.transaction do
          Marking.create!(homework: homework, student: student, status: 'pending')
          Marking.create!(homework: homework, student: other_student, status: 'invalid_status_value')
        end
      end.to raise_error(ActiveRecord::RecordInvalid)

      expect(Marking.count).to eq(initial_count)
    end
  end
end
