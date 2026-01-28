# ADR-002: Local Persistence Strategy (Drift + SQLite)
Status: Accepted
Date: 2026-01-28

## Context
- Both drift and sqflite are in dependencies, but only sqflite is used.
- Tasks are stored in SQLite, prayer checkins in SharedPreferences.
- Offline-first needs a single, durable data store with migrations.

## Decision
- Use Drift as the single local DB layer (SQLite backend).
- Remove direct sqflite usage after migration.
- Use SharedPreferences only for tiny settings (onboarding flag, theme).
- All domain data lives in Drift tables with typed models.
- Migrations handled via drift_dev + build_runner.

## Consequences
- Better type safety and migrations, at the cost of codegen.
- Clear separation between domain data and simple preferences.
- Requires a one-time data migration path from existing sqflite data.

## Alternatives Considered
- Sqflite only (manual SQL, harder migrations).
- Hive/ObjectBox (not currently used, different tradeoffs).
