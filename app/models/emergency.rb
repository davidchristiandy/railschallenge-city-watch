class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :fire_severity, presence: true, numericality: true
  validates :police_severity, presence: true, numericality: true
  validates :medical_severity, presence: true, numericality: true
  has_many :responders
end
