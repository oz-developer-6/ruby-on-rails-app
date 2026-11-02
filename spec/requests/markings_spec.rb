require 'rails_helper'

RSpec.describe 'Markings', type: :request do
  let!(:school) { School.create!(name: 'Horizon High', code: 'HH-01') }
  let!(:student) { Student.create!(school: school, first_name: 'Miles', last_name: 'Morales', email: 'miles@horizon.edu', enrollment_number: 'HH-001') }
  let!(:homework) { Homework.create!(school: school, title: 'Robotics Design', subject: 'Robotics', max_score: 100, due_date: Date.tomorrow) }
  let!(:marking) { Marking.create!(homework: homework, student: student, status: 'pending') }

  describe 'GET /markings' do
    it 'returns http success and lists markings' do
      get markings_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Miles Morales')
      expect(response.body).to include('Robotics Design')
    end

    it 'filters by status' do
      get markings_path(status: 'pending')
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Miles Morales')

      get markings_path(status: 'marked')
      expect(response.body).to include('No marking records match your selection.')
    end
  end

  describe 'GET /markings/:id' do
    it 'renders marking details' do
      get marking_path(marking)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Miles Morales')
      expect(response.body).to include('Robotics Design')
    end
  end

  describe 'PATCH /markings/:id' do
    context 'grading a submission' do
      let(:update_params) do
        {
          marking: {
            status: 'marked',
            score: 94.5,
            feedback: 'Brilliant circuit schematics!'
          }
        }
      end

      it 'updates score, status, and redirects to marking page' do
        patch marking_path(marking), params: update_params
        expect(response).to redirect_to(marking_path(marking))
        follow_redirect!
        expect(response.body).to include('Marking successfully recorded.')

        marking.reload
        expect(marking.score).to eq(94.5)
        expect(marking.status).to eq('marked')
        expect(marking.grade_letter).to eq('A')
      end
    end

    context 'with invalid score exceeding max' do
      it 'renders unprocessable entity' do
        patch marking_path(marking), params: { marking: { status: 'marked', score: 120 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /markings/:id/quick_mark' do
    it 'grades via quick_mark' do
      patch quick_mark_marking_path(marking), params: { score: 88, feedback: 'Great job' }
      expect(response).to redirect_to(marking_path(marking))
      expect(marking.reload.score).to eq(88.0)
      expect(marking.status).to eq('marked')
    end

    it 'triggers resubmission via quick_mark' do
      patch quick_mark_marking_path(marking), params: { status: 'resubmission_required', feedback: 'Please fix step 2' }
      expect(response).to redirect_to(marking_path(marking))
      expect(marking.reload.status).to eq('resubmission_required')
      expect(marking.score).to be_nil
    end
  end

  describe 'DELETE /markings/:id' do
    it 'removes marking record' do
      expect do
        delete marking_path(marking)
      end.to change(Marking, :count).by(-1)

      expect(response).to redirect_to(homework_path(homework))
    end
  end
end
