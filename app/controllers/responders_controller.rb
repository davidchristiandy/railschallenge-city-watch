class RespondersController < ApplicationController
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

  private

  def responder_params
    params.require(:responder).permit(
      :type,
      :name,
      :capacity
    )
  end
end
