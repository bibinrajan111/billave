# BillAve — Master Architecture v2

> **Status:** Architecture baseline / future-reference document  
> **Purpose:** Authoritative product, architecture, module, and engineering blueprint for BillAve.  
> **Scope:** Long-term international restaurant operating platform.  
> **Implementation principle:** Build the foundation so future capabilities are added primarily by extension (new modules, providers, plugins, configuration) rather than by rewriting stable modules.

---

## 1. Product Vision

BillAve is intended to become a **multi-tenant, offline-first, modular, event-driven Restaurant Operating System** for Android, iOS, Web, Windows, and macOS.

The long-term platform supports:

- Restaurant operations
- Menu and QR ordering
- Table management
- Kitchen operations
- Reservations
- Payments
- Inventory and recipes
- Customers and loyalty
- Analytics
- AI assistance
- Multi-language menus
- Multi-currency operation
- Country-specific tax and regulatory configuration
- Country-specific payment providers
- Enterprise administration
- SaaS subscriptions
- Plugins and integrations

The initial commercial launch should support **one country first**, while the architecture is designed so additional countries can be introduced through country configuration, tax rules, payment adapters, localization, and compliance work rather than a new codebase.

---

## 2. Core Engineering Philosophy

### 2.1 Open for extension, closed for unnecessary modification

New capabilities should normally be added by:

1. Creating a module/plugin.
2. Implementing stable interfaces.
3. Registering the module/provider.
4. Publishing or consuming domain events.
5. Adding configuration.

Avoid modifying unrelated existing modules to introduce a new capability.

### 2.2 Modules must know as little as possible about each other

A module must not directly depend on the internal implementation of another module.

Prefer:

```text
Module A
   -> Event Bus -> Module B/C/D

Module A
   -> Interface -> Provider implementation
```

Avoid:

```text
Orders -> InventoryService -> KitchenService -> LoyaltyService
```

### 2.3 Configuration over hardcoding

Business rules that vary by country, tenant, restaurant, branch, plan, or feature should be configurable.

Do not hardcode values such as VAT rates, currency symbols, payment providers, reservation deposits, or feature availability inside business logic.

Security invariants, data integrity rules, and core architectural constraints remain enforced in code.

### 2.4 Offline first

Restaurant-critical workflows must continue to operate when connectivity is temporarily unavailable.

Use local persistence and a durable sync queue. Cloud connectivity is an enhancement, not a prerequisite for basic restaurant operation.

### 2.5 Secure by default

Never trust a Flutter client. All authorization-sensitive operations require server-side enforcement.

### 2.6 API/provider abstraction

External vendors must be behind interfaces so a provider can be replaced without changing domain modules.

Examples:

- `PaymentProvider`
- `AIProvider`
- `TaxProvider`
- `NotificationProvider`
- `StorageProvider`
- `AuthenticationProvider`

### 2.7 Documentation first

Architecture, contracts, decisions, events, configuration keys, and important workflows must be documented before or alongside implementation.

---

## 3. Platform Layers

BillAve is divided conceptually into four layers:

```text
Applications
    ↓
Domain / Business Modules
    ↓
Core Platform
    ↓
Infrastructure / Providers
```

### Applications

- Restaurant application
- Customer ordering experience
- Admin dashboard
- Platform dashboard

### Domain modules

- Menu
- Orders
- Tables
- Reservations
- Kitchen
- Inventory
- Customers
- Employees
- Loyalty
- Analytics
- etc.

### Core platform

- Dependency injection
- Event bus
- Configuration engine
- Permissions
- Feature flags
- Plugin system
- Repository contracts
- Error/result system
- Logging/auditing
- Synchronization contracts
- Identity and tenant context

### Infrastructure/providers

- SQLite
- Firebase
- Payment gateways
- AI providers
- Notification providers
- External integrations

---

## 4. Core Engines

The Core is built before business features.

### 4.1 Dependency Injection / Service Registration

Responsible for registering interfaces and implementations without hardcoding concrete dependencies throughout the application.

Example:

```text
PaymentProvider -> StripePaymentProvider
AIProvider      -> GeminiProvider
OrderRepository -> OfflineFirstOrderRepository
```

### 4.2 Event Bus

A central event mechanism for loose coupling.

Events are immutable facts such as:

