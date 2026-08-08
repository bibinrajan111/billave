# BillAve Master Architecture

> **Purpose:** This document is the master reference for the BillAve architecture, folder structure, module boundaries, infrastructure responsibilities, and agreed development direction.
>
> Use this document as the architectural checklist while implementing the project. If implementation conflicts with this document, stop and resolve the architecture decision before adding more feature code.

## 1. Product Direction

BillAve is a Flutter business platform designed to grow into multiple business capabilities without turning the application into a tightly coupled monolith.

The application is built around a **Core + Modules** architecture.

The central rule is:

> **The Core provides capabilities and contracts. Business modules provide business behavior. Modules do not depend directly on other modules.**

The architecture must make it possible to add a new module without rewriting existing modules.

---

## 2. Architectural Layers

```text
BillAve
│
├── Application / Bootstrap
│   └── Starts and assembles the application
│
├── Core
│   ├── Dependency Injection
│   ├── Service Registry
│   ├── Module Registry / Loader
│   ├── Event Bus
│   ├── Navigation
│   ├── Configuration
│   ├── Logging
│   ├── Authentication abstraction
│   ├── Permission abstraction
│   └── Persistence / data-access abstractions
│
├── Modules
│   ├── Customers
│   ├── Inventory
│   ├── Sales
│   ├── Purchases
│   ├── Suppliers
│   └── Reports
│
├── Shared
│   └── Truly reusable UI, helpers, constants and utilities
│
└── Infrastructure
    ├── Local persistence
    ├── Firebase / remote services
    ├── Authentication implementation
    └── Synchronization / external integrations
```

The Core must not contain business-specific rules. Infrastructure implementations must be replaceable behind Core contracts where practical.

---

## 3. Dependency Direction

Allowed direction:

```text
Presentation / Module
        ↓
      Core contracts
        ↓
 Infrastructure implementations
```

A business module may depend on:

- Core contracts
- Core services
- genuinely shared utilities
- its own internal layers

A business module must **not** directly import another business module.

Forbidden example:

```text
Customers → Inventory
```

Preferred approach:

```text
Customers
   ↓
 Core Event Bus / Contract
   ↓
Inventory
```

This keeps modules replaceable and independently evolvable.

---

## 4. Target Repository Structure

The intended long-term structure is:

```text
billave/
│
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DECISIONS.md
│   ├── DEVELOPMENT_RULES.md
│   ├── MODULE_GUIDE.md
│   ├── ROADMAP.md
│   └── BILLAVE_MASTER_ARCHITECTURE.md
│
├── lib/
│   │
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── bootstrap/
│   │   └── billave_bootstrap.dart
│   │
│   ├── core/
│   │   ├── core.dart
│   │   ├── di/
│   │   ├── services/
│   │   ├── modules/
│   │   ├── events/
│   │   ├── navigation/
│   │   ├── config/
│   │   ├── logging/
│   │   ├── auth/
│   │   ├── permissions/
│   │   └── persistence/
│   │
│   ├── modules/
│   │   ├── customers/
│   │   ├── inventory/
│   │   ├── sales/
│   │   ├── purchases/
│   │   ├── suppliers/
│   │   └── reports/
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   ├── helpers/
│   │   ├── constants/
│   │   └── utilities/
│   │
│   └── infrastructure/
│       ├── database/
│       ├── firebase/
│       ├── auth/
│       ├── sync/
│       └── integrations/
│
└── test/
    ├── core/
    ├── modules/
    └── integration/
```

This is the **target architecture**, not a requirement to create every empty directory immediately. Directories should be introduced when their implementation is needed.

---

## 5. Application Bootstrap

`lib/main.dart` is intentionally tiny.

Its responsibility is to start BillAve, not to contain application configuration or business logic.

```text
main.dart
   ↓
runBillAveApp()
   ↓
BillAveBootstrap.initialize()
   ↓
Core initialization
   ↓
Module registration / initialization
   ↓
runApp(BillAveApp)
```

The bootstrap layer orchestrates initialization in a predictable order.

It should not become a dumping ground for services or business logic.

---

## 6. Core Responsibilities

### 6.1 Dependency Injection

The Core owns dependency construction and registration.

Goals:

- avoid hard-coded concrete dependencies
- make services replaceable
- make testing easier
- prevent modules from constructing infrastructure themselves

### 6.2 Service Registry

The Core provides shared services through contracts.

Expected service categories include:

- configuration
- logging
- navigation
- authentication
- permissions
- persistence
- synchronization
- notifications where needed

### 6.3 Module Registry / Loader

The Core owns module registration.

A module should expose its metadata and integration points rather than requiring the Core to know its internal implementation.

