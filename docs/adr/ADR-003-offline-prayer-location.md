# ADR-003: Offline Prayer Times and Location Caching
Status: Accepted
Date: 2026-01-28

## Context
- Prayer times are computed on demand with live location.
- No cache or manual location selection exists.
- Offline-first requires reliable access without GPS or network.

## Decision
- Persist last known and user-selected location in the database.
- Support manual city selection (local dataset) as a fallback.
- Compute and cache 30 days of prayer times on location change or month roll.
- Store the calculation profile (method, madhab, adjustments) in the DB.
- UI reads from cache; if missing, show fallback and trigger compute.
- Prayer checkins are keyed by (date, prayer) using the schedule date for that prayer.

## Consequences
- Reliable offline behavior and predictable UI.
- More data to store, but minimal size (30 days per location).
- Requires a background refresh when date crosses month boundary.

## Alternatives Considered
- Compute on every view (fragile offline).
- Keep only next prayer time (not enough for lists and summaries).
