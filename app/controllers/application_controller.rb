class ApplicationController < ActionController::Base
  before_action :page_not_found, only: [:new, :edit, :destroy]

  def new
  end

  def edit
  end

  def destroy
  end

  private

  def page_not_found
    render json: { message: 'page not found' }, status: :not_found
  end
end
