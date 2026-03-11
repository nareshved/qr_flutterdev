# qr_flutterdev

A new Flutter project.

## Project PRD

Below is a **single, consolidated, updated PRD** for your iOS-style Flutter QR app, including everything requested: goals, flows, **packages**, **technical architecture stack**, **navigation**, and **screen sections**.

You can hand this directly to designers and developers.

---

# Product Requirements Document (PRD)

**App Name (working):** QR Studio (placeholder)  
**Platform:** Flutter (iOS primary, Android secondary)  
**Core Features:**  
- Scan QR codes and barcodes  
- Generate QR codes for Website URLs & Phone numbers  
- Manage history, favorites, and sharing  
- Attractive, iOS-style design

---

## 1. Vision & Overview

### 1.1 Vision
Deliver a **beautiful, iOS-style Flutter app** that makes QR use simple and delightful. Users can **scan**, **generate**, and **manage** QR codes and barcodes with minimal friction and maximum visual polish.

### 1.2 Target Users
- Everyday users scanning codes for links, Wi‑Fi, products, etc.
- Professionals generating QR codes for websites or phone numbers.
- Users who appreciate iOS-level design quality and smooth UX.

### 1.3 Non-Goals (for v1)
- Inventory/warehouse-level barcode workflows.
- Advanced AR, heavily stylized QR design, or complex editing.
- Multi-user/team collaboration.

---

## 2. Goals & Success Metrics

### 2.1 Goals
1. **Fast, reliable scanning** for QR & common barcodes.
2. **Simple generation** of QR codes for URLs and phone numbers in just a few steps.
3. **Clear management** of history & favorites without clutter.
4. **iOS-style attractive UI** with intuitive flows.
5. **Privacy & safety**: clear camera permission, safe URL handling.

### 2.2 Metrics
- DAU/WAU and retention (Day 7, Day 30).
- Avg scans/user/day; avg generations/user/day.
- QR generation → successful scan rate (with external scanners).
- Crash-free sessions; error reports.
- Number of favorites and history usage.

---

## 3. Core User Stories & Acceptance Criteria

### 3.1 Scan Codes
**Story:** As a user, I want to scan QR codes & barcodes quickly and act on the results.

**Acceptance:**
- Camera opens with clear permission request and fallback (“from photos”).
- Recognizes QR + a small, defined set of barcodes (e.g., EAN-13, Code128, etc.).
- Displays result with appropriate actions based on content type:
  - URL: Open, Copy, Share.
  - Phone: Call, Add to Contacts, Copy.
  - Plain text: Copy, Share.
- Adds to history if history is enabled.
- Clear error feedback if scan fails.

### 3.2 Generate QR for Website URL
**Story:** As a user, I want to generate a QR code from a website URL.

**Acceptance:**
- URL input with validation (basic format check).
- “Generate QR” button enabled only for plausible URLs.
- Generated QR is shown in high quality and scannable by other apps.
- Actions: Save to Photos, Share, Copy image, Copy URL, Favorite.
- Auto-saved to history (configurable in settings).

### 3.3 Generate QR for Phone Number
**Story:** As a user, I want to generate a QR code from a phone number.

**Acceptance:**
- Phone number input with light validation.
- Explains behavior: “Scanning this QR will prompt a call to this number.”
- Encodes `tel:` URI.
- Generated QR visible, scannable.
- Actions: Save to Photos, Share, Copy image, Copy number, Favorite.
- Auto-saved to history.

### 3.4 Manage History & Favorites
**Story:** As a user, I want to see and manage my scan/generation history and favorites.

**Acceptance:**
- History list with each item’s type, content snippet, timestamp.
- Favorites list as a separate view or tab.
- Search by text (content/label).
- Filters by type (QR / Barcode, Scanned / Generated, time range).
- Swipe or long-press actions: favorite/unfavorite, delete.
- Detail view for each item with all actions and content.

### 3.5 Privacy & Safety
**Story:** As a user, I want to feel safe when using the app.

**Acceptance:**
- Camera permission rationale is clear.
- Option to disable history and/or control retention.
- URL safety: small warning for non-HTTPS or suspicious patterns (simple heuristic).
- Clear settings for privacy: history, analytics (if any), permissions info.

---

## 4. Feature Scope Summary (v1)

- **Scan**
  - Live camera scanning (QR + basic barcodes).
  - Scan from gallery image.
  - Result sheet with context-aware actions.

- **Generate**
  - Generate QR from:
    - Website URL.
    - Phone number (`tel:`).
  - Size option (simple: Small/Medium/Large or just a default for v1 if time-limited).
  - Share/save/copy actions.

- **Manage**
  - History of scanned + generated items.
  - Favorites management.
  - Search & basic filters.
  - Delete and optional export (JSON or CSV if time allows).

