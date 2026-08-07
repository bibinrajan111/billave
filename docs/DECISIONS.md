# Architecture Decisions

## ADR-001: Flutter as the application framework
BillAve will be built in Flutter so the same codebase can target mobile, web, and desktop in the future.

## ADR-002: Modular architecture
The app will be split into a shared Core and independent business modules.

## ADR-003: Core owns infrastructure
Navigation, configuration, logging, service registration, module registration, and data-access abstractions belong in Core.

## ADR-004: Modules are isolated
Modules must not depend directly on each other. Communication should happen through Core interfaces and events.

## ADR-005: Customers first
The Customers module will be the first complete module and the reference template for future modules.
