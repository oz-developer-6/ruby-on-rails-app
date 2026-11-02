require 'rails_helper'

RSpec.describe 'Students', type: :request do
  let!(:school) { School.create!(name: 'Central Academy', code: 'CA-01') }
  let!(:student) { Student.create!(school: school, first_name: 'Barry', last_name: 'Allen', email: 'barry@central.edu', enrollment_number: 'CA-001') }

  describe 'GET /students' do
    it 'returns http success and lists students' do
      get students_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Barry Allen')
      expect(response.body).to include('CA-001')
    end
  end

  describe 'GET /students/:id' do
    it 'displays the student profile and homework history' do
      get student_path(student)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Barry Allen')
      expect(response.body).to include('barry@central.edu')
    end
  end

  describe 'GET /students/new' do
    it 'renders new student form with school options' do
      get new_student_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Enroll Student')
      expect(response.body).to include('Central Academy')
    end
  end

  describe 'POST /students' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          student: {
            school_id: school.id,
            first_name: 'Iris',
            last_name: 'West',
            email: 'iris@central.edu',
            enrollment_number: 'CA-002'
          }
        }
      end

      it 'enrolls a student and redirects to profile' do
        expect do
          post students_path, params: valid_params
        end.to change(Student, :count).by(1)

        new_student = Student.last
        expect(response).to redirect_to(student_path(new_student))
        follow_redirect!
        expect(response.body).to include('Student successfully enrolled.')
      end
    end

    context 'with invalid parameters' do
      it 'renders unprocessable entity when validation fails' do
        post students_path, params: { student: { school_id: school.id, first_name: '', email: 'not-an-email' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /students/:id' do
    it 'updates student profile' do
      patch student_path(student), params: { student: { first_name: 'Bartholomew' } }
      expect(response).to redirect_to(student_path(student))
      expect(student.reload.first_name).to eq('Bartholomew')
    end
  end

  describe 'DELETE /students/:id' do
    it 'deletes student and redirects to index' do
      expect do
        delete student_path(student)
      end.to change(Student, :count).by(-1)

      expect(response).to redirect_to(students_url)
      follow_redirect!
      expect(response.body).to include('Student record successfully removed.')
    end
  end
end
