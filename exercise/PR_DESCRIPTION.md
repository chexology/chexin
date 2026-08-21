# Add per-property quiet hours for guest notifications

## Motivation

A couple of hotel partners have asked us to stop texting their guests overnight — nobody wants a "your coat is ready" buzz at 2am. This adds per-property quiet hours: a daily window during which guest SMS are held instead of sent.

## What changed

- New nullable `quiet_hours_start` / `quiet_hours_end` time columns on `properties`. Properties without a window behave exactly as before.
- `Property#quiet_now?` tells you whether a property is currently inside its quiet window (handles windows that span midnight).
- The property settings page gets a "Quiet hours" section so each hotel can manage its own window.
- `NotifyGuestJob` checks it before sending: inside the window we write a `skipped` notification log with detail `quiet hours` and return — no retry churn, and the dashboard shows exactly what happened.
- `rake notifications:flush_held` re-enqueues held notifications once the window is over. We can wire it to a schedule after this merges.
- Small hardening pass on `MockTwilioClient` while I was in there (send timeout, clarified the retry/jitter note).
- Seeded Sundial Resort with a 21:00 → 08:00 window so there's something to poke at locally.

## How to test

1. `bin/rails db:seed`
2. Sundial ships seeded with a 21:00 → 08:00 window; you can tweak it (or add one to any property) from its settings page.
3. Open `/properties/sundial-resort/activity` and mark a check-in ready.
4. During the quiet window you'll see a `skipped — quiet hours` log instead of a sent SMS; outside it, notifications behave as before.
5. `bin/rails test` — new coverage for `quiet_now?` and the skip path.

## Checklist

- [ ] Migration is nullable + backwards compatible
- [ ] No behavior change for properties without quiet hours
- [ ] Tests added and passing
- [ ] Seeds updated