- `RestaurantCreated`
- `BranchCreated`
- `MenuCreated`
- `MenuUpdated`
- `OrderCreated`
- `OrderSubmitted`
- `OrderReady`
- `OrderCompleted`
- `PaymentCompleted`
- `ReservationConfirmed`
- `InventoryReduced`
- `CustomerCreated`
- `EmployeeCreated`

A publisher must not need to know which modules consume an event.

### 4.3 Configuration Engine

Hierarchical configuration:

```text
Platform
  ↓
Country
  ↓
Tenant
  ↓
Restaurant
  ↓
Branch
  ↓
User/device (only where appropriate)
```

Configuration values inherit downward and can be overridden only where policy permits.

### 4.4 Permission Engine

Fine-grained permissions instead of hardcoded role checks.

Examples:

```text
menu.create
menu.edit
menu.delete
order.create
order.cancel
order.refund
payment.refund
reservation.manage
inventory.manage
employee.manage
report.view
configuration.manage
```

Roles are collections of permissions.

### 4.5 Feature Flag Engine

Controls whether a capability is available without embedding feature rollout logic throughout modules.

Possible scopes:

- Platform
- Country
- Subscription plan
- Tenant
- Restaurant
- Branch

Feature flags do not replace authorization or subscription entitlements.

### 4.6 Plugin Engine

Provides lifecycle and registration contracts for optional capabilities.

Potential plugins:

- Inventory
- Loyalty
- Delivery
- Payroll
- Accounting
- Marketing
- Advanced analytics
- Digital signage
- External integrations

### 4.7 Error / Result System

Standardize failures and success results.

Potential failure categories:

- Validation
- Authentication
- Authorization
- Network
- Persistence
- Synchronization
- Payment
- Configuration
- External provider
- Unknown/internal

### 4.8 Logging / Audit Engine

Operational logs and business audit records are separate concepts.

Audit records should capture important mutations such as:

- Who
- What changed
- When
- Tenant/restaurant/branch context
- Old value where appropriate
- New value where appropriate
- Reason where required

### 4.9 Identity / Tenant Context

Every request, command, event, and repository operation must have an appropriate tenant/context boundary.

---

## 5. Multi-Tenant Model

Primary hierarchy:

```text
Platform
  ↓
Tenant
  ↓
Restaurant Group / Restaurant
  ↓
Branch
  ↓
Floor
  ↓
Section
  ↓
Table
```

A tenant must never be able to access another tenant's data.

Tenant isolation is enforced server-side and reflected in repository/query boundaries.

Every business entity receives a stable unique ID. Names are display data, never identity.

---

## 6. Organization and Location Engine

Support future enterprise structures such as:

- Platform offices
- Regions
- Support teams
- Restaurant groups
- Restaurant branches
- Floors
- Sections
- Tables

Use IDs and parent relationships rather than hardcoded location assumptions.

Hierarchical category/location structures should use a parent reference where appropriate so future nesting does not require schema redesign.

---

## 7. Internationalization Framework

International support is a platform capability, not a collection of country-specific forks.

### Country configuration should cover

- ISO country code
- Phone country code
- Currency
- Default language(s)
- Time zone rules
- Address format
- Number format
- Date/time format
- Tax framework
- Receipt requirements
- Payment provider availability
- Regional configuration

### Important

Supporting a country means more than translating the UI. Tax, payments, receipts, privacy, fiscalization, employment rules, and other legal requirements must be independently validated before commercial activation.

---

## 8. Currency and Money

Never store presentation strings such as `€12.50` as the monetary source of truth.

Use a money value object containing:

```text
amount in minor units where appropriate
currency code
```

Examples:

```text
1250 EUR
1250 USD
1250 INR
```

Formatting is performed by the localization/currency layer.

Avoid floating-point arithmetic for financial values.

---

## 9. Tax Engine

Tax logic must be provider/rule based rather than hardcoded into invoices or menu code.

Conceptual model:

```text
Country
  ↓
Tax framework
  ↓
Tax profile/category
  ↓
Tax rule/version
  ↓
Calculated tax
```

Potential concepts:

- VAT
- GST
- Sales tax
- Multiple rates
- Tax-inclusive prices
- Tax-exclusive prices
- Dine-in rules
- Takeaway rules
- Delivery rules
- Alcohol rules
- Service charges
- Exemptions

Tax rules must be versioned and auditable.

Rates and legal rules must be verified against current local law before activation.

