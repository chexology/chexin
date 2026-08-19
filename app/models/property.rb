class Property < ApplicationRecord
  has_many :guests, dependent: :destroy
  has_many :check_ins, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :time_zone, presence: true
  validate :time_zone_must_be_valid

  scope :active, -> { where(active: true) }

  private

  # time_zone holds an IANA identifier, e.g. "America/New_York".
  def time_zone_must_be_valid
    return if time_zone.blank?

    errors.add(:time_zone, "is not a valid IANA time zone") if ActiveSupport::TimeZone[time_zone].nil?
  end
end
