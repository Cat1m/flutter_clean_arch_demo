# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Install dependencies
flutter pub get

# Code generation (DI, models, API clients, env) — run after changing annotated files
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run analysis
flutter analyze

# Run tests
flutter test
flutter test test/path/to/specific_test.dart

# Run integration tests
flutter test integration_test/

# Regenerate Rust FFI bindings (after modifying rust/src/)
flutter_rust_bridge_codegen generate
```

## Architecture

**Clean Architecture** with three layers per feature (`lib/src/features/<feature>/`):

- **`data/`** — Retrofit API clients (`@RestApi`), Freezed models with JSON serialization
- **`repository/`** — Abstract interface + `Impl` that combines API calls, storage, and error mapping
- **`presentation/`** — Pages (scaffold), Views (stateful UI), Cubits (state management with sealed state classes)

**Dependency flow:** Presentation → Repository (abstract) → Data. Cubits depend on repositories, never on datasources directly.

## Core Modules (`lib/src/core/`)

- **`di/`** — GetIt + Injectable. All services/repos/cubits registered via annotations. Access with `getIt<T>()`.
- **`network/`** — Dio client with interceptor chain (order matters): Auth → Token → Logger → Error. `Failure` is a sealed class hierarchy (`ServerFailure`, `ConnectionFailure`, `AuthFailure`, `CacheFailure`, `UnknownFailure`).
- **`auth/`** — Bearer token auth. `TokenInterceptor` handles 401→refresh→retry with a separate Dio instance to avoid loops. `AuthEventService` broadcasts session expiration via streams.
- **`navigation/`** — GoRouter with auth-based redirects. Listens to `LoginCubit` via `StreamListenable` adapter.
- **`env/`** — Uses `envied` package. Secrets in `.env` file (git-ignored), accessed via generated `Env` class.
- **`storage/`** — `SecureStorageService` (tokens, encrypted via `RustCryptoService`) and `SettingsService` (SharedPreferences).
- **`crypto/`** — `RustCryptoService` (AES-256-GCM at rest, backs `SecureStorageService`) and `PinLockService` (PIN + Argon2 key derivation). See `rust/README.md`.
- **`pdf/`** — Standalone PDF module with domain/infrastructure/presentation layers. Uses `pdf` package for generation, Syncfusion for viewing.
- **`ai/`** — `TranslationService` interface backed by Firebase AI Logic (`FirebaseAiTranslationService`, Gemini model). Requires Firebase project + App Check setup — see `lib/src/core/ai/README.md`.
- **`ui/`** — App theme (light/dark), colors, text styles, dimensions, shared widgets.

## Key Patterns

- **Error handling:** `Either<Failure, T>` from `dartz`. Repositories return `Left(failure)` or `Right(data)`. Cubits fold results into sealed state classes.
- **State:** Sealed classes (`AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthFailure`, `AuthSessionExpired`). Use Equatable.
- **Models:** Freezed for immutability + `copyWith`. JSON via `json_serializable`. API clients via Retrofit annotations.
- **Auth annotations:** Custom `@noAuth` and `@userToken` decorators on API endpoints control auth header behavior.

## Code Generation

Five generators are active — after modifying annotated classes, always run `build_runner`:
- **injectable** → `injection.config.dart` (DI container)
- **freezed** → `.freezed.dart` (model equality/copyWith)
- **json_serializable** → `.g.dart` (JSON serialization)
- **retrofit_generator** → `.g.dart` (HTTP clients)
- **envied_generator** → `env.g.dart` (environment variables)

## Rust Integration

`flutter_rust_bridge` bridges Rust code (`rust/src/`) to Dart (`lib/src/rust/`). Build handled by `cargokit` in `rust_builder/`. Config in `flutter_rust_bridge.yaml`. Full docs, structure, and gotchas: `rust/README.md`.

Three demo features live here: AES-256-GCM encryption for `SecureStorageService`, PIN+Argon2 key derivation (`PinLockService`), and a Dart-vs-Rust Fibonacci benchmark (`/rust-benchmark`).

**Important:** `cargokit` builds Rust in the same profile as Flutter — `flutter run` (debug) builds Rust unoptimized, so Rust can appear *slower* than Dart there. Only `flutter run --release` reflects real Rust performance. Also: never mark a slow Rust function `#[frb(sync)]` (blocks the Dart UI thread) — only fast functions (AES-GCM, key/salt generation) should be sync; anything CPU-heavy (Argon2, benchmarks) should stay async.

## Shared API Service

`lib/src/shared/data/remote/api_service.dart` — Central Retrofit client with all endpoints (auth, user, quote). Feature-specific clients in `features/*/data/datasources/` are alternatives.

## Lint Rules

`analysis_options.yaml` enforces strict mode: no implicit casts, no implicit dynamics, `prefer_single_quotes`, `require_trailing_commas`. Comments are in Vietnamese.