---

## 10. Payment Architecture

The business domain must depend on a payment abstraction, not a specific gateway.

```text
PaymentProvider
   ├── Stripe
   ├── Mollie
   ├── Adyen
   ├── Razorpay
   ├── PayPal
   └── Future providers
```

Provider availability can be configured by country and tenant, subject to platform support and legal/payment-provider requirements.

Operations should cover as required:

- Authorization
- Capture
- Refund
- Partial refund
- Cancellation
- Payment status
- Webhooks
- Reconciliation
- Failure handling

Payment secrets remain server-side. Never embed private provider credentials in Flutter clients.

---

## 11. SaaS Subscription and Entitlement Engine

Separate restaurant customer payments from BillAve's own subscription billing.

Potential plans:

- Free
- Starter
- Professional
- Business
- Enterprise

Capabilities are controlled by entitlements.

Example:

```text
AI analytics -> Pro
Multiple branches -> Business
Advanced inventory -> Enterprise
```

Feature flags determine technical rollout; entitlements determine whether a customer has purchased access.

---

## 12. Menu Module

Menu hierarchy:

```text
Menu
  ↓
Category
  ↓
Subcategory(s)
  ↓
Menu Item
  ↓
Variant
  ↓
Modifier Group
  ↓
Modifier
```

Menu items may contain:

- ID
- Name
- Description
- Images
- Price
- Tax category
- Allergens
- Ingredients
- Availability
- Preparation time
- Calories/nutrition where supported
- Dietary attributes
- Translations
- Modifiers

The module owns menu domain behavior and does not directly own orders, inventory, payments, or AI.

---

## 13. Category Hierarchy

Use a parent-child model:

```text
id
parentId
name
metadata
```

This permits future nesting without hardcoding a fixed number of category levels.

The same pattern can be used for other hierarchical business structures where appropriate.

---

## 14. Translation / Multi-Language Menu

Store translations as data rather than generating them on every request.

Customer language can be inferred from:

- Device/browser locale
- QR/deep-link preference
- Explicit language selection

AI can generate an initial translation, which is then stored and optionally reviewed by the restaurant.

AI should not be called every time a customer opens a menu.

---

## 15. QR Menu Module

QR identifiers should reference a controlled restaurant/table context rather than contain sensitive business data.

Typical flow:

```text
QR
 ↓
Restaurant/Branch/Table context
 ↓
Customer session
 ↓
Menu
```

QR codes must be revocable/rotatable where security requires it.

---

## 16. Customer Ordering Module

Flow:

```text
Scan QR
 ↓
Open menu
 ↓
Select items
 ↓
Modifiers
 ↓
Review
 ↓
Submit order
 ↓
Restaurant receives order
```

Support table-level sessions so multiple guests can participate in a shared table order.

---

## 17. Order Module

Orders use explicit state transitions rather than scattered booleans.

Example:

```text
Draft
 ↓
Submitted
 ↓
Accepted
 ↓
Preparing
 ↓
Ready
 ↓
Served
 ↓
Paid
 ↓
Closed
```

Cancellation/refund states must be explicitly modeled.

The Orders module publishes events. It does not directly call Inventory, Loyalty, Analytics, Kitchen, or Marketing implementations.

---

## 18. Table Management Module

Tables have:

- ID
- Branch
- Floor
- Section
- Capacity
- Status
- QR reference
- Current session reference

Table states and transitions must be controlled.

---

## 19. Kitchen Display System

Kitchen receives order-related events and maintains its own operational view.

Capabilities:

- Kitchen queues
- Stations
- Preparation timers
- Priorities
- Item status
- Order status
- Delayed-order alerts

The kitchen UI should not directly mutate the Orders database without going through defined application/domain commands.

---

## 20. Reservation Module

Capabilities:

- Online reservation
- Availability
- Time slots
- Party size
- Table assignment
- Confirmation
- Cancellation
- Rescheduling
- Waiting list
- Deposits
- Reminders
- Booking window
- Grace period
- No-show status

Example state machine:

```text
Requested
 ↓
Confirmed
 ↓
CheckedIn
 ↓
Completed
```

Alternative terminal states:

```text
Cancelled
NoShow
```

---

## 21. Reservation Fraud / No-Show Controls

Use configurable risk controls rather than relying on a single mechanism.

Possible controls:

