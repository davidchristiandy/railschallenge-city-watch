class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :fire_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :police_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :medical_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :responders

  # TODO: change this to after save to handle update actions
  after_create :assign_available_responders!
  before_update :reassign_responders!

  def self.full_responses
    emergencies, full = all, 0
    emergencies.each do |x|
      full += 1 if x.full_response
    end

    [full, emergencies.size]
  end

  def responder_names
    responders.map(&:name) || []
  end

  def fire_severity_fulfilled?
    assigned_capacity = 0
    responders.where(type: 'Fire').find_each do |x|
      assigned_capacity += x.capacity
    end

    assigned_capacity >= fire_severity
  end

  def medical_severity_fulfilled?
    assigned_capacity = 0
    responders.where(type: 'Medical').find_each do |x|
      assigned_capacity += x.capacity
    end

    assigned_capacity >= medical_severity
  end

  def police_severity_fulfilled?
    assigned_capacity = 0
    responders.where(type: 'Police').find_each do |x|
      assigned_capacity += x.capacity
    end

    assigned_capacity >= police_severity
  end

  def all_severities_fulfilled?
    fire_severity_fulfilled? &&
      medical_severity_fulfilled? &&
      police_severity_fulfilled?
  end

  def hash_form
    {
      emergency: {
        code: code,
        fire_severity: fire_severity,
        police_severity: police_severity,
        medical_severity: medical_severity,
        resolved_at: resolved_at,
        responders: responder_names,
        full_response: all_severities_fulfilled?
      }
    }
  end

  def severities_changed?
    fire_severity_changed? ||
      police_severity_changed? ||
      medical_severity_changed?
  end

  def severities_hash
    {
      'Fire' => fire_severity,
      'Police' => police_severity,
      'Medical' => medical_severity
    }
  end

  def assign_available_responders!
    return if resolved_at.present?
    assigned = []
    severities_hash.each do |key, value|
      assigned << Responder.request_responders_for(key, value)
    end

    assigned.flatten.each do |x|
      next unless x.present?
      responders << x
    end

    update_column :full_response, all_severities_fulfilled?
  end

  def reassign_responders!
    responders.delete_all
    return if resolved_at.present?
    assign_available_responders!
  end
end
