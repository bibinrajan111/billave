# BillAve Development Rules

These rules keep the BillAve codebase modular, readable, and easy to extend.

## 1. Core owns infrastructure

Shared concerns belong in `lib/core/`:

- app startup
- configuration
- navigation
- logging
- service registration
- module registration
- event dispatching
- persistence abstractions
- authentication abstractions
- permission abstractions

Business modules must not duplicate these responsibilities.

## 2. Modules are independent

Every business feature must live in its own module under `lib/modules/`.

A module may depend on the Core and on shared abstractions, but it must not import another module directly.

## 3. Shared code must be truly shared

Use `lib/shared/` only for UI components, helpers, constants, and utilities that are genuinely reusable by multiple modules.

Do not put feature-specific logic in `shared`.

## 4. Prefer interfaces over direct implementation coupling

When one part of the app needs a service, it should request an interface or an abstract contract from the Core instead of creating concrete dependencies itself.

## 5. Build one full module first

Customers is the first complete module.

That module defines the pattern for future modules such as Inventory, Sales, Purchases, Suppliers, and Reports.

## 6. Keep the folder structure predictable

Each module should follow the same general shape:

- `data/`
- `domain/`
- `presentation/`
- `services/`
- `widgets/`
- `models/`
- `repositories/`
- `routes/`

The exact substructure can grow later, but the base pattern should stay consistent.

## 7. Make changes in small, meaningful commits

Each commit should represent a logical step in the architecture, not a random mix of unrelated files.