- Phone verification/OTP
- Deposits
- Payment authorization where supported
- Cancellation policies
- No-show history
- Booking limits
- Manual confirmation for high-risk reservations
- Waiting-list fallback

AI may assist with recommendations, but should not be the sole authority for blocking customers.

---

## 22. Inventory Module

Inventory should support:

- Ingredients
- Units
- Stock levels
- Suppliers
- Purchase orders
- Stock adjustments
- Waste
- Expiry
- Low-stock thresholds

Inventory changes can be triggered by business events such as completed/consumed orders according to the restaurant's configured stock policy.

---

## 23. Recipe Module

A menu item can reference a recipe:

```text
Margherita Pizza
  ├── Flour
  ├── Cheese
  ├── Tomato
  └── Oil
```

Recipe quantities and units must be versioned where needed.

Inventory reacts to order/consumption events rather than the Menu module directly manipulating stock.

---

## 24. Supplier and Purchasing Module

Future capabilities:

- Suppliers
- Supplier products
- Purchase prices
- Purchase orders
- Receiving
- Supplier invoices
- Price history

---

## 25. Waste Module

Track:

- Spoilage
- Expiry
- Overproduction
- Damage
- Manual waste

Waste data feeds analytics and future forecasting.

---

## 26. Customer Module

Customer profile may contain:

- ID
- Name
- Phone
- Email
- Preferences
- Consent records
- Visit history
- Order history
- Reservation history
- Loyalty state

Privacy, consent, retention, and deletion rules are first-class requirements.

---

## 27. Loyalty Module

Possible models:

- Points per currency unit
- Visit-based rewards
- Tiered loyalty
- VIP levels
- Coupons
- Birthday rewards
- Expiring points

The loyalty module listens to appropriate business events such as completed orders/visits.

---

## 28. Employee Module

Employee records include:

- Identity
- Role
- Permissions
- Branch
- Department
- Status
- Employment metadata as legally appropriate

Do not mix employment-law logic into the basic identity model; use country-specific integrations/modules where needed.

---

## 29. Time and Shift Module

Future capabilities:

- Clock in/out
- Breaks
- Attendance
- Shifts
- Availability
- Shift swaps
- Staffing reports

Payroll should initially be an integration/plugin rather than a full accounting/payroll engine.

---

## 30. Notification Module

Use a provider abstraction:

```text
NotificationProvider
   ├── Push
   ├── Email
   ├── SMS
   ├── WhatsApp
   └── Future channels
```

Notifications are generally triggered by events and governed by consent/preferences.

---

## 31. Marketing Module

Future capabilities:

- Campaigns
- Customer segments
- Offers
- Coupons
- Automated journeys
- Email/SMS/WhatsApp/push integrations

Marketing automation must respect consent and applicable privacy/communications law.

---

## 32. Delivery Module

Support business modes:

- Dine-in
- Pickup
- Takeaway
- Delivery
- Catering

Delivery providers should be integrations/plugins rather than embedded assumptions.

---

## 33. Digital Signage Module

Displays:

- Today's specials
- Promotions
- Menu highlights
- Queue information

It should react to menu/configuration events rather than require changes to the Menu module.

---

## 34. Analytics Module

Operational metrics:

- Revenue
- Orders
- Average order value
- Popular items
- Busy hours
- Table utilization
- Customer retention
- Payment methods
- Reservation cancellations
- No-shows
- Kitchen delays
- Food waste
- Inventory trends

Analytics should avoid forcing every screen interaction to generate an expensive cloud read.

---

## 35. Restaurant Brain / AI Analytics

AI may summarize restaurant data and provide recommendations such as:

- Busy-period forecasts
- Potential ingredient demand
- Sales anomalies
- Menu performance insights
- Waste observations

AI recommendations should be explainable where practical and should not silently execute high-impact financial actions.

---

## 36. AI Assistant

Natural-language commands are converted into structured, validated intents.

Example:

User:

```text
Remove Pizza Pepperoni today.
```

AI returns something conceptually like:

```json
{
  "action": "disable_menu_item",
  "itemId": "...",
  "until": "..."
}
```

Application validates:

- Entity exists
- Correct tenant/restaurant
- User permission
- Action allowed
- Parameters valid

Only then does application code execute the mutation.

**AI never receives unrestricted database write authority.**

---

## 37. AI Provider Layer

Use:

