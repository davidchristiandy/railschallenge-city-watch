class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates :capacity, presence: true, inclusion: { in: [1, 2, 3, 4, 5] }
  belongs_to :emergency
end
