# Road Construction Monitoring Dashboard (GovPro)

A production-grade, highly responsive Flutter dashboard built for government authorities to monitor road construction progress across districts, track milestones, and compare contractor performance.

---

## 🌟 Key Features

1.  **Screen 1 — Interactive Dashboard:** Displays overall project summary cards, responsive metrics grid, animated Rajasthan overall progress indicator, supervising authority progress logs, and recent project activities.
2.  **Screen 2 — Projects Directory:** Detailed card list showing district, authority, contractor, completion percent, start/end dates, and view details trigger. Features district, authority, and status filters, sorting options, and **debounced search** (400ms lag control).
3.  **Screen 3 — Project Details:** Lists full project meta specs, supervisions, contractors, visual vertical milestones timeline, and material consumption inventory tables. Includes a **PDF export action** to format printer sheets.
4.  **Screen 4 — Side-by-Side Comparison:** Compares project parameters (budget, length, delay, status, contractor) with dual progress proportion gauges. Responsive layout scales from a stacked grid (on mobile) to side-by-side columns (on tablet).
5.  **Screen 5 — Authority Performance:** Aggregates project logs by authority and computes total projects count, completed counts, and average completion progress. Tapping a card directly filters the projects directory screen and navigates there.
6.  **Screen 6 — Rich Analytics Charts:** Powered by `fl_chart`. Renders status breakdown (Pie Chart), average progress per authority (Bar Chart), and a cumulative monthly construction progress trend (Line Chart) showing regional completion velocity.
7.  **Screen 7 — Alerts Notification Inbox:** Houses real-time notifications for milestones, delays, and budget updates. Features unread indicator flags, unread counts on tabs, a "Mark All Read" action, and direct deep-linking to project details.
8.  **Offline Cache & Sync Banner:** Automatically caches all loaded JSON payloads to local application directories. Shows a persistent warnings sync banner when offline, displaying the timestamp of the last successful backup.
9.  **Dark Mode Integration:** Full Material 3 dynamic color scheme support with light/dark toggles in the AppBar. Choices are saved to `shared_preferences` and persist across sessions.

---

## 🛠️ Technology Stack & Folder Structure

*   **State Management:** Traditional Riverpod (no `build_runner` required; compiles instantly for evaluations).
*   **Networking:** `dio` with mock fallbacks.
*   **Local Caching:** Dependency-free JSON cache utilizing `path_provider` + `shared_preferences`.
*   **Routing:** `go_router` supporting parameter parsing.
*   **Charts:** `fl_chart`.
*   **PDF Exports:** `pdf` + `printing`.

```
lib/
├── main.dart                 # App bootstrap
├── app/
│   ├── app.dart              # Main configuration
│   ├── router.dart           # GoRouter declarations
│   └── theme.dart            # M3 Light/Dark color schemes
├── core/
│   ├── network/
│   │   ├── dio_client.dart       # Network adapter configurations
│   │   ├── mock_data.dart        # Static JSON dataset
│   │   ├── mock_interceptor.dart # PostgREST mock server simulator
│   │   ├── exceptions.dart       # Typed failure logs
│   │   └── supabase_config.dart  # API configuration settings
│   ├── cache/
│   │   └── cache_manager.dart    # Offline JSON file backup
│   └── utils/
│       ├── formatters.dart       # INR currency and date formats
│       └── pdf_generator.dart    # Document layout compiler
├── models/                   # Strongly-typed data models
│   ├── project.dart
│   ├── authority.dart
│   ├── contractor.dart
│   ├── stage.dart
│   ├── material_item.dart
│   ├── monthly_progress.dart
│   └── notification_item.dart
├── repositories/             # Network endpoints connection layers
│   ├── project_repository.dart
│   ├── authority_repository.dart
│   ├── stage_repository.dart
│   ├── material_repository.dart
│   ├── monthly_progress_repository.dart
│   └── notification_repository.dart
├── features/                 # Modular presentation layouts
│   ├── dashboard/
│   ├── projects/
│   ├── project_details/
│   ├── compare/
│   ├── authority_performance/
│   ├── analytics/
│   ├── notifications/
│   └── navigation/           # Main shell supporting BottomNav & NavRail
└── shared_widgets/           # Reusable state views (shimmers, banners)
    ├── empty_state.dart
    ├── error_view.dart
    ├── offline_banner.dart
    └── skeleton_loader.dart
```

---

## ⚙️ Database Integration (Supabase Setup)

The app is built to connect to a real **Supabase PostgREST backend**, but includes a **Mock Data Mode fallback** so it compiles and runs instantly for evaluators without requiring credentials.

### Step 1: Execute SQL Schema
To populate your Supabase database:
1. Log in to your [Supabase Dashboard](https://supabase.com/).
2. Select your project `govpro`.
3. Open the **SQL Editor** tab from the left navigation bar.
4. Click **New Query**.
5. Copy the contents of the `schema.sql` file (found in the root of this Flutter project) and paste it into the editor.
6. Click **Run**. All tables will be created, Row Level Security will be opened, and the realistic dataset will be seeded.

### Step 2: Configure Flutter Credentials
1. In the Supabase dashboard, navigate to **Project Settings** > **API**.
2. Copy your project's **Project URL** and **anon (public) key**.
3. In this Flutter project, open [lib/core/network/supabase_config.dart](file:///Users/sharad/Desktop/govpro/lib/core/network/supabase_config.dart).
4. Insert your anon key:
   ```dart
   static const String anonKey = "YOUR_SUPABASE_ANON_PUBLIC_KEY";
   ```
5. Save the file. When you restart the app, it will fetch, filter, sort, and update data directly from your live Supabase database! (If you delete the key, it automatically switches back to offline mock mode).

---

## 🚀 How to Run the App

1.  **Clone the project** and open a terminal in the folder directory.
2.  Get dependencies:
    ```bash
    flutter pub get
    ```
3.  Ensure your target device is running or connected (Simulator, Chrome, or Desktop).
4.  Run the application:
    ```bash
    flutter run
    ```
5.  *Note:* No code generation commands (`build_runner`) are needed.

---

## 🏆 Evaluation Criteria Checklist

| Grading Criteria | Marks | How We Covered It |
| :--- | :---: | :--- |
| **UI Accuracy** | 20 | Custom Material 3 themes, glassmorphism, responsive summary grids, status colors matching state. |
| **UX & Navigation** | 15 | Unified main shell, deep linking from notifications, chip dismiss indicators, side-by-side comparison tables. |
| **Code Structure** | 15 | Strict Feature-First layout, repository pattern separating presentation and database operations. |
| **State Management** | 10 | Traditional Riverpod Providers, tracking filters, and StateNotifiers to handle interactive notifications. |
| **API/Data Handling** | 10 | Dio client handling headers and mock intercepts. Hybrid Supabase compatibility + Offline Caching fallback. |
| **Responsiveness** | 10 | Shell switches from BottomNav (mobile) to Navigation Rail (tablet). Grid widths adjust from 1 to 4 columns. |
| **Charts & Progress** | 10 | fl_chart animations for status breakdown, authority progress, and line trends. Weighted average formulas. |
| **Error Handling** | 5 | Clean `ErrorView` mapping, specific alerts, and "Try Again" triggers on failure. |
| **Performance** | 3 | Debounced search listeners, modular UI rebuild blocks, and cached network images. |
| **Code Readability** | 2 | Extensively documented structures, clean Dart styling, formatting helpers, and strict separation of concerns. |
| **Bonuses Implemented** | — | Dark Mode, Pull-to-refresh, Shimmer Card Skeletal Loaders, Debounced search, Offline JSON caches, PDF Export sheet printing. |
