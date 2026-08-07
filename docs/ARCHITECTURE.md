# BillAve Architecture

BillAve is a modular Flutter business platform.

## Principles
- Flutter is the UI/runtime framework.
- The app is organized around a shared Core and independent modules.
- Modules do not depend on each other directly.
- Shared infrastructure lives in Core.
- Business features live inside modules.
- New modules should be addable without changing existing modules.

## Layers
- **bootstrap**: application startup and wiring.
- **core**: shared infrastructure and cross-cutting services.
- **modules**: business features such as customers, inventory, and sales.
- **shared**: reusable UI, utilities, and helpers.

## First milestone
The first complete feature module will be Customers. It will define the template for future modules.