```text
AIProvider
   ├── Gemini
   ├── OpenAI
   ├── Claude
   ├── Other providers
   └── Local model implementations where appropriate
```

Provider choice can be configured where commercially and technically appropriate.

AI output must be validated before becoming domain commands.

---

## 38. AI Cost Control

Do not use AI for deterministic operations.

Good AI uses:

- Translation
- Natural-language commands
- Summaries
- Recommendations
- Forecasting
- Marketing assistance

Bad AI uses:

- Reading a price that already exists in the database
- Calculating a tax that a deterministic tax engine can calculate
- Updating table status
- Processing payments

Cache/store reusable AI output whenever possible.

---

## 39. Platform Administration

Platform dashboard should manage:

- Tenants
- Restaurants
- Countries
- Configuration
- Payment providers
- AI providers
- Feature flags
- Entitlements
- Subscriptions
- Support
- Audit logs
- Usage
- AI cost
- Storage
- System health
- Plugins

---

## 40. Restaurant Administration

Restaurant dashboard should provide:

- Overview
- Menu
- Orders
- Tables
- Kitchen
- Reservations
- Customers
- Employees
- Inventory
- Loyalty
- Reports
- Payments
- Settings
- Integrations
- AI assistant

---

## 41. Plugin Marketplace

Long-term marketplace for first-party and possibly third-party extensions.

Potential extensions:

- Accounting
- Payroll
- Delivery
- CRM
- Marketing
- Advanced analytics
- Regional payment systems
- Country-specific integrations

Plugin security, permissions, version compatibility, and tenant isolation are mandatory before allowing third-party extensions.

---

## 42. API-First Architecture

Important platform capabilities should be represented through stable application/domain contracts and API boundaries so future integrations can be added without coupling external systems directly to internal database structures.

Potential integrations:

- Accounting
- ERP
- Delivery
- Payroll
- CRM
- External POS
- Data export

Version APIs and contracts.

---

## 43. Repository Architecture

UI and domain logic must not directly depend on Firebase SDK calls.

Conceptual flow:

```text
UI
 ↓
Application Use Case
 ↓
Repository Interface
 ↓
Offline-first Repository
 ├── SQLite/local data source
 └── Sync/remote data source
          ↓
       Firebase
```

This keeps infrastructure replaceable.

---

## 44. Offline-First Data Architecture

Restaurant device:

```text
Flutter
 ↓
Application/domain
 ↓
Repository
 ↓
SQLite
 ↓
Sync Queue
 ↓
Sync Engine
 ↓
Firebase
```

Local writes should be durable.

The sync engine must support:

- Retry
- Idempotency
- Ordering where required
- Partial failure recovery
- Conflict handling
- Backoff
- Offline duration
- Crash recovery
- Sync status

---

## 45. Conflict Resolution

Do not assume one universal conflict policy.

Define policies by entity/operation.

Questions that must be answered:

- What if two devices edit the same menu item?
- What if a price changes offline on two devices?
- What if an order is created while offline?
- What if a payment succeeds remotely but local state is stale?
- What if the app crashes during sync?

Financial operations require idempotency and server-side reconciliation.

---

## 46. State Machines

Use explicit state machines for important workflows.

### Order

```text
Draft → Submitted → Accepted → Preparing → Ready → Served → Paid → Closed
```

### Reservation

```text
Requested → Confirmed → CheckedIn → Completed
```

Terminal alternatives:

```text
Cancelled
NoShow
```

### Payment

```text
Pending → Authorized → Captured
```

With failure/cancellation/refund states as appropriate.

---

## 47. Security Architecture

Required principles:

- Tenant isolation
- Least privilege
- Server-side authorization
- Secure secrets
- Input validation
- Rate limiting
- App/device attestation where appropriate
- Encryption in transit
- Encryption at rest through platform/provider controls
- Secure session management
- Dependency vulnerability management
- Auditability

Never trust client-provided tenant IDs, permissions, prices, taxes, or payment states without server-side validation.

---

## 48. Firebase Architecture

Firebase may provide:

- Authentication
- Firestore
- Storage
- Cloud Functions
- Cloud Messaging
- Crashlytics
- Analytics
- Remote Config where appropriate
- Hosting where appropriate

Firebase is infrastructure, not the domain architecture.

Business modules should depend on interfaces/repositories rather than Firebase APIs directly.

---

