# Fineasy - Business Management App

A comprehensive Flutter-based business management application for small and medium businesses.

## Features

- **Invoice Management** - Create, track, and manage invoices
- **Payment Tracking** - Record and monitor payments with UPI integration  
- **Customer & Supplier Management** - Maintain business relationships
- **Financial Dashboard** - Real-time business insights and analytics
- **Recurring Payments** - Automate regular transactions
- **WhatsApp Integration** - Send invoices and reminders
- **Reports** - Comprehensive financial reports
- **Multi-user Support** - Role-based access control

## Tech Stack

- **Frontend**: Flutter 3.24.0
- **Backend**: Supabase (PostgreSQL)
- **State Management**: Provider
- **Authentication**: Supabase Auth

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Dart 3.5.0 or higher
- Supabase account

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/fineasy.git
cd fineasy
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure environment
```bash
cp .env.example .env
# Edit .env with your Supabase credentials
```

4. Run the app
```bash
flutter run
```

## Building for Production

### Android (Play Store)

```bash
./build_for_playstore.sh
```

Or manually:
```bash
flutter build appbundle --release
```

### iOS (App Store)

```bash
flutter build ipa --release
```

## Project Structure

```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic
├── widgets/         # Reusable widgets
└── main.dart        # App entry point
```

## Configuration

Create a `.env` file with your credentials:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

Proprietary - All rights reserved

## Contact

For support or inquiries, please open an issue.
