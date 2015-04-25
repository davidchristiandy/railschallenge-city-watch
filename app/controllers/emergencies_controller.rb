class EmergenciesController < ApplicationController
  def show
    record = Emergency.find_by(code: params[:id])
    return resource_not_found unless record.present?

    render json: { emergency: record }, status: :ok
  end

  def create
    status = :created
    record = Emergency.new(emergency_params)
    if record.save
      response = { emergency: record }
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

    if record.update(emergency_update_params)
      response = { emergency: record }
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
