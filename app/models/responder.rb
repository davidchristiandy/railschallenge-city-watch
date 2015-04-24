class Responder < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates :capacity, presence: true, numericality: true
  belongs_to :emergency
end
