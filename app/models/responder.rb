class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates :capacity, presence: true, inclusion: { in: [1, 2, 3, 4, 5] }
  belongs_to :emergency

  class << self
    # Returns an array of 4 elements, which contain:
    # - total capacity of all responders (on and off duty)
    # - total capacity of all available responders
    # - total capacity of all on-duty responders
    # - total capacity of all available and on-duty responders
    #
    # @param string type
    # @return array
    def get_capacity_array(type)
      result = [0, 0, 0, 0]
      responders = where(type: type)
      responders.each do |x|
        cap = x.capacity

        result[0] += cap
        result[1] += cap unless x.emergency.present?
        next unless x.on_duty
        result[2] += cap
        result[3] += cap unless x.emergency.present?
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

    # Returns the best responder group for the severity.
    #
    # @param string needed_type
    # @param number needed_capacity
    # @return array
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

    # Recursive DP method that ultimately returns an array of responder groups.
    # for example, given responders: [2, 3, 4, 5] and need: 9, this method
    # will return all possible combinations with total capacity that fulfills
    # (and/or exceeds) 9.
    #
    # @param array responders
    # @param number need
    # @return array
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
      choose_best_responder_group(selections)
    end

    # returns the total capacity given an array of responders.
    #
    # @param array responders
    # @return number
    def total_capacity_from_array(responders)
      return 0 unless responders.present?
      total = 0
      responders.each do |x|
        total += x.capacity
      end

      total
    end

    # returns an array of responders that:
    # 1. has the closest total capacity to the severity
    # 2. has the least number of units
    #
    # @param array selections
    # @return array
    def choose_best_responder_group(selections)
      current_minimum = 999
      current_count = 999
      result = nil
      selections.each do |x|
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
