# CHIMBO mobile app — instructions for Claude

This is the Flutter app for CHIMBO. The plan and progress live with the backend:
1. `C:\xampp\htdocs\chimbo\docs\PROGRESS.md` — current phase and next step (read first)
2. `C:\xampp\htdocs\chimbo\docs\CHIMBO_BLUEPRINT.md` — full plan (Flutter architecture §8, API §12, order §19)
3. `C:\xampp\htdocs\chimbo\docs\CODING_STANDARDS.md` — clean-code rules (section 6 = Flutter). The user cares a lot about clean code; every change must follow them.

The backend (PHP API, admin, web storefront) is in `C:\xampp\htdocs\chimbo\`.
Update `PROGRESS.md` at the end of every session.

API facts the app relies on (details: blueprint §12):
- Base URL (local): emulator `http://10.0.2.2/chimbo/api/v1`, real phone `http://<PC-LAN-IP>/chimbo/api/v1`. Working endpoint now: `GET /health`.
- Every response: `{"success": true, "data": ..., "meta": {...}}` or `{"success": false, "error": {"code", "message", "fields"}}`. Error `message` is Kiswahili, ready to show.
- JSON keys are the database column names (`user_id`, `user_phone`, `user_full_name`, `region_id` …).
- Auth (Phase 1, not built yet): phone + 6-digit OTP → Bearer token stored in flutter_secure_storage.

Working rules for this app:
- Follow CODING_STANDARDS §6 (Flutter). Explain new Flutter concepts briefly — the user is learning.
- Work only inside this folder; a separate session builds the PHP backend. When adding your log entry to PROGRESS.md, don't rewrite other entries.
- **Never commit or push unless the user says so.** Keep replies concise.
