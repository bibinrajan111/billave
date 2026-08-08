# BillAve First Commercial Release Plan

This plan follows `docs/BILLAVE_MASTER_ARCHITECTURE_V2.md`: build the Core Foundation before restaurant features, then add the first-country restaurant workflows by extension.

## Release scope

The first commercial release should include:

1. Restaurant, branch, floor, section, and table management.
2. Menu management with categories, items, modifiers, pricing, taxes, and stored translations.
3. QR menu and QR ordering with table/customer sessions.
4. Basic order workflow and kitchen display.
5. Reservations with no-show controls.
6. One payment provider for the launch country.
7. Basic customer records and analytics.
8. Secure authentication, permissions, offline-first local persistence, cloud sync, and platform administration.

## What is implemented now

The repository now contains the first Core Foundation contracts:

- Dependency injection/service registry.
- Event bus contracts and in-memory implementation.
- Configuration contracts.
- Permission contracts.
- Feature flag contracts.
- Plugin contracts.
- Repository contracts.
- Result/failure types.
- Identity/tenant context.
- Money and clock value objects.
- Logging contracts.
- Sync queue contracts.

## Things I cannot do from inside this repo

You must complete these externally:

1. Create Firebase projects for development, staging, and production.
2. Enable Firebase Authentication providers and App Check.
3. Create Firestore and Storage instances.
4. Add real Firebase config files for each platform; do not commit private service-account files.
5. Choose the launch country and verify tax, receipt, privacy, employment, and fiscalization requirements with qualified local professionals.
6. Create payment provider accounts and webhook endpoints.
7. Register app store developer accounts and production signing credentials.
8. Provision production monitoring, backups, domains, and secrets.

## Recommended implementation phases

1. Finish Core Foundation tests and code review.
2. Add local SQLite schema, migrations, local repositories, and durable sync queue.
3. Add Firebase remote repositories, Cloud Functions, Security Rules, Storage Rules, and App Check.
4. Add organization module: tenant, restaurant, branch, floor, section, table, employee roles.
5. Add menu module.
6. Add QR menu and customer session module.
7. Add order and kitchen modules.
8. Add first-country payment provider adapter.
9. Add reservations.
10. Add customer records and basic analytics.
11. Harden security, observability, backup/restore, and CI/CD.

## Exact external setup checklist

1. Install Flutter stable and Firebase CLI.
2. Run `flutter create . --platforms=android,ios,web,windows,macos` if platform folders are not present.
3. Run `flutterfire configure --project <dev-project-id>` for development.
4. Repeat Firebase configuration for staging and production using separate Firebase projects.
5. Enable Firebase Authentication and choose sign-in methods.
6. Enable Firestore in native mode.
7. Enable Cloud Storage.
8. Enable App Check for every supported client platform.
9. Deploy Firestore rules from `docs/firebase/firestore.rules` after adapting project-specific paths if needed.
10. Deploy Storage rules from `docs/firebase/storage.rules` after adapting bucket and path conventions if needed.
11. Configure payment provider webhook secrets only in backend secret storage.
12. Run security-rule emulator tests before production.