## 49. Firebase Security Rules

Rules must enforce tenant and user boundaries at the data layer.

Conceptually:

```text
Who is this user?
Which tenant are they in?
Which restaurant/branch are they allowed to access?
Which operation are they performing?
Is the operation allowed?
```

Security Rules are one layer of defense; sensitive operations may also require trusted backend validation.

---

## 50. Data Retention and Privacy

The platform must support policies for:

- Customer data retention
- Order/receipt retention
- Reservation data
- Employee data
- Audit logs
- Marketing consent
- Data export
- Deletion requests
- Regional privacy requirements

Country-specific legal requirements must be verified before activation.

---

## 51. Backup and Disaster Recovery

Plan for:

- Automated backups
- Restore procedures
- Point-in-time recovery where supported
- Recovery testing
- Data retention
- Disaster recovery documentation

A backup is not considered reliable until restore procedures have been tested.

---

## 52. Observability

Monitor:

- Application crashes
- Performance
- Backend errors
- Sync failures
- Payment failures
- Provider failures
- AI usage/cost
- Storage growth
- Database usage
- Queue depth
- Critical business failures

Use structured logs and correlation/request IDs where practical.

---

## 53. Versioning

Version:

- Database schema
- SQLite migrations
- APIs
- Events/contracts
- Configuration schemas
- Plugins
- Tax rules
- Receipt templates
- AI prompts/structured output schemas

Breaking changes require explicit migration/version strategy.

---

## 54. UI / Design System

Create a shared UI kit for:

- Buttons
- Forms
- Tables
- Dialogs
- Cards
- Navigation
- Charts
- Empty states
- Loading states
- Error states

Support:

- Responsive layouts
- Accessibility
- Localization
- RTL
- Light/dark themes
- Restaurant branding

---

## 55. Applications / Platforms

Target:

- Android
- iOS
- Web
- Windows
- macOS

Flutter is the primary cross-platform client technology, with platform-specific functionality isolated behind platform interfaces where necessary.

Potential application surfaces:

```text
apps/
  restaurant_app/
  customer_app/
  admin_dashboard/
  platform_dashboard/
```

The exact split can evolve without changing the domain modules.

---

## 56. Testing Strategy

Required test levels:

### Unit tests

Domain logic, value objects, state machines, configuration, tax calculations, permissions.

### Widget tests

Reusable UI components and screen behavior.

### Integration tests

Feature workflows.

### End-to-end tests

Critical user journeys.

### Offline tests

Device offline/online transitions, queued writes, retries, recovery.

### Sync tests

Conflict and partial-failure scenarios.

### Security tests

Tenant isolation and authorization.

### Payment tests

Provider sandbox environments and webhook behavior.

---

## 57. CI/CD

Recommended pipeline:

```text
Commit
 ↓
Format
 ↓
Static analysis
 ↓
Unit tests
 ↓
Widget/integration tests
 ↓
Security/dependency checks
 ↓
Build
 ↓
Deploy to test/staging
 ↓
Production approval/deployment
```

Environments:

```text
Development
Testing
Staging
Production
```

Never use production secrets in development.

---

## 58. Secrets Management

Never commit:

- Private API keys
- Payment secrets
- Server credentials
- Private signing keys
- Service-account credentials

Client-safe configuration and server secrets must be treated differently.

---

## 59. Recommended Monorepo Direction

Target structure:

```text
billave/
├── apps/
│   ├── restaurant_app/
│   ├── customer_app/
│   ├── admin_dashboard/
│   └── platform_dashboard/
│
├── packages/
│   ├── core/
│   ├── configuration/
│   ├── event_bus/
│   ├── sync/
│   ├── logger/
│   ├── permissions/
│   ├── ui_kit/
│   └── shared/
│
├── modules/
│   ├── menu/
│   ├── orders/
│   ├── reservations/
│   ├── inventory/
│   ├── payments/
│   ├── kitchen/
│   ├── customers/
│   ├── employees/
│   ├── loyalty/
│   └── analytics/
│
├── providers/
│   ├── payment/
│   ├── tax/
│   ├── ai/
│   └── notifications/
│
├── functions/
├── docs/
├── scripts/
└── tools/
```

The exact Dart package layout can be adjusted during the architecture implementation phase; the dependency direction must remain the important invariant.

---

## 60. Module Contract

Every business module should define:

