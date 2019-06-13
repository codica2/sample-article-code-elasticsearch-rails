# frozen_string_literal: true

class HomeController < ApplicationController
  def search
    results = Location.search(search_params[:q], search_params)

    locations = results.map do |r|
      r.merge(r.delete('_source')).merge('id': r.delete('_id'))
    end

    render json: { locations: locations }, status: :ok
  end

  private

  def search_params
    params.permit(:q, :level)
  end
end
