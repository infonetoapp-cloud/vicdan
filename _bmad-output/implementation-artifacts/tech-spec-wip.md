---
title: 'Amin Halkası (Social Prayer Network)'
slug: 'amin-halkasi'
created: '2026-01-29'
status: 'in-progress'
stepsCompleted: [1]
tech_stack: ['Flutter', 'Firebase Firestore', 'Riverpod']
files_to_modify: 
  - 'lib/features/social'
  - 'lib/features/home/presentation/screens/home_screen.dart'
code_patterns: ['Repository Pattern', 'Riverpod Providers', 'Clean Architecture']
test_patterns: ['Widget Tests', 'Unit Tests']
---

# 1. Overview

## Problem Statement
Users currently practice spirituality in isolation. There is a need for a communal space where they can share their burdens and spiritual requests (Dua) and receive support from others without exposing their full identity if they choose not to.

## Solution
"Amin Halkası" is a social feed within the application where users can:
1.  **Request Dua:** Post a prayer request (optionally anonymous).
2.  **Support Others:** View a feed of others' prayers and tap "Amin" to show support.
3.  **Receive Support:** See how many people have said "Amin" to their prayer.
4.  **Feel Connected:** A "Digital Mahya" or visual representation of the collective spiritual energy.

## Scope
### In Scope
-   **Prayer Feed UI:** Infinite scroll list of prayer requests.
-   **Create Request UI:** Form to input prayer text and toggle anonymity.
-   **Amin Interaction:** Tapping "Amin" increments a counter globally.
-   **My Prayers:** View list of own requests and their Amin counts.
-   **Firebase Integration:** Firestore collection `prayer_requests` and `amin_interactions`.
-   **Moderation (Local Admin):** A fast, local HTML/JS admin dashboard to approve/reject/delete prayer requests directly from the desktop.

### Out of Scope
-   **Comments/Replies:** To prevent toxicity, only "Amin" interaction is allowed.
-   **Direct Messaging:** No user-to-user chat.
-   **Push Notifications (Phase 2):** Not in MVP unless simple topic subscription.

# 2. Context for Development

## Technical Constraints
-   **Firebase Firestore:** Use for real-time data sync.
-   **Offline-First:** Must handle offline state gracefully (optimistic UI updates).
-   **Design:** Must match the existing "Vicdan" verification aesthetic (Dark mode, premium feel).

## Architecture
-   **Clean Architecture:**
    -   `domain/entities`: `PrayerRequest`, `Amin`
    -   `data/models`: `PrayerRequestModel` (Firestore JSON parsing)
    -   `data/repositories`: `SocialRepositoryImpl`
    -   `presentation/providers`: `prayerFeedProvider`, `createPrayerProvider`

## Data Model (Firestore)

### Collection: `prayer_requests`
-   `id` (string)
-   `userId` (string)
-   `userDisplayName` (string, masked if anonymous)
-   `content` (string)
-   `aminCount` (int)
-   `createdAt` (timestamp)
-   `isAnonymous` (bool)
-   `theme` (string) - simpler usage of "Kandil" or "General" card styles.

### Collection: `amin_interactions` (Sub-collection or Top-level)
-   `requestId` (string)
-   `userId` (string)
-   `timestamp` (timestamp)
