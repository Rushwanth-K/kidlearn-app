# KidLearn 📱
### Safe Educational Video App for Children

> ⚠️ **This is an MVP (Minimum Viable Product)** — Core features are working and tested on a real Android device. The full polished version with improved UI/UX and advanced features is actively being developed.

---

## 📖 About

KidLearn is a child-safe educational short-form video application built for children aged 1–7. It solves a real problem — children are spending large amounts of time on YouTube Shorts and similar platforms that expose them to both educational and potentially harmful content without any filtering or parental oversight.

KidLearn provides a dedicated safe space where children can learn and explore through curated video content, with strong parental controls.

---

## 📱 Screenshots

> Home Screen | Online Videos | Offline Videos | Parent Dashboard

*(Add your app screenshots here)*

---

## ✅ MVP Features

### For the Child
- **Online Mode** — Watch curated safe videos fetched from the backend
- **Offline Mode** — Watch parent-uploaded local videos without internet
- **Category browsing** — Education, Creativity, Nature, Stories, Music
- **No open search** — Browsing is fully curated, no harmful content possible
- **Video player** — Play, pause, skip forward/backward 10 seconds

### For the Parent
- **Register + Login** — Secure JWT authentication
- **Parent Dashboard** — View child's watch history
- **Screen Time Control** — Set daily viewing limits
- **Offline video management** — Upload, categorize and delete local videos

---

## 🔜 Coming in Full Version
- [ ] Polished UI/UX on all screens
- [ ] Child profiles with age-based content filtering
- [ ] Screen time enforcement (auto-lock when limit reached)
- [ ] Content approval system for parent-uploaded videos
- [ ] AI-based video recommendations
- [ ] School integration — teachers can upload content
- [ ] Multilingual support (Tamil, Hindi, English)
- [ ] iOS support

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | Flutter | Cross-platform Android + iOS app |
| State Management | StatefulWidget + setState | UI state management |
| Local Database | SQLite (sqflite) | Offline video storage |
| Video Playback | video_player + chewie | Online and offline video player |
| File Handling | file_picker | Parent video uploads |
| HTTP Client | http | API calls to backend |
| Secure Storage | flutter_secure_storage | JWT token storage |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── database_helper.dart         # SQLite CRUD operations
├── screens/
│   ├── login_screen.dart        # Parent login
│   ├── register_screen.dart     # Parent registration
│   ├── home_screen.dart         # Home with mode selection
│   ├── online_screen.dart       # Online videos with category filter
│   ├── offline_screen.dart      # Offline videos with file picker
│   ├── video_player_screen.dart # Video player (online + offline)
│   └── parent_dashboard_screen.dart  # Watch history + screen time
└── services/
    └── api_service.dart         # All API calls to Node.js backend
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio or VS Code
- Android device or emulator

### Installation

1. Clone the repository
```bash
git clone https://github.com/Rushwanth-K/kidlearn-app.git
cd kidlearn-app
```

2. Install dependencies
```bash
flutter pub get
```

3. Update the API base URL in `lib/services/api_service.dart`
```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:3000';
```

4. Run the app
```bash
flutter run
```

---

## 🔗 Backend Repository

The Node.js backend for this app is available here:
👉 [kidlearn-backend](https://github.com/Rushwanth-K/kidlearn-backend)

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0          # Local SQLite database
  file_picker: ^8.0.0       # Pick video files from device
  video_player: ^2.8.0      # Video playback
  path: ^1.9.0              # File path handling
  http: ^1.2.0              # HTTP requests to backend
  flutter_secure_storage: ^9.0.0  # Secure JWT token storage
```

---

## 👨‍💻 Developer

**Rushwanth K**
- BCA Final Year Student
- GitHub: [@Rushwanth-K](https://github.com/Rushwanth-K)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

> 💡 **This project is both a Final Year College Project and a Startup MVP.**
> Built with the goal of making screen time safe and educational for every child.