- **Settings**
  - History on/off, retention.
  - URL handling: confirm before open toggle.
  - Appearance (System / Light / Dark, if supported).
  - Privacy info, app info, licenses.

---

## 5. Navigation Structure

Using **bottom tab bar** with nested navigation for detail screens.

### 5.1 Tabs

1. **Scan** (default)
2. **Generate**
3. **Manage**
4. **Settings**

### 5.2 Route Map (using `go_router` or similar)

- `/` → `RootTabScaffold`
  - `/scan` → `ScanScreen`
    - `/scan/result/:id` → `ScanResultScreen` (or bottom sheet)
  - `/generate` → `GenerateHomeScreen`
    - `/generate/url` → `GenerateUrlScreen`
    - `/generate/phone` → `GeneratePhoneScreen`
    - `/generate/result/:id` → `GenerateResultScreen` (or on same screen)
  - `/manage` → `ManageHomeScreen`
    - `/manage/history` → `HistoryListScreen` (if separate from main Manage)
    - `/manage/favorites` → `FavoritesScreen`
    - `/manage/item/:id` → `ItemDetailScreen`
  - `/settings` → `SettingsScreen`
    - `/settings/privacy` → `PrivacySettingsScreen`
    - `/settings/about` → `AboutScreen`

Sheets vs full screens can be chosen per UX, but routes should exist.

---

## 6. Screen-by-Screen Requirements

### 6.1 RootTabScaffold

**Purpose:** Host tabs and global layout.

**Sections:**
- Bottom Tab Bar:
  - Icons & labels:
    - Scan: camera/QR icon.
    - Generate: plus/QR icon.
    - Manage: clock/list icon.
    - Settings: gear icon.
- Content area: displays the current tab’s screen.

---

### 6.2 ScanScreen

**Purpose:** Main scanning interface.

**Sections:**
1. **Header**
   - Title: “Scan”.
   - Right icon: History shortcut (optional).

2. **Camera View**
   - Live preview from `mobile_scanner`.
   - Center overlay:
     - Semi-transparent frame (rounded square/rectangle).
     - Instruction text: “Point at a QR or barcode”.

3. **Controls (overlay toolbar)**
   - Flash toggle.
   - Switch camera (if desired).
   - “From Photos” (opens gallery via `image_picker`).
   - (Optional) Info icon.

4. **Scan Feedback**
   - When a code is detected:
     - Pause scanning momentarily.
     - Show bottom sheet: `ScanResultSheet`.

---

### 6.3 ScanResultSheet / ScanResultScreen

**Purpose:** Show result from a scan.

**Sections:**
1. **Header**
   - Small type chip: “QR • URL” / “QR • Phone” / “Barcode • EAN-13”, etc.
   - Timestamp.

2. **Main Content**
   - Large, readable value:
     - URL (truncate middle but allow full view on tap).
     - Phone.
     - Text.
   - Optional label field (editable name).

3. **Primary Actions (context-aware)**
   - For URL:
     - Open (in-app webview or external browser).
     - Copy.
     - Share.
   - For Phone:
     - Call.
     - Add to Contacts.
     - Copy.
   - For text:
     - Copy.
     - Share.

4. **Secondary Actions**
   - Favorite toggle.
   - “View in History” (if needed).
   - Delete from history (if accessed from Manage).

5. **Safety Notice (conditional)**
   - Example: “This link is not HTTPS. Open with caution.”

---

### 6.4 GenerateHomeScreen

**Purpose:** Entry for QR generation flows.

**Sections:**
1. **Header**
   - Title: “Generate”.
   - Subtitle: “Create QR codes for links and phone numbers.”

2. **Primary Options (Cards)**
   - Card 1: “Website URL”
     - Short description: “Turn a website link into a QR code.”
   - Card 2: “Phone Number”
     - “Let people call you by scanning this code.”

3. **Recent Generated (optional)**
   - Horizontal list of the last few generated QRs.

---

### 6.5 GenerateUrlScreen

**Purpose:** Generate QR from website URL.

**Sections:**
1. **Header**
   - Title: “URL QR Code”.
   - Back to Generate.

2. **Input Section**
   - TextField:
     - Placeholder: “https://example.com”.
     - “Paste” button.
   - Inline validation messages:
     - “Enter a valid URL.”

3. **Options**
   - (Optional) Size selector: Small / Medium / Large.
   - (Optional) Auto-favorite toggle.

4. **Generate Button**
   - “Generate QR Code” (enabled only when URL valid).

