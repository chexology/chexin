# Seeds a small, believable data set: 4 properties in different time zones,
# 8-10 guests each, and ~30 check-ins in mixed states with notification logs
# that match what NotifyGuestJob would have written.
#
# Safe to re-run: it wipes and rebuilds the domain tables.

NotificationLog.delete_all
CheckIn.delete_all
Guest.delete_all
Property.delete_all

PROPERTIES = [
  { name: "Harborview Hotel", slug: "harborview-hotel", time_zone: "America/New_York" },
  { name: "Sundial Resort", slug: "sundial-resort", time_zone: "America/Los_Angeles",
    quiet_hours_start: "21:00", quiet_hours_end: "08:00" },
  { name: "Lakeshore Club", slug: "lakeshore-club", time_zone: "America/Chicago" },
  { name: "Aurora Lodge", slug: "aurora-lodge", time_zone: "Pacific/Honolulu" }
].freeze

GUEST_NAMES = [
  "Maya Chen", "Theo Ramirez", "Priya Patel", "Jonas Berg", "Amara Diallo",
  "Lucas Moreau", "Sofia Rossi", "Daniel Kim", "Nora Haddad", "Felix Wagner",
  "Ines Castillo", "Omar Farouk", "Greta Lindqvist", "Ravi Nair", "Hana Sato",
  "Mateo Alvarez", "Zoe Papadopoulos", "Liam O'Brien", "Aisha Bello", "Petra Novak",
  "Kofi Mensah", "Elena Volkova", "Tariq Aziz", "Ingrid Olsen", "Marco Bianchi",
  "Leila Nasser", "Owen Walsh", "Yuki Tanaka", "Camille Dubois", "Andres Herrera",
  "Freya Jensen", "Samir Chaudhry", "Alice Turner", "Viktor Horvath", "Rosa Delgado",
  "Ben Fischer"
].freeze

ITEMS = [
  "black wool coat", "navy trench coat", "two-piece luggage set", "leather duffel bag",
  "garment bag", "ski jacket", "umbrella and raincoat", "carry-on suitcase",
  "backpack", "fur-lined parka", "suit bag", "rolling suitcase"
].freeze

guest_counts = [9, 10, 8, 9]
name_pool = GUEST_NAMES.dup

properties = PROPERTIES.each_with_index.map do |attrs, i|
  property = Property.create!(attrs)
  guest_counts[i].times do |n|
    property.guests.create!(
      name: name_pool.shift,
      phone_number: format("+1555%03d%04d", i + 1, n + 1)
    )
  end
  property
end

# Mixed check-in states per property: some still checked in, some ready
# (guest notified), some already claimed.
states = %i[checked_in ready claimed]
total = 0

properties.each do |property|
  property.guests.each_with_index do |guest, n|
    next if total >= 30 && n > 5

    state = states[n % states.size]
    created_at = (n + 2).hours.ago

    check_in = property.check_ins.create!(
      guest: guest,
      item_description: ITEMS[(total + n) % ITEMS.size],
      status: :checked_in,
      created_at: created_at
    )
    total += 1

    case state
    when :ready
      check_in.update!(status: :ready, ready_at: created_at + 90.minutes)
    when :claimed
      check_in.update!(status: :claimed, ready_at: created_at + 45.minutes)
    end

    # Logs consistent with NotifyGuestJob: ready/claimed check-ins were
    # notified; one in ten deliveries failed after retries.
    next if check_in.checked_in?

    if total % 10 == 0
      check_in.notification_logs.create!(
        channel: "sms",
        status: :failed,
        detail: "mock carrier timeout",
        created_at: check_in.ready_at + 15.seconds
      )
    else
      check_in.notification_logs.create!(
        channel: "sms",
        status: :sent,
        detail: "sid SM#{SecureRandom.hex(8)}",
        created_at: check_in.ready_at + 2.seconds
      )
    end
  end
end

puts "Seeded #{Property.count} properties, #{Guest.count} guests, " \
     "#{CheckIn.count} check-ins, #{NotificationLog.count} notification logs."
