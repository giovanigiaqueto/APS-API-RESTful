class CountriesController < ApplicationController
  # renderização HTML
  # include ActionView::Layouts
  # include ActionController::Rendering

  def index
    @countries = Country
      .select(:name, :corruption_index, :annual_income)
      .all
    render json: {"data": @countries}
  end

  def show
    @country = Country
      .select(:name, :corruption_index, :annual_income)
      .where(name: params[:name])
      .take
    render json: {"country": @country}
  rescue ActiveRecord::RecordNotFound
    render json: {"error": 404, "text": "Not Found"}
  end
end
