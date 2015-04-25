class RespondersController < ApplicationController
  # gets responder record by :name
  def show
    record = Responder.find_by(name: params[:id])
    return resource_not_found unless record.present?

    render json: { responder: record }, status: :ok
  end

  def create
    status = :created
    record = Responder.new(responder_params)
    if record.save
      response = {
        responder: {
          emergency_code: nil,
          type: record.type,
          name: record.name,
          capacity: record.capacity,
          on_duty: record.on_duty
        }
      }
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
    record = Responder.find_by(name: params[:id])
    return resource_not_found unless record.present?
    if record.update(responder_update_params)
      response = {
        responder: {
          emergency_code: record.emergency_code,
          type: record.type,
          name: record.name,
          capacity: record.capacity,
          on_duty: record.on_duty
        }
      }
    else
      status = :unprocessable_entity
      response = { message: record.errors }
    end

    render json: response, status: status
  rescue ActionController::UnpermittedParameters => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  private

  def responder_params
    params.require(:responder).permit(
      :type,
      :name,
      :capacity
    )
  end

  def responder_update_params
    params.require(:responder).permit(
      :on_duty
    )
  end
end
