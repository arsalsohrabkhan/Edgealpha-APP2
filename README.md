# AlphaEdge Capital — Flutter App

Exact Flutter port of the AlphaEdge web portal.

## Screens
| Screen | Route | Description |
|--------|-------|-------------|
| Landing | `/` | Marketing page matching index.html |
| Login | `/login` | Client + Admin login matching login.html |
| Dashboard | `/dashboard` | Main portfolio dashboard |
| Trades | `/trades` | All trades with filter chips |
| Performance | `/performance` | Sharpe, drawdown, equity curve |
| Reports | `/reports` | Generate account/trade/performance reports |
| Messages | `/messages` | Client ↔ advisor messaging |
| Admin | `/admin` | Portfolio oversight for all clients |
| Admin Messages | `/admin/messages` | All client threads |
| Admin Reports | `/admin/reports` | Generate reports for any client |

## Setup

### 1. Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=alphaedge-993e2
```
This regenerates `lib/firebase_options.dart` with correct values.

### 2. Firestore Structure
Each client is a document in the `clients` collection with ID = their numeric ID (e.g. "1", "2"):

```json
{
  "first": "Arsal",
  "last": "Khan",
  "email": "abcd",
  "password": "abcd",
  "phone": "+1 (212) 555-0101",
  "initials": "AK",
  "color": "#f0a500",
  "status": "Active",
  "risk": "Moderate",
  "joined": "Jan 15, 2026",
  "capital": 240000,
  "trades": [
    { "id": "t1", "asset": "BTC", "direction": "long", "pnl": 21016, "pct": 8.76,
      "openDate": "Jan 20, 2026", "closeDate": "Jan 28, 2026" }
  ],
  "messages": [
    { "id": "m1", "from": "admin", "text": "Welcome!", "time": "Jan 15, 2026 · 09:00 AM" }
  ]
}
```

Admin password is stored in `config/admin` document:
```json
{ "password": "admin2026" }
```

### 3. Migrate your clients-data.js to Firestore
Run this once in a browser console on your web app, or use the Firebase Console to manually create documents matching the structure above.

### 4. Run locally
```bash
flutter pub get
flutter run
```

### 5. Deploy via Codemagic
- Push to GitHub
- Connect repo in Codemagic
- Use the included `codemagic.yaml`
- Add your signing credentials in Codemagic environment

## Dependencies
- `firebase_core`, `cloud_firestore` — Firebase
- `provider` — State management
- `go_router` — Navigation
- `fl_chart` — Charts (equity line + donut)
- `google_fonts` — Syne + Playfair Display fonts
- `flutter_animate` — Animations
