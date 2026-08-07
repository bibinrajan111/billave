# BillAve Architecture

BillAve is a Flutter business platform built around a modular architecture.

## Principles

- The app is divided into a **Core** and **Modules**.
- The **Core** owns shared infrastructure such as configuration, navigation, logging, service registration, module registration, and data access abstractions.
- Each business feature is a self-contained **module**.
- Modules must not depend directly on each other.
- Modules communicate through the Core using explicit interfaces and events.
- New modules should be addable without changing existing module code.

## Initial Scope

The first complete module will be **Customers**.

That module will become the blueprint for future modules such as Inventory, Sales, Purchases, Suppliers, Reports, and others.

## Planned Top-Level Structure

- `lib/core/` — shared infrastructure
- `lib/modules/` — business features
- `lib/shared/` — reusable UI and helpers
- `lib/bootstrap/` — application startup
- `docs/` — architecture and development guidance

## Development Approach

We will build the architecture in layers:

1. Documentation and conventions
2. Core infrastructure
3. Application bootstrap
4. First full module
5. Additional modules based on the same pattern

