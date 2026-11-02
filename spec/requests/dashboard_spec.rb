require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  describe 'GET /' do
    it 'renders the dashboard with key metrics and HTTP 200' do
      school = School.create!(name: 'Metropolis High', code: 'MET-01')
      student = Student.create!(school: school, first_name: 'Clark', last_name: 'Kent', email: 'clark@dailyplanet.com', enrollment_number: 'MET-001')
      homework = Homework.create!(school: school, title: 'Journalism Ethics', subject: 'English', max_score: 100, due_date: Date.tomorrow)
      Marking.create!(homework: homework, student: student, score: 98, status: 'marked')

      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('EduMark System')
      expect(response.body).to include('Metropolis High')
      expect(response.body).to include('Clark Kent')
      expect(response.body).to include('Journalism Ethics')
    end
  end
end
