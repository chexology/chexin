class Guest < ApplicationRecord
  belongs_to :property
  has_many :check_ins, dependent: :destroy

  validates :name, presence: true
  validates :phone_number, presence: true
end
