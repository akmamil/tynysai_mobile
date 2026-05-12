# TynysAI Mobile — Agent Instructions

## Architecture

* Use Flutter + Riverpod only
* Preserve existing feature-based structure
* Preserve GoRouter navigation
* Preserve AppTheme/AppColors/AppText system
* Do not introduce Bloc, GetX, or Redux

## UX

* Mobile-first UI
* Diploma MVP scope
* Avoid enterprise overengineering
* Reuse existing widgets when possible

## Coding Rules

* Do not refactor unrelated architecture
* Avoid unnecessary abstraction
* Generate file-by-file patches only
* Keep code compile-safe
* Preserve existing routes/providers unless explicitly requested

## Backend

* Backend may still use mock APIs
* Do not assume production backend exists
* Preserve current API structure
* Use ApiPaths constants

## Preferred Style

* Consistent spacing
* Reusable UI components
* Production-like loading/error states
* Responsive layouts
