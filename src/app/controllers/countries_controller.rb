class CountriesController < ApplicationController
  # renderização HTML
  # include ActionView::Layouts
  # include ActionController::Rendering

  def index
    return if not autorizar_request
    @countries = Country
      .select(:name, :corruption_index, :annual_income)
      .all
    render json: {"data": @countries}
  end

  def show
    return if not autorizar_request
    @country = Country
      .select(:name, :corruption_index, :annual_income)
      .where(name: params[:name])
      .take
    render json: {"country": @country}
  rescue ActiveRecord::RecordNotFound
    render json: {"error": 404, "text": "Not Found"}
  end
end
