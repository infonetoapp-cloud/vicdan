# ADR-001: State Management and Dependency Injection
Status: Accepted
Date: 2026-01-28

## Context
- UI creates services and repositories inside widgets.
- Riverpod is already in dependencies and ProviderScope is used in main.dart.
- We need a consistent, testable state flow for offline-first data.

## Decision
- Use Riverpod as the single state management and DI mechanism.
- Define providers at feature boundaries:
  - core: clock, logger, database, location, notification services
  - data: repositories and data sources
  - presentation: StateNotifier/AsyncNotifier for screens
- Widgets become ConsumerWidget/ConsumerStatefulWidget and read state via providers.
- Use AsyncValue for loading/error states.
- Avoid creating services in widget constructors or initState.

## Consequences
- Upfront refactor cost, but improved testability and consistency.
- Providers become the single entry point for dependencies.
- Screen logic moves into controllers (StateNotifier/AsyncNotifier).

## Alternatives Considered
- Keep current approach (fast but brittle, hard to test).
- BLoC/Cubit (adds boilerplate, no current footprint).
- Provider (already superseded by Riverpod in this repo).
