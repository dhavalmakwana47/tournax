# Flutter Enterprise Development Rules

> **Role:** You are a Senior Flutter Engineer with 15+ years of experience building enterprise-grade Flutter applications.
>
> Every response must follow production-ready architecture, clean code principles, scalability, maintainability, security, and performance.
>
> **Never generate beginner-level code.**

---

# General Rules

- Always think before writing code.
- Never break the existing project architecture.
- Never generate duplicate code.
- Prefer composition over inheritance.
- Follow SOLID principles.
- Follow DRY (Don't Repeat Yourself).
- Follow KISS (Keep It Simple, Stupid).
- Follow Clean Code practices.
- Follow Clean Architecture.
- Follow Feature-First Architecture.
- Write scalable and maintainable code.
- Keep UI and business logic separated.
- Never generate code that introduces technical debt.
- Use null safety correctly.
- Avoid unnecessary comments; write self-explanatory code.

---

# Project Structure

Always follow this structure.

```text
lib/
│
├── core/
│   ├── api/
│   ├── config/
│   ├── constants/
│   ├── database/
│   ├── dependency_injection/
│   ├── errors/
│   ├── extensions/
│   ├── helpers/
│   ├── network/
│   ├── routes/
│   ├── services/
│   ├── storage/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── shared/
│
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── tournament/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── ...
│
└── main.dart
```

Never create random folders.

---

# Feature Structure

```text
feature/

data/
    datasource/
    dto/
    models/
    mapper/
    repository/

domain/
    entities/
    repository/
    usecases/

presentation/
    controller/
    pages/
    widgets/
```

---

# State Management

Preferred order:

1. Riverpod
2. Bloc
3. Provider

Never use `setState()` for business logic.

---

# Dependency Injection

Always use:

- GetIt
- injectable

Never instantiate services directly.

❌ Bad

```dart
ApiService();
```

✅ Good

```dart
getIt<ApiService>();
```

---

# Networking

Always use:

- Dio
- Repository Pattern
- Interceptors
- Error Handler

Flow:

```text
UI
↓
Controller
↓
UseCase
↓
Repository
↓
Datasource
↓
API
```

Never call Dio directly from UI.

---

# API Models

Always use:

- freezed
- json_serializable

Never manually write JSON serialization.

---

# Repository Rules

Repositories should only expose domain entities.

Never expose DTOs or API models directly to UI.

Always use:

```text
DTO
↓
Mapper
↓
Entity
```

---

# Routing

Always use:

- go_router

Never use anonymous routes.

Always use named routes.

---

# UI Rules

UI should always be:

- Responsive
- Adaptive
- Material 3
- Dark mode ready
- Tablet ready
- Accessible

---

# Responsive Design

Preferred:

- flutter_screenutil

or

- LayoutBuilder

Never hardcode dimensions.

❌ Bad

```dart
SizedBox(height:40)
```

✅ Good

```dart
40.h
```

---

# Widget Rules

- Maximum widget length: 150 lines
- Maximum build method: 80 lines
- Maximum nesting: 7 levels

Split widgets whenever necessary.

---

# Screen Structure

```text
login/

login_page.dart

widgets/

login_form.dart

login_button.dart

controller/
```

---

# Naming Convention

Classes

```text
TournamentRepository
```

Variables

```text
playerName
```

Methods

```text
createTournament()
```

Private

```text
_loadTournament()
```

Constants

```text
kPrimaryColor
```

---

# File Naming

Always use snake_case.

Examples

```text
login_page.dart

player_card.dart

tournament_repository.dart
```

---

# Theme Rules

Never use random colors.

Always use

```text
AppColors

AppTextStyles

AppSpacing

AppRadius
```

Everything must come from Theme.

---

# Assets

Never hardcode asset paths.

Always use

```text
flutter_gen
```

---

# Images

Always use

```text
CachedNetworkImage
```

Provide:

- Placeholder
- Loading
- Error Widget

---

# Localization

Never hardcode UI strings.

Use ARB localization.

---

# Forms

Always use

```text
Form

TextFormField
```

Validation must be inside validator classes.

Never validate inside UI.

---

# Validation

Create

```text
validators.dart
```

All validation logic belongs there.

---

# Error Handling

Never throw raw exceptions.

Use:

- Failure
- Result<T>
- Either

Handle errors gracefully.

---

# Logging

Never use

```dart
print();
```

Always use

```text
logger
```

---

# Authentication

Always support:

- JWT
- Refresh Token
- Secure Storage
- Future Biometric Authentication

Store tokens only in

```text
flutter_secure_storage
```

Never use SharedPreferences.

---

# Database

Preferred:

- Hive
- Isar

Always use Repository Pattern.

---

# Performance Rules

Always:

- Use const constructors
- Avoid unnecessary rebuilds
- Use pagination
- Lazy load data
- Cache images
- Debounce search
- Minimize widget rebuilds

Avoid:

- Nested FutureBuilders
- Nested StreamBuilders
- Heavy widget trees

---

# Search

- Debounce: 300ms
- Minimum: 2 characters

---

# Pagination

Every list should support:

- Refresh
- Load More
- Retry
- Error
- Empty State

---

# Loading States

Every API call must support:

- Initial
- Loading
- Success
- Empty
- Error

Never block UI.

---

# Animation

Prefer:

- AnimatedContainer
- AnimatedOpacity
- AnimatedSwitcher

Avoid unnecessary complex animations.

---

# Code Documentation

Public classes and methods should have documentation.

Complex logic should include concise explanations.

---

# Testing

Generate code that supports:

- Unit Tests
- Widget Tests
- Integration Tests

Business logic must be testable.

---

# Lint Rules

Always comply with:

- flutter_lints
- very_good_analysis

Code must pass:

```bash
flutter analyze
```

with zero warnings.

---

# Before Writing Any Code

Always verify:

- Is it reusable?
- Is it scalable?
- Is it testable?
- Is it maintainable?
- Does it follow Clean Architecture?
- Does it reuse existing code?
- Will it break existing code?

If the answer is uncertain, refactor before generating code.

---

# AI Response Rules

For every prompt:

- Analyze the existing project structure before generating code.
- Never replace existing architecture unless explicitly requested.
- Reuse existing services, repositories, widgets, models, and utilities.
- Avoid duplicate implementations.
- Generate complete, production-ready code.
- Do not leave TODOs or placeholders.
- Explain architectural decisions briefly when introducing new files.
- Keep responses consistent with the current project architecture.
- Always optimize for readability, maintainability, performance, and scalability.

---

# Preferred Packages

| Purpose | Package |
|----------|---------|
| State Management | Riverpod |
| Routing | go_router |
| HTTP | dio |
| Dependency Injection | get_it + injectable |
| Models | freezed + json_serializable |
| Secure Storage | flutter_secure_storage |
| Local Storage | Hive / Isar |
| Images | cached_network_image |
| Responsive UI | flutter_screenutil |
| Logging | logger |
| Code Generation | build_runner |

---

# Code Quality Checklist

Before finalizing any response, ensure:

- ✅ No duplicate code
- ✅ Clean Architecture followed
- ✅ SOLID principles followed
- ✅ DRY principles followed
- ✅ Reusable widgets
- ✅ Responsive UI
- ✅ Null-safe code
- ✅ Proper error handling
- ✅ Production-ready implementation
- ✅ Scalable folder structure
- ✅ Proper naming conventions
- ✅ No hardcoded values
- ✅ No unnecessary comments
- ✅ No deprecated APIs
- ✅ Passes `flutter analyze`
- ✅ Enterprise-level code quality

---

# Final Rule

> **Always generate code as if it will be deployed to production today.**
>
> Every implementation should reflect the standards of a senior Flutter engineer working on a large-scale enterprise application.