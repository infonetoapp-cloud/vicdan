# Domain Model v1 (Offline-first)

This model is local-only. Dates use local calendar date strings (YYYY-MM-DD).
Times are stored as HH:mm for the given date and location timezone.

## Core Entities

Settings
- key TEXT PK
- value TEXT

UserProfile
- id TEXT PK
- displayName TEXT
- createdAt TEXT

Location
- id TEXT PK
- name TEXT
- latitude REAL
- longitude REAL
- timezone TEXT
- source TEXT (gps|manual)
- updatedAt TEXT

PrayerCalcProfile
- id TEXT PK
- method TEXT (turkey|isna|mwl|other)
- madhab TEXT (hanafi|shafi)
- highLatRule TEXT
- adjustmentsJson TEXT
- createdAt TEXT

PrayerTimeCache
- id TEXT PK
- date TEXT (YYYY-MM-DD)
- locationId TEXT FK
- calcProfileId TEXT FK
- fajr TEXT
- sunrise TEXT
- dhuhr TEXT
- asr TEXT
- maghrib TEXT
- isha TEXT

PrayerCheckin
- id TEXT PK
- date TEXT (YYYY-MM-DD)
- prayer TEXT (fajr|sunrise|dhuhr|asr|maghrib|isha)
- completedAt TEXT
- source TEXT (manual|notification)

TaskDefinition
- id TEXT PK
- title TEXT
- description TEXT
- category TEXT (ibadet|iyilik|zihin)
- xpValue INTEGER
- isActive INTEGER
- createdAt TEXT

TaskInstance
- id TEXT PK
- taskId TEXT FK
- date TEXT (YYYY-MM-DD)
- isCompleted INTEGER
- completedAt TEXT

QuranProgress
- id TEXT PK
- surah INTEGER
- ayah INTEGER
- page INTEGER
- readAt TEXT
- durationSec INTEGER

TreeSnapshot
- id TEXT PK
- date TEXT (YYYY-MM-DD)
- healthScore INTEGER
- breakdownJson TEXT

## Derived Views (Computed)
- DailySummary(date): tasks, prayers, quran progress, health score
- VicdanScore(date): normalized 0-100 from task instances + prayer checkins + quran progress

## Notes
- TaskDefinition is static; TaskInstance stores daily completion history.
- PrayerTimeCache is generated in 30-day blocks per location and calc profile.
- SharedPreferences is reserved for tiny flags only (onboarding_complete, theme).
