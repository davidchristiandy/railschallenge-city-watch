class EmergenciesController < ApplicationController
  def index
    response = {
      emergencies: Emergency.all,
      full_responses: Emergency.full_responses
    }
    render json: response, status: :ok
  end

  def show
    record = Emergency.find_by(code: params[:id])
    return resource_not_found unless record.present?

    render json: record.hash_form, status: :ok
  end

  def create
    status = :created
    record = Emergency.new(emergency_params)
    if record.save
      response = record.hash_form
    else
      status = :unprocessable_entity
      response = { message: record.errors }
    end

    render json: response, status: status
  rescue ActionController::UnpermittedParameters => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def update
    status = :ok
    record = Emergency.find_by(code: params[:id])
    return resource_not_found unless record.present?

    if record.update!(emergency_update_params)
      response = record.hash_form
    else
      status = :unprocessable_entity
      response = { message: record.errors }
    end

    render json: response, status: status
  rescue ActionController::UnpermittedParameters => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  private

  def emergency_params
    params.require(:emergency).permit(
      :code,
      :fire_severity,
      :police_severity,
      :medical_severity
    )
  end

  def emergency_update_params
    params.require(:emergency).permit(
      :fire_severity,
      :police_severity,
      :medical_severity,
      :resolved_at
    )
  end
end
