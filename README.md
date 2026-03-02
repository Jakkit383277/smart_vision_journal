# API
- ต้องพึ่งการใช้ GOOGLE AI STUDIO API KEY ของตัวเองจะมี .env ที่จะให้ใส่ API ลงไปแล้วก็ใน Lib/features/journal/data/datasources/remote_data_source.dart -------> remote_data_source.dart จะมีบรรทัดนี้ให้กรอกใส่ API ลงไปอีกที/ // ใส่ KEY ใหม่ตรง-- นี้ static const String _apiKey = 'your_real_key_here';
- 
# 📔 Smart Vision Journal

แอปพลิเคชันจดบันทึกอัจฉริยะ ที่รวม OCR และ AI Summarization เข้าด้วยกัน
พัฒนาด้วย Flutter ตาม Clean Architecture

## ✨ Features

- 📝 **บันทึกข้อความ** — เพิ่ม แก้ไข ลบบันทึกได้อย่างง่ายดาย
- 📷 **OCR Scanner** — สแกนข้อความจากรูปภาพด้วย Google ML Kit (Android)
- 🤖 **AI Summarization** — สรุปบันทึกอัตโนมัติด้วย Gemini API
- 🌙 **Dark/Light Mode** — สลับธีมได้ตามใจชอบ บันทึกค่าด้วย SharedPreferences
- 📴 **Offline First** — ใช้งานได้แม้ไม่มีอินเทอร์เน็ต

## 🏗️ Architecture
```
lib/
├── core/
│   ├── di/              # Dependency Injection (get_it)
│   ├── error/           # Failures (dartz Either)
│   ├── network/         # Dio Client + Interceptors
│   ├── services/        # ThemeService (SharedPreferences)
│   └── usecases/        # Abstract UseCase
├── features/journal/
│   ├── domain/          # Entities, Repository Interface, UseCases
│   ├── data/            # Models, DataSources, Repository Impl
│   └── presentation/    # BLoC, Pages, Widgets
└── app/
    ├── router/          # auto_route
    └── theme/           # Ocean Blue Theme
```

## 🛠️ Tech Stack

| Category | Package |
|---|---|
| Architecture | Clean Architecture + Repository Pattern |
| State Management | flutter_bloc |
| DI | get_it + dartz |
| Navigation | auto_route |
| Local DB | sqflite |
| Cache | hive_flutter |
| Settings | shared_preferences |
| Networking | dio |
| AI | Gemini API (gemini-1.5-flash) |
| ML | google_mlkit_text_recognition |
| Testing | mocktail + bloc_test |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.3.0
- Dart SDK >= 3.3.0
- Gemini API Key จาก [Google AI Studio](https://aistudio.google.com)

### Installation
```bash
# 1. Clone repo
git clone https://github.com/YOUR_USERNAME/smart_vision_journal.git
cd smart_vision_journal

# 2. Install dependencies
flutter pub get

# 3. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Setup API Key
# สร้างไฟล์ .env ที่ root
echo "GEMINI_API_KEY=your_api_key_here" > .env

# 5. Run
flutter run
```

### Running Tests
```bash
# Unit + Widget Tests
flutter test

# Integration Tests  
flutter test integration_test/app_test.dart
```

## 📱 Screenshots

> รันแอปแล้ว screenshot มาใส่ตรงนี้ครับ

## 📄 License

MIT License — สร้างเพื่อการศึกษา
```

---

## Push ขึ้น GitHub

### 1. สร้าง `.gitignore` (แก้ให้แน่ใจว่ามีบรรทัดเหล่านี้)
```
.env
*.g.dart
*.gr.dart
/build
.dart_tool/
