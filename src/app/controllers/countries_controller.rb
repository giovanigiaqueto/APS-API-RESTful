class CountriesController < ApplicationController
  # renderização HTML
  # include ActionView::Layouts
  # include ActionController::Rendering

  def index
    autorizar_request!
    @countries = Country
      .select(:name, :corruption_index, :annual_income)
      .all
    render json: {"data": @countries}
  end

  def show
    autorizar_request!
    @country = Country
      .select(:name, :corruption_index, :annual_income)
      .where(name: params[:name])
      .take
    render json: {"country": @country}
  end
end