5. **Result Section** (on same screen or separate `GenerateResultScreen`)
   - QR image (from `qr_flutter` inside `RepaintBoundary`).
   - Text showing encoded URL.
   - Buttons:
     - Save to Photos.
     - Share (with image + URL).
     - Copy QR image.
     - Copy URL text.
     - Favorite toggle.

---

### 6.6 GeneratePhoneScreen

**Purpose:** Generate QR from phone number.

**Sections:**
1. **Header**
   - Title: “Phone QR Code”.

2. **Input Section**
   - TextField:
     - Placeholder: “+1 234 567 890”.
   - Light validation (min length, allowed characters).

3. **Info Text**
   - “Scanning this QR will prompt a call to this number.”

4. **Options**
   - (Optional) Size selector.
   - (Optional) Auto-favorite toggle.

5. **Generate Button**
   - “Generate QR Code”.

6. **Result Section**
   - QR preview.
   - Encoded text: `tel:+1234567890`.
   - Buttons:
     - Save to Photos.
     - Share.
     - Copy image.
     - Copy phone number.
     - Favorite toggle.

---

### 6.7 ManageHomeScreen

**Purpose:** History & favorites management.

**Sections:**
1. **Header**
   - Title: “Manage”.
   - Search icon or search bar.

2. **Tabs or Segment Control**
   - “History” | “Favorites”.

3. **Filter Bar**
   - Filter chips or icon leading to bottom sheet:
     - QR / Barcode.
     - Scanned / Generated.
     - Time: Today / Week / All.

4. **List**
   - Item row card:
     - Icon or badge (QR vs Barcode).
     - Title (label or auto text).
     - Subtitle: content snippet.
     - Timestamp.
   - Swipe actions:
     - Favorite/unfavorite.
     - Delete.

5. **Bulk Actions (optional)**
   - Select multiple items:
     - Delete.
     - Export.

6. **Empty States**
   - For history and favorites, show helpful text and actions.

---

### 6.8 ItemDetailScreen

**Purpose:** Detailed view of a specific history/favorite item.

**Sections:**
1. **Header**
   - Back button.
   - Editable title.
   - Favorite icon.

2. **Preview**
   - QR image (if QR).
   - Generic barcode representation (if barcode).
   - “View full screen” button (optional).

3. **Details**
   - Type & category (e.g., “QR • URL”).
   - Full content text (scrollable).
   - Created/scanned timestamp.

4. **Actions**
   - Same as ScanResult (Open/Call/Add to Contacts/Copy/Share).
   - Delete from history.

5. **Notes (optional)**
   - User notes field.

---

### 6.9 SettingsScreen

**Purpose:** Manage global settings.

**Sections:**
1. **Header**
   - Title: “Settings”.

2. **Appearance**
   - Theme: System / Light / Dark (if supported).

3. **Scanning Behavior**
   - “Confirm before opening URLs” (toggle).
   - “Auto-open URLs after scan” (toggle—mutually consistent).

4. **History & Privacy**
   - “Save scan history” (On/Off).
   - History retention:
     - Keep last 30 / 100 / All.
   - “Clear history” button (with confirm).

5. **Analytics / Data (optional)**
   - “Share anonymous usage data” toggle (if using analytics).

6. **About**
   - App version.
   - Licenses (for `mobile_scanner`, `qr_flutter`, etc.).
   - Privacy Policy link.
   - Rate app link.

---

## 7. Design Requirements

### 7.1 Principles
- Clean, minimal, iOS-style.
- High contrast, legible typography.
- Consistent spacing and component system.
- Light animations & haptics that support clarity.

### 7.2 Visual
- Colors: Neutral background, strong accent (blue/teal), semantic colors for warning/success.
- Typography: iOS system-like (SF Pro). Clear hierarchy for titles, labels, body.
- Components: Cupertino-inspired text fields, buttons, chips, cards, sheets.

### 7.3 UX Details
- Immediate feedback on actions: “Copied”, “Saved to Photos”, “Favorited”.
- Clear states for loading, error, and empty.
- Accessibility:
  - Minimum 44x44 tap targets.
  - VoiceOver/TalkBack labels for all interactive elements.
  - Support at least basic text scaling.

---

## 8. Technical Architecture & Stack

### 8.1 Overall Architecture

**Layers:**
- Presentation (UI, state management).
- Domain (services, use-cases, models).
- Data (local DB, file storage, shared prefs).

### 8.2 State Management

**Recommended:** Riverpod (or hooks_riverpod)

- Providers:
  - `scanControllerProvider`
  - `generateUrlControllerProvider`
  - `generatePhoneControllerProvider`
  - `historyControllerProvider`
  - `settingsControllerProvider`

Alternative: BLoC with separate blocs for Scan, Generate, History, Settings.

### 8.3 Packages Used