```text
module/
├── domain/
├── application/
├── infrastructure/
├── presentation/
├── events/
├── repositories/
├── models/
└── tests/
```

A module must document:

1. Purpose
2. Owned entities
3. Commands/use cases
4. Published events
5. Consumed events
6. Required interfaces
7. Configuration keys
8. Permissions
9. Persistence requirements
10. Synchronization requirements
11. Error cases
12. Tests

---

## 61. How New Modules Must Be Added

When adding a future capability such as Digital Signage:

```text
1. Define the module boundary.
2. Define its domain entities/use cases.
3. Define required interfaces.
4. Define events it publishes.
5. Define events it consumes.
6. Define configuration.
7. Define permissions.
8. Define local/cloud persistence needs.
9. Register the module/plugin.
10. Add tests.
```

Do not modify unrelated modules merely to make the new module work.

Example:

```text
MenuUpdated
    ↓
Event Bus
    ↓
Digital Signage Module
```

The Menu module does not need to know Digital Signage exists.

---

## 62. What “Future Proof” Means in BillAve

Future proof does **not** mean never changing code.

It means:

- New features usually arrive as new modules.
- New payment providers implement an interface.
- New AI providers implement an interface.
- New countries add configuration/rules/providers.
- New integrations become plugins.
- New workflows use events and state machines.
- Infrastructure can be replaced behind repositories/providers.

Existing stable modules may still require intentional changes for bug fixes, security patches, migrations, or genuine domain changes.

---

## 63. What Should NOT Be Built as Configuration

Do not turn every line of application behavior into a database setting.

Keep these in code:

- Core security invariants
- Data integrity constraints
- Permission enforcement
- State-machine invariants
- Authentication protocol behavior
- Financial correctness guarantees
- Sync correctness
- Plugin sandbox/security boundaries

Configuration is for controlled business variability, not arbitrary executable behavior.

---

## 64. Development Order

### Phase 0 — Documentation and Architecture

- Product requirements
- Architecture
- Module boundaries
- Dependency rules
- Event catalog
- Configuration catalog
- Permission catalog
- Database/domain model
- Security model

### Phase 1 — Core

- DI
- Event Bus
- Configuration Engine
- Permissions
- Feature Flags
- Plugin contracts
- Logger
- Error/Result system
- Identity/Tenant context
- Repository contracts

### Phase 2 — Local Platform

- SQLite
- Migrations
- Local repositories
- Offline queue
- Sync contracts
- Conflict strategy
- Background sync

### Phase 3 — Cloud

- Firebase project
- Authentication
- Firestore
- Storage
- Cloud Functions
- Security Rules
- App Check
- Crashlytics/monitoring

### Phase 4 — Organization

- Tenant
- Restaurant
- Branch
- Floor
- Section
- Table
- Employees/roles

### Phase 5 — Menu

- Menu
- Categories
- Items
- Modifiers
- Pricing
- Taxes
- Translations

### Phase 6 — QR

- QR generation
- Table context
- Customer session
- QR menu
- Ordering

### Phase 7 — Orders/Kitchen

- Order state machine
- Kitchen display
- Table sessions
- Order events

### Phase 8 — Payments

- Payment abstraction
- First-country provider
- Webhooks
- Refunds
- Reconciliation

### Phase 9 — Reservations

- Availability
- Booking
- Deposits
- Reminders
- No-show controls
- Waiting list

### Phase 10 — Inventory

- Ingredients
- Units
- Recipes
- Stock
- Purchasing
- Waste

### Phase 11 — Customers/Loyalty

- Profiles
- Consent
- Loyalty
- Rewards

### Phase 12 — Analytics

- Operational dashboards
- Reports
- Exports

### Phase 13 — AI

- Provider abstraction
- Translation
- Natural-language commands
- Analytics summaries
- Forecasting/recommendations

### Phase 14 — Enterprise Platform

- Platform dashboard
- Subscriptions
- Entitlements
- Feature flags
- Country configuration
- Provider management
- Support tools

### Phase 15 — International Expansion

For each country:

- Legal/compliance review
- Tax rules
- Currency
- Localization
- Payment providers
- Receipts/fiscalization
- Privacy/retention
- Regional integrations
- Testing

### Phase 16 — Hardening

- Security review
- Performance testing
- Disaster recovery
- Observability
- CI/CD
- Penetration/security testing as appropriate
- Production readiness

