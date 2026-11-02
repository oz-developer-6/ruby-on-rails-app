require 'rails_helper'

RSpec.describe 'Homeworks', type: :request do
  let!(:school) { School.create!(name: 'Midtown High', code: 'MH-01') }
  let!(:homework) do
    Homework.create!(
      school: school,
      title: 'Chemistry Lab Report',
      subject: 'Chemistry',
      description: 'Write up polymer experiment',
      max_score: 100,
      due_date: Date.tomorrow
    )
  end

  describe 'GET /homeworks' do
    it 'returns http success and lists homework assignments' do
      get homeworks_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Chemistry Lab Report')
      expect(response.body).to include('Chemistry')
    end
  end

  describe 'GET /homeworks/:id' do
    it 'displays homework details and submissions list' do
      get homework_path(homework)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Chemistry Lab Report')
      expect(response.body).to include('Assign to All Students')
    end
  end

  describe 'POST /homeworks' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          homework: {
            school_id: school.id,
            title: 'Algebra Quiz',
            subject: 'Math',
            description: 'Chapter 2 quadratic equations',
            max_score: 50,
            due_date: Date.current + 3.days
          }
        }
      end

      it 'creates a homework and redirects' do
        expect do
          post homeworks_path, params: valid_params
        end.to change(Homework, :count).by(1)

        new_hw = Homework.last
        expect(response).to redirect_to(homework_path(new_hw))
        follow_redirect!
        expect(response.body).to include('Homework assignment successfully published.')
      end
    end

    context 'with invalid parameters' do
      it 'renders unprocessable entity' do
        post homeworks_path, params: { homework: { school_id: school.id, title: '', max_score: 0 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'POST /homeworks/:id/assign_all' do
    let!(:student1) { Student.create!(school: school, first_name: 'Peter', last_name: 'Parker', email: 'peter@midtown.edu', enrollment_number: 'MH-001') }
    let!(:student2) { Student.create!(school: school, first_name: 'Ned', last_name: 'Leeds', email: 'ned@midtown.edu', enrollment_number: 'MH-002') }

    it 'creates pending markings for all students of the school' do
      expect do
        post assign_all_homework_path(homework)
      end.to change(Marking, :count).by(2)

      expect(response).to redirect_to(homework_path(homework))
      follow_redirect!
      expect(response.body).to include('Homework successfully assigned to all students')
    end
  end

  describe 'DELETE /homeworks/:id' do
    it 'deletes homework and associated markings' do
      expect do
        delete homework_path(homework)
      end.to change(Homework, :count).by(-1)

      expect(response).to redirect_to(homeworks_url)
      follow_redirect!
      expect(response.body).to include('Homework assignment successfully deleted.')
    end
  end
end