**UI & Navigation**
- `flutter` / `cupertino_icons`
- `go_router` – navigation & routes
- `hooks_riverpod` or `riverpod` – state management

**QR & Barcode**
- `mobile_scanner` – scanning QR + common barcodes
- `qr_flutter` – QR code generation widget

**Media & Files**
- `image_picker` – pick images from gallery
- `path_provider` – app directories
- (Optional) `gallery_saver` or platform-specific code to save images to Photos

**Storage & Settings**
- `sqflite` – local database for history & favorites
- `shared_preferences` – app settings (history, theme, behavior)

**Permissions & Sharing**
- `permission_handler` – camera/photos permissions
- `share_plus` – system share sheets

**Optional**
- `firebase_analytics` + `firebase_crashlytics` (if you want analytics/crash reports)
- `logger` – debugging logs

### 8.4 Data Model (High-level)

**ScannedItem**
- `id` (String/int)
- `type` (QR / Barcode)
- `subtype` (e.g., EAN-13, Code128, etc.)
- `category` (URL / Phone / Text / Other)
- `content` (String)
- `label` (String? nullable)
- `isFavorite` (bool)
- `timestamp` (DateTime)

**GeneratedItem**
- `id`
- `category` (URL / Phone)
- `content` (String: URL or tel:)
- `qrImagePath` (String? path to saved image if any)
- `label` (String? nullable)
- `isFavorite` (bool)
- `timestamp` (DateTime)

(You may unify these with a single `Item` model flagged as scanned/generated.)

**Settings**
- `saveHistory` (bool)
- `historyRetention` (int? or enum: last30 / last100 / all)
- `confirmBeforeOpenUrl` (bool)
- `themeMode` (system / light / dark)
- `analyticsOptIn` (bool, optional)

### 8.5 Services & Repositories

- `ScanService`
  - Wraps `mobile_scanner` integration.
  - Maps scanned raw data → `ScannedItem`.

- `QrGenerationService`
  - Uses `qr_flutter` to generate QR.
  - Provides method to export as image file.

- `HistoryRepository`
  - CRUD for scanned & generated items in `sqflite`.

- `SettingsRepository`
  - Wraps `shared_preferences`.

- `FileStorageService`
  - Compose image saving using `path_provider` + `dart:io` + optional gallery save.

### 8.6 Data Flow Examples

**Scan Flow**
- Camera detects → UI receives scan result.
- UI calls `ScanService` to classify & build `ScannedItem`.
- If history enabled → `HistoryRepository.save(item)`.
- UI updates to show `ScanResultSheet`.

**Generate Flow (URL/Phone)**
- User enters data → controller validates.
- On Generate → `QrGenerationService.generate(content)`.
- Service returns preview widget or references.
- Optional: service exports PNG to local path and returns path.
- Controller saves `GeneratedItem` via `HistoryRepository`.
- UI shows result section.

---

## 9. Security, Privacy & Reliability

- No remote server needed for v1: all content stays on-device unless user shares it.
- Camera access clearly explained and only used for scanning.
- Basic URL heuristics:
  - Show warning for non-HTTPS.
  - Avoid auto-opening suspicious patterns.
- Robust error handling for:
  - Camera permission denied.
  - Scan failure (retry hints).
  - File save errors (show user message).
- Option for user to disable history entirely and/or clear it.

---

## 10. Testing & Quality

### 10.1 Testing Levels
- **Unit tests:**
  - URL & phone validation.
  - Model conversions (DB <-> domain).
  - Settings logic.
- **Widget tests:**
  - Generate screens (form validation + result display).
  - Manage lists & filters.
- **Device/integration tests:**
  - Scan performance on at least:
    - 1–2 iPhones (different generations).
    - 1–2 Android phones.
  - Generate → Scan round-trip (generated QR scanned by other apps).

### 10.2 Acceptance for Release
- All core flows work without crashes:
  - Scan → result → history.
  - Generate URL → QR → share/save.
  - Generate phone → QR → share/save.
  - Manage → view/edit/delete/favorite.
- Generated QRs pass test scan on real devices and common third-party apps.
- UI is visually consistent and responsive; no obvious layout breaks.
- Settings work as expected:
  - History on/off and retention.
  - URL confirmation behavior.
- Basic accessibility: labels for main controls, readable fonts, adequate tap areas.


# Prompt for image ui design to working flutter app


Hey, can you take these mobile app designs and turn them
into a working Flutter application? Make sure that the
navigation works between screens and it matches the
design of it exactly. Then run it locally so that I can test it.


# Youtube video link checkout youtube channel

> > Build a Flutter App WITHOUT Coding Using AI QR Scanner App Using Google Antigravity AI 

>> https://youtu.be/GURq5AI5mLw?si=l28OcsdbznsArCWm

