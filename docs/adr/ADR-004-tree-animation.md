# ADR-004: Tree Animation Pipeline
Status: Accepted
Date: 2026-01-28

## Context
- There are multiple tree implementations: Lottie, custom painter, fractal.
- The app needs a single production pipeline for consistent UX.

## Decision
- Use Lottie as the MVP runtime format for the tree.
- Keep a single JSON file with progress controlled by health score.
- Add glow/leaves/ambient effects in Flutter code (not in Lottie).
- Move alternative prototypes to an experiments folder or remove from build.
- Maintain the health score to progress mapping (0.15..1.0) with animation smoothing.

## Consequences
- Faster content iteration with designers.
- Less code complexity in the app layer.
- Reduced interactivity compared to fully procedural animation.

## Alternatives Considered
- Pure custom painter (full control, more engineering effort).
- Rive (interactive, adds dependency and pipeline overhead).
