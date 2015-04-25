class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates :capacity, presence: true, inclusion: { in: [1, 2, 3, 4, 5] }
  belongs_to :emergency

  def self.get_capacity_array(type)
    total, available, on_duty, available_on_duty = 0, 0, 0, 0
    responders = where(type: type).all
    responders.each do |x|
      total += x.capacity
      available += x.capacity unless x.emergency.present?
      on_duty += x.capacity if x.on_duty
      available_on_duty += x.capacity if x.on_duty && x.emergency.nil?
    end

    [total, available, on_duty, available_on_duty]
  end

  def self.all_hash
    result = { responders: [] }
    all.each do |x|
      result[:responders] << x.hash_form[:responder]
    end

    result
  end

  def self.available_responders
    where(on_duty: true, emergency_id: nil)
  end

  def emergency_code
    return emergency.code if emergency.present?
    nil
  end

  def hash_form
    {
      responder: {
        emergency_code: emergency_code,
        type: type,
        name: name,
        capacity: capacity,
        on_duty: on_duty
      }
    }
  end
end
