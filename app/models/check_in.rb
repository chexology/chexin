class CheckIn < ApplicationRecord
  CLAIM_CODE_LENGTH = 6

  belongs_to :property
  belongs_to :guest
  has_many :notification_logs, dependent: :destroy

  enum status: { checked_in: "checked_in", ready: "ready", claimed: "claimed" }

  before_validation :generate_claim_code, on: :create

  validates :item_description, presence: true
  validates :claim_code, presence: true,
                         length: { is: CLAIM_CODE_LENGTH },
                         uniqueness: { scope: :property_id }

  def mark_ready!
    update!(status: :ready, ready_at: Time.current)
    NotifyGuestJob.perform_later(self)
  end

  private

  # Claim codes are short and human-readable, so collisions within a property
  # are possible; keep drawing until we find a free one.
  def generate_claim_code
    return if claim_code.present?

    self.claim_code = loop do
      code = SecureRandom.alphanumeric(CLAIM_CODE_LENGTH).upcase
      break code unless self.class.exists?(property_id: property_id, claim_code: code)
    end
  end
end