### Phase 17 — Extensions

- Accounting
- Payroll
- Delivery marketplace
- Marketing automation
- Digital signage
- Plugin marketplace
- Additional countries
- Additional providers

---

## 65. What We Should NOT Build First

The architecture should accommodate these, but they should not block the first commercial product:

- Full payroll
- Full accounting
- Delivery marketplace
- Third-party plugin marketplace
- Dozens of countries
- Dozens of payment gateways
- Advanced ML forecasting
- Complex marketing automation
- Digital signage
- Every possible notification provider

The first release should prove that restaurants will pay for the core value proposition.

---

## 66. First Commercial Scope Recommendation

A focused first-country release should prioritize:

1. Restaurant/branch/table management
2. Menu management
3. Multi-language menu foundation
4. QR menu
5. QR ordering
6. Basic table/order workflow
7. Kitchen display
8. Reservations
9. Payment integration appropriate to the first country
10. Basic customer records
11. Basic analytics
12. Secure authentication/permissions
13. Offline-first restaurant operation
14. Cloud synchronization
15. Platform administration

Everything else can be architecturally prepared and implemented according to validated demand.

---

## 67. Architecture Success Criteria

Before considering the foundation complete, we should be able to demonstrate:

- A new module can be added without modifying unrelated modules.
- A new provider can be implemented behind an interface.
- A menu can be edited offline and synchronized later.
- Tenant A cannot access Tenant B data.
- Permission checks work independently of UI visibility.
- Important business workflows have explicit states.
- Events can be published/consumed without direct module coupling.
- Configuration can inherit and override safely.
- Financial values avoid floating-point errors.
- AI cannot directly mutate business data.
- Tests can run without requiring production Firebase.
- Development/staging/production environments are isolated.

---

## 68. Non-Negotiable Rules

1. **Do not hardcode country business rules.**
2. **Do not hardcode payment providers into domain modules.**
3. **Do not hardcode AI providers into domain modules.**
4. **Do not access Firebase directly from UI/business logic.**
5. **Do not trust client authorization.**
6. **Do not use names as primary identifiers.**
7. **Do not use floating-point values as the source of truth for money.**
8. **Do not let AI directly write to databases.**
9. **Do not couple business modules directly to one another without an explicit architectural reason.**
10. **Do not add a feature without considering offline behavior where relevant.**
11. **Do not add a feature without defining permissions.**
12. **Do not add a persistent entity without defining tenant ownership and lifecycle.**
13. **Do not introduce a provider without an interface/adapter boundary.**
14. **Do not ship a critical workflow without tests.**
15. **Do not treat configuration as a replacement for secure application logic.**

---

## 69. Architectural North Star

The desired long-term shape is:

```text
                    BILLAVE PLATFORM
                           │
          ┌────────────────┴────────────────┐
          │                                 │
    Applications                       Platform Admin
          │                                 │
          └──────────────┬──────────────────┘
                         ↓
                 DOMAIN MODULES
                         │
        ┌────────────────┼────────────────┐
        │                │                │
      Menu             Orders       Reservations
        │                │                │
        └────────────────┼────────────────┘
                         ↓
                        CORE
        ┌────────────────┼─────────────────┐
        │        │       │       │         │
      Events   Config   Sync   Auth     Plugins
                         │
                    PROVIDERS
        ┌────────────────┼─────────────────┐
        │                │                 │
      SQLite          Firebase       External APIs
```

The architecture should allow the platform to grow horizontally without turning every new feature into a rewrite of the existing system.

---

## 70. Immediate Next Step

Before implementing restaurant features, create the actual Core architecture and contracts in the repository.

The first implementation milestone is:

```text
Core Foundation
├── Dependency Injection
├── Event Bus
├── Configuration contracts
├── Permission contracts
├── Feature Flag contracts
├── Plugin contracts
├── Repository contracts
├── Result / Failure types
├── Identity / Tenant context
├── Money / Time value objects
├── Logging contracts
└── Test foundation
```

Only after these contracts are reviewed should SQLite, Firebase, and business modules be implemented.

---

## 71. Final Principle

> **Build the platform so that future features are added by extension, not by repeatedly redesigning the foundation.**

The goal is not to predict every future requirement. The goal is to create stable boundaries so that when requirements change, the change is isolated.

That is the standard for BillAve development.
