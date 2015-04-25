class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :fire_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :police_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :medical_severity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  has_many :responders

  after_create :assign_available_responders

  def self.full_responses
    emergencies, full_response = all, 0
    emergencies.each do |x|
      full_response += 1 if x.all_severities_fulfilled?
    end

    [full_response, emergencies.length]
  end

  def fire_severity_fulfilled?
    assigned_capacity = 0
    responders.where(type: 'Fire').each do |x|
      assigned_capacity += x.capacity
    end

    assigned_capacity >= fire_severity
  end

  def medical_severity_fulfilled?
    assigned_capacity = 0
    responders.where(type: 'Medical').each do |x|
      assigned_capacity += x.capacity
    end

    assigned_capacity >= medical_severity
  end

  def police_severity_fulfilled?
    assigned_capacity = 0
    responders.where(type: 'Police').each do |x|
      assigned_capacity += x.capacity
    end

    assigned_capacity >= police_severity
  end

  def all_severities_fulfilled?
    fire_severity_fulfilled? &&
      medical_severity_fulfilled? &&
      police_severity_fulfilled?
  end

  # TODO: implement dispatchers
  def assign_available_responders
    available_responders = Responder.available_responders
  end
end
