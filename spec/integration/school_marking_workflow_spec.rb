require 'rails_helper'

RSpec.describe 'School and Student Marking Database Workflow', type: :integration do
  it 'executes the complete lifecycle from school creation to final marking statistics' do
    school = School.create!(
      name: 'St. Jude International Academy',
      code: 'SJIA-01',
      address: '77 Academy Way'
    )

    student_one = Student.create!(
      school: school,
      first_name: 'Hermione',
      last_name: 'Granger',
      email: 'hermione@hogwarts.ac.uk',
      enrollment_number: 'EN-001'
    )

    student_two = Student.create!(
      school: school,
      first_name: 'Ron',
      last_name: 'Weasley',
      email: 'ron@hogwarts.ac.uk',
      enrollment_number: 'EN-002'
    )

    homework = Homework.create!(
      school: school,
      title: 'Transfiguration Theory',
      subject: 'Magic',
      description: 'Explain the principles of Gamp law',
      max_score: 100,
      due_date: Date.current + 7.days
    )

    homework.assign_to_all_school_students!

    expect(Marking.where(homework: homework).count).to eq(2)
    expect(Marking.where(status: 'pending').count).to eq(2)

    hermione_marking = Marking.find_by!(homework: homework, student: student_one)
    hermione_marking.mark!(98.5, 'Exceptional mastery of transformations')

    ron_marking = Marking.find_by!(homework: homework, student: student_two)
    ron_marking.mark!(54.0, 'Acceptable effort, needs more precision')

    expect(hermione_marking.reload.percentage).to eq(98.5)
    expect(hermione_marking.grade_letter).to eq('A')
    expect(hermione_marking.passed?).to be true

    expect(ron_marking.reload.percentage).to eq(54.0)
    expect(ron_marking.grade_letter).to eq('D')
    expect(ron_marking.passed?).to be true

    expect(homework.reload.average_score).to eq(76.25)
    expect(homework.completion_rate_percentage).to eq(100.0)

    expect(school.reload.average_score).to eq(76.25)
    expect(school.completion_rate_percentage).to eq(100.0)

    ron_marking.require_resubmission!('Please rewrite section 2')

    expect(ron_marking.reload.resubmission_required?).to be true
    expect(ron_marking.score).to be_nil
    expect(school.reload.completion_rate_percentage).to eq(50.0)
    expect(school.average_score).to eq(98.5)
  end
end
