class EmergenciesController < ApplicationController
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

  private

  def emergency_params
    params.require(:emergency).permit(
      :code,
      :fire_severity,
      :police_severity,
      :medical_severity
    )
  end
end