Conceptually:

```text
Module
├── identity / name
├── routes
├── menu contribution
├── permissions
├── services
└── initialization
```

Adding a new module should be an additive operation.

### 6.4 Event Bus

Modules communicate through explicit events/contracts instead of direct imports.

Example:

```text
CustomerCreated
      ↓
   Event Bus
   ├── Sales reacts
   ├── Reports reacts
   └── other interested modules react
```

The event system should remain explicit, testable, and type-safe where practical.

### 6.5 Navigation

Navigation belongs to Core infrastructure.

Modules contribute their routes rather than owning the application's global navigation mechanism.

### 6.6 Configuration

Configuration is centralized so modules do not contain environment-specific configuration or hard-coded infrastructure details.

### 6.7 Logging

Logging is a Core capability. Modules should use the shared logging contract instead of creating unrelated logging systems.

### 6.8 Authentication and Permissions

Authentication and authorization/permission contracts belong to Core.

Concrete providers such as Firebase Authentication belong in Infrastructure.

### 6.9 Persistence Abstraction

Modules should depend on persistence/repository contracts rather than directly depending on a specific database implementation.

This preserves the ability to use local persistence and remote synchronization without coupling business logic to the storage technology.

---

## 7. Data Strategy

The agreed direction is **offline-first** rather than making every screen directly dependent on a remote backend.

Conceptually:

```text
Module
   ↓
Repository / Data Contract
   ↓
Local persistence
   ↓
Sync layer
   ↓
Remote backend / Firebase
```

The exact database and synchronization implementation should remain behind abstractions.

Firebase is intended for remote services such as authentication and cloud synchronization. Local persistence is intended to allow the application to remain useful when connectivity is unavailable.

Do not place Firebase SDK calls directly throughout business modules.

---

## 8. Module Architecture

Every business capability is a self-contained module.

Target shape:

```text
lib/modules/<module_name>/
├── data/
├── domain/
├── presentation/
├── services/
├── widgets/
└── <module_name>_module.dart
```

As a module grows, it may add:

```text
models/
repositories/
routes/
```

but those additions remain internal to the module unless an explicit Core/shared contract is required.

### Module rules

1. A module owns its own business logic.
2. A module owns its own data flow.
3. A module owns its own presentation.
4. A module may depend on Core contracts.
5. A module must not import another module's private implementation.
6. A module must not duplicate Core infrastructure.
7. Shared code belongs in `shared/` only when it is genuinely reusable.
8. New modules should be addable without changing existing module implementation.

---

# 9. Business Modules

The following module names are the business scope explicitly established in the project architecture and roadmap.

## 9.1 Customers — FIRST COMPLETE MODULE

```text
lib/modules/customers/
├── data/
├── domain/
├── presentation/
├── services/
├── widgets/
└── customers_module.dart
```

Purpose:

- customer management
- customer-specific business workflows
- customer data and repository contracts
- customer presentation
- customer routes/menu contribution

**Customers is the reference implementation for all future modules.**

The goal is not merely to make Customers work. The goal is to prove the module architecture.

---

## 9.2 Inventory

Purpose:

- inventory-related business workflows
- stock-related data and domain logic
- inventory presentation
- inventory routes and services

Inventory must remain independent from Sales, Purchases, and other modules through Core contracts/events.

---

## 9.3 Sales

Purpose:

- sales workflows
- sales-specific domain and data
- sales presentation
- sales integration through Core events/contracts

Sales must not directly import Inventory, Customers, or Purchases internals.

---

## 9.4 Purchases

Purpose:

- purchase workflows
- purchase-specific domain and data
- purchase presentation
- integration with other business areas through Core contracts/events

---

## 9.5 Suppliers

Purpose:

- supplier management
- supplier-specific data and domain logic
- supplier presentation
- supplier workflows and routes

---

## 9.6 Reports

Purpose:

- reporting workflows
- report-specific presentation and services
- consuming approved Core/module contracts and events

Reports should not reach into another module's private database or implementation.

---

## 10. Module-to-Module Communication

The desired architecture is:

```text
                 ┌──────────────┐
                 │     Core     │
                 │              │
                 │ Event Bus    │
                 │ Contracts    │
                 │ Services     │
                 └──────┬───────┘
                        │
       ┌────────────────┼────────────────┐
       ↓                ↓                ↓
  Customers         Sales           Inventory
       │                │                │
       └────────────────┼────────────────┘
                        │
                     Events
```

A module should not need to know which other modules consume its event.

This is one of the key mechanisms that allows BillAve to grow safely.

---

## 11. Shared Layer

