# CHIMBO mobile app — rules for every AI coding agent

This is the Flutter app. The shared rules for all agents live with the backend — **read them first and follow them exactly**:
1. `C:\xampp\htdocs\chimbo\AGENTS.md` — which files each area may edit, non-negotiable rules, definition of done, Git rules
2. `C:\xampp\htdocs\chimbo\docs\CODING_STANDARDS.md` — clean-code rules (**§6 = Flutter/Dart**)
3. `C:\xampp\htdocs\chimbo\docs\API_REFERENCE.md` — every endpoint and the exact JSON field names
4. `C:\xampp\htdocs\chimbo\docs\PROGRESS.md` — current state (newest entries first)

App-specific rules:
- Edit only this folder. Never change the backend (`C:\xampp\htdocs\chimbo\…`); if you need an endpoint or field, tell the user.
- Feature-first structure: `data/` (API + repository + models), `application/` (Riverpod controllers), `presentation/` (screens, widgets). Widgets never call the API or hold business rules.
- JSON keys are the database column names (`user_phone`, `product_price_from` …). Prices and totals always come from the server.
- API base URL comes from `--dart-define=API_BASE_URL=…` (default: the emulator's `http://10.0.2.2/chimbo/api/v1`). Every request sends the `ngrok-skip-browser-warning` header (see `lib/core/config/env.dart`).
- Customer text in Kiswahili through the l10n files — no hard-coded strings or colours.
- Done means: `flutter analyze` clean, `flutter test` passes, entry added to PROGRESS.md.
- Never commit or push unless the user asks; plain commit messages; no "Co-Authored-By" line.
