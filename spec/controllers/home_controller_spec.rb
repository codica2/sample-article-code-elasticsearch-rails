# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #search' do
    let!(:location) { create :location }

    it 'returns http success' do
      get :search
      expect(response).to have_http_status(:success)
    end
  end
end
