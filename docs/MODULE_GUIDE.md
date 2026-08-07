# BillAve Module Guide

Each business feature in BillAve is implemented as a self-contained module.

## Module Rules

- A module owns its own data, domain, and presentation code.
- A module must not import another module's private implementation.
- A module may depend only on the Core contracts and shared utilities.
- A module should be addable without changing existing module code.

## Expected Module Shape

```text
lib/modules/<module_name>/
├── data/
├── domain/
├── presentation/
├── services/
├── widgets/
└── <module_name>_module.dart
```

## First Module

The first module will be `customers`.

It will become the template for future modules.
