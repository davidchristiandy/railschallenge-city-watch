class RespondersController < ApplicationController
  skip_before_action :resource_not_found, only: [:index]

  def index
    show = params[:show]
    if show.present?
      response = {
        capacity: {
          'Fire' => Responder.get_capacity_array('Fire'),
          'Police' => Responder.get_capacity_array('Police'),
          'Medical' => Responder.get_capacity_array('Medical')
        }
      }
    else
      response = Responder.all_hash
    end

    render json: response, status: :ok
  end

  # gets responder record by :name
  def show
    record = Responder.find_by(name: params[:id])
    return resource_not_found unless record.present?

    render json: record.hash_form, status: :ok
  end

  def create
    status = :created
    record = Responder.new(responder_params)
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
    record = Responder.find_by(name: params[:id])
    return resource_not_found unless record.present?
    if record.update(responder_update_params)
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
