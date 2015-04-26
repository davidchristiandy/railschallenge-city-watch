class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates :capacity, presence: true, inclusion: { in: [1, 2, 3, 4, 5] }
  belongs_to :emergency

  class << self
    def get_capacity_array(type)
      result = [0, 0, 0, 0]
      responders = where(type: type).all
      responders.each do |x|
        result[0] += x.capacity
        result[1] += x.capacity unless x.emergency.present?
        next unless x.on_duty
        result[2] += x.capacity
        result[3] += x.capacity if x.emergency.nil?
      end

      result
    end

    def all_hash
      result = { responders: [] }
      all.find_each do |x|
        result[:responders] << x.hash_form[:responder]
      end

      result
    end

    def available_responders
      where(on_duty: true, emergency_id: nil)
    end

    def request_responders_for(needed_type, needed_capacity)
      responders = where(type: needed_type, on_duty: true, emergency_id: nil)
      assigned = []

      return [] unless responders.present?
      responders.find_each do |x|
        assigned << x
        # assign responder immediately if a perfect match is found
        next unless x.capacity == needed_capacity
        return [x]
      end

      minimum_responders(assigned, needed_capacity)
    end

    private

    # minimum_responders uses a little dynamic programming, and
    # returns an array of responders that:
    # 1. has the closest total capacity to the severity
    # 2. has the least number of units
    def minimum_responders(responders, need)
      return nil if need < 1
      return responders[0] if responders.size == 1

      selections = []
      responders.each do |x|
        list = responders.select { |responder| responder != x }
        temp = [x]
        minimum = minimum_responders(list, need - x.capacity)
        temp << minimum if minimum.present?
        selections << temp.flatten
      end

      return nil if selections.size == 0
      filter_excessive_responders(selections)
    end

    def total_capacity_from_array(responders)
      return 0 unless responders.present?
      Rails.logger.info(responders)
      total = 0
      responders.each do |x|
        total += x.capacity
      end

      total
    end

    def filter_excessive_responders(array)
      Rails.logger.info("Excessive responders = #{array}\n\n")
      current_minimum = 999
      current_count = 999
      result = nil
      array.each do |x|
        cap = total_capacity_from_array(x)
        num = x.size
        result << x if cap == current_minimum || num == current_count
        next if cap >= current_minimum || num >= current_minimum
        result = x
        current_minimum = cap
        current_count = num
      end

      result
    end
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
