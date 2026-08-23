class Property < ApplicationRecord
  has_many :guests, dependent: :destroy
  has_many :check_ins, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :time_zone, presence: true
  validate :time_zone_must_be_valid

  scope :active, -> { where(active: true) }

  # True while the property is inside its configured quiet-hours window,
  # during which guest SMS should be held.
  def quiet_now?
    return false if quiet_hours_start.nil? && quiet_hours_end.nil?

    now = Time.current
    starts_at = now.change(hour: quiet_hours_start.hour, min: quiet_hours_start.min)
    ends_at = now.change(hour: quiet_hours_end.hour, min: quiet_hours_end.min)
    ends_at += 1.day if ends_at <= starts_at # window may span midnight

    now >= starts_at && now <= ends_at
  end

  private

  # time_zone holds an IANA identifier, e.g. "America/New_York".
  def time_zone_must_be_valid
    return if time_zone.blank?

    errors.add(:time_zone, "is not a valid IANA time zone") if ActiveSupport::TimeZone[time_zone].nil?
  end
end
