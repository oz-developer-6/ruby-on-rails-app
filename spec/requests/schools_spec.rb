require 'rails_helper'

RSpec.describe 'Schools', type: :request do
  let!(:school) { School.create!(name: 'Gotham Academy', code: 'GA-01', address: '100 Wayne Manor') }

  describe 'GET /schools' do
    it 'returns http success and lists schools' do
      get schools_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Gotham Academy')
      expect(response.body).to include('GA-01')
    end
  end

  describe 'GET /schools/:id' do
    it 'shows school details and associated metrics' do
      get school_path(school)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Gotham Academy')
      expect(response.body).to include('100 Wayne Manor')
    end
  end

  describe 'GET /schools/new' do
    it 'renders the new school form' do
      get new_school_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('New School')
    end
  end

  describe 'POST /schools' do
    context 'with valid parameters' do
      let(:valid_params) do
        { school: { name: 'Star City High', code: 'SC-01', address: '50 Queen Blvd' } }
      end

      it 'creates a new School and redirects to show' do
        expect do
          post schools_path, params: valid_params
        end.to change(School, :count).by(1)

        created_school = School.last
        expect(created_school.name).to eq('Star City High')
        expect(created_school.code).to eq('SC-01')
        expect(response).to redirect_to(school_path(created_school))
        follow_redirect!
        expect(response.body).to include('School successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { school: { name: '', code: '' } }
      end

      it 'does not create a school and returns 422 unprocessable entity' do
        expect do
          post schools_path, params: invalid_params
        end.not_to change(School, :count)

        expect(response).to have_http_status(422)
        expect(response.body).to include("can&#39;t be blank")
      end
    end
  end

  describe 'PATCH /schools/:id' do
    context 'with valid parameters' do
      it 'updates the school and redirects' do
        patch school_path(school), params: { school: { name: 'Gotham International Academy' } }
        expect(response).to redirect_to(school_path(school))
        follow_redirect!
        expect(school.reload.name).to eq('Gotham International Academy')
        expect(response.body).to include('School successfully updated.')
      end
    end

    context 'with invalid parameters' do
      it 'does not update and returns unprocessable entity' do
        patch school_path(school), params: { school: { name: '' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /schools/:id' do
    it 'destroys the school and redirects to index' do
      expect do
        delete school_path(school)
      end.to change(School, :count).by(-1)

      expect(response).to redirect_to(schools_url)
      follow_redirect!
      expect(response.body).to include('School successfully removed.')
    end
  end
end
