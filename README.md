# Chexin

A tiny valet / coat-check service for hotels and clubs.

## The domain in five lines

1. A **Property** is a hotel, resort, or club, each in its own time zone.
2. **Guests** check items (coats, luggage) at a property, creating a **CheckIn** with a 6-character claim code.
3. Staff hit `POST /check_ins/:id/mark_ready` when an item is ready for pickup.
4. `NotifyGuestJob` texts the guest via a mock Twilio client (nothing is really sent) and records a **NotificationLog** (`sent` / `failed`).
5. `/properties/:slug/activity` shows recent check-ins and their notification history.

## Setup

```sh
bin/setup          # bundle install + db:prepare
bin/rails db:seed  # 4 properties, guests, and check-ins in mixed states
```

## Run

```sh
bin/rails s
```

Then open <http://localhost:3000> and pick a property.

## Test

```sh
bin/rails test
```

## Debugging tip: run the job inline

The mock SMS job runs on the async ActiveJob adapter in development. To step
through it synchronously (e.g. with `debugger`), switch the adapter to inline
in `config/environments/development.rb`:

```ruby
config.active_job.queue_adapter = :inline
```