`lib/shared/` is deliberately small.

It is for genuinely reusable things such as:

- reusable UI widgets
- generic helpers
- constants
- utilities

Do not use `shared/` as a place to hide business logic.

If code belongs to Customers, it stays in Customers.

If it belongs to the infrastructure/Core, it stays in Core.

---

## 12. Infrastructure Layer

Infrastructure contains concrete implementations behind Core contracts.

Planned areas:

### Local database

Responsible for local persistence implementation.

### Firebase

Responsible for Firebase-specific integration.

### Authentication

Concrete authentication provider implementation.

### Synchronization

Responsible for coordinating local and remote data synchronization.

### External integrations

Future third-party services should be isolated here rather than spread throughout modules.

---

## 13. What Must NOT Happen

### Do not create this:

```text
Customers → Inventory → Sales → Firebase
```

### Do not create this:

```text
Customers
└── firebase_service.dart
```

if that service bypasses the Core infrastructure contracts.

### Do not create this:

```text
lib/shared/customer_helpers.dart
```

just because the helper is convenient.

Customer-specific logic belongs in the Customers module.

### Do not make `app.dart` the application architecture.

`app.dart` should assemble the application, not contain all services and business logic.

---

## 14. Development Sequence

The agreed implementation order is:

### Phase 1 — Architecture

- architecture documentation
- development rules
- module guide
- roadmap
- architecture decisions

### Phase 2 — Core Infrastructure

- valid Flutter project foundation
- application bootstrap
- dependency injection
- service registry
- module registry
- event bus
- navigation
- shared utilities

### Phase 3 — First Full Module

- Customers module
- Customers data layer
- Customers domain layer
- Customers presentation layer
- Customers services/repositories as required
- Customers module registration

### Phase 4 — Supporting Infrastructure

- local persistence
- authentication
- configuration
- logging
- permissions
- remote/Firebase integration
- synchronization

### Phase 5 — Additional Modules

- Inventory
- Sales
- Purchases
- Suppliers
- Reports

New modules should follow the proven Customers pattern instead of inventing a second architecture.

---

## 15. Current Implementation Status

At the time this document was created:

### Documentation

- [x] Architecture documentation
- [x] Architecture decisions
- [x] Development rules
- [x] Module guide
- [x] Roadmap
- [x] Master architecture document

### Application shell

- [x] `lib/main.dart`
- [x] `lib/app.dart`
- [ ] Complete bootstrap implementation

### Core

- [ ] Dependency injection
- [ ] Service registry
- [ ] Module registry
- [ ] Event bus
- [ ] Navigation abstraction
- [ ] Configuration service
- [ ] Logging service
- [ ] Authentication contract
- [ ] Permission contract
- [ ] Persistence contract

### Modules

- [ ] Customers
- [ ] Inventory
- [ ] Sales
- [ ] Purchases
- [ ] Suppliers
- [ ] Reports

### Infrastructure

- [ ] Local persistence implementation
- [ ] Firebase integration
- [ ] Authentication implementation
- [ ] Synchronization layer
- [ ] External integrations

---

## 16. Definition of a Successful Architecture

BillAve's architecture is successful when we can add a new business module by creating its module folder and registering its public integration points, without rewriting existing modules.

For example:

```text
Today:

Core + Customers

Later:

Core + Customers + Inventory

Later:

Core + Customers + Inventory + Sales

Later:

Core + Customers + Inventory + Sales + Purchases + Suppliers + Reports
```

Existing modules should continue to work because they depend on stable Core contracts rather than on each other's internal implementation.

---

## 17. Architectural Checklist Before Adding Any Feature

Before implementing a new feature, ask:

- Does this belong to Core, a module, Shared, or Infrastructure?
- Is the business logic inside the correct module?
- Am I importing another module directly?
- Could this dependency be expressed as a Core contract or event?
- Am I duplicating an existing Core service?
- Am I putting feature-specific code in `shared/`?
- Can this module still work if another module is removed?
- Can another module be added without changing this module?
- Is persistence accessed through the intended abstraction?
- Is the feature testable without Firebase or another external service?

If the answer to these questions is clear, the implementation is likely following the BillAve architecture.

---

## 18. Source-of-Truth Relationship

This document consolidates the architectural direction already recorded in:

- `docs/ARCHITECTURE.md`
- `docs/DECISIONS.md`
- `docs/DEVELOPMENT_RULES.md`
- `docs/MODULE_GUIDE.md`
- `docs/ROADMAP.md`

Those documents remain useful as focused references. This file is the **single visual map/checklist** for understanding the whole system.

If a future architectural change is agreed, update the relevant decision documentation and this master document together.
