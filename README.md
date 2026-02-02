# 7Eps - Progressive Disclosure Dating App

A Flutter + Supabase dating app focused on meaningful connections through a 7-episode progressive disclosure journey.

## 🎯 Core Features

- **Daily Edition**: 3-5 curated matches per day (no infinite swiping)
- **Max 3 Active Journeys**: Quality over quantity
- **Progressive Disclosure**: Photos blur and unblur as episodes progress
- **7-Episode Structure**: Guided interactions from funny prompts to date suggestions
- **Book Timeline**: Artifact-based journal (not chat bubbles)

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart 3+)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management**: Riverpod
- **Navigation**: go_router
- **Code Generation**: freezed + json_serializable

## 📋 Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Supabase account (free tier works)
- Android Studio / VS Code (for Flutter development)

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd 7Eps
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Go to Project Settings → API
4. Copy your project URL and anon key

### 4. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
# Supabase Configuration
SUPABASE_URL=your-project-url.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 5. Update Supabase Client

Edit `lib/core/supabase/supabase_client.dart`:

```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  debug: true,
);
```

### 6. Run Database Migrations

Option 1: Via Supabase Dashboard
1. Go to SQL Editor in Supabase
2. Run each migration file in order:
   - `supabase/migrations/001_initial_schema.sql`
   - `supabase/migrations/002_rls_policies.sql`
   - `supabase/migrations/003_functions_triggers.sql`

Option 2: Via Supabase CLI

```bash
# Install Supabase CLI
npm install -g supabase

# Link to your project
supabase link --project-ref your-project-id

# Push migrations
supabase db push
```

### 7. Run Code Generation

```dart
// Generate freezed and riverpod code
flutter pub run build_runner build --delete-conflicting-outputs
```

### 8. Run the App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## 📱 Development

### Project Structure

```
lib/
├── core/               # Core functionality
│   ├── router/        # Navigation (go_router)
│   ├── supabase/      # Supabase client
│   └── theme/         # App theme
├── models/            # Data models
├── providers/         # Riverpod providers
├── features/          # Feature modules
│   ├── auth/          # Authentication
│   ├── profile/       # User profiles
│   ├── daily_edition/ # Daily matches
│   ├── journey/       # Episode progression
│   └── timeline/      # Artifact timeline
└── utils/             # Utilities
```

### Running Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

### Code Generation

After modifying models with `@freezed` or `@Riverpod` annotations:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔐 Security Features

- **Row Level Security (RLS)**: All tables have RLS policies
- **Server-Side Validation**: Episode progression enforced in Postgres
- **Max Journey Limit**: Trigger enforces max 3 active journeys
- **Input Validation**: All server functions validate inputs
- **Auth-Scoped Storage**: Profile photos and artifacts secured

## 📊 Database Schema

### Key Tables

- `profiles` - User profiles and demographics
- `profile_photos` - User profile photos
- `daily_editions` - Daily curated matches (3-5 per day)
- `matches` - Journey/match records
- `match_participants` - Many-to-many relationship
- `artifacts` - Episode submissions

### Key Functions

- `submit_artifact(match_id, type, payload)` - Submit with validation
- `create_match(user1_id, user2_id)` - Create with enforcement
- `get_active_matches(user_id)` - Get user's active journeys
- `get_current_episode_info(match_id)` - Get episode progress

## 🎨 UI/UX

**Aesthetic**: "Indie bookstore meets high-end journal"

**Color Palette**:
- Sage Green: #87A878
- Terracotta: #C17F59
- Cream: #F5F1E8
- Charcoal: #3D3D3D

**Typography**:
- Headings: Merriweather (serif)
- Body: Inter (sans-serif)

## 🔧 Troubleshooting

### Migration Failures

If migrations fail, check:
1. Supabase project is active (not paused)
2. You have admin privileges
3. Run migrations in order (001, 002, 003)

### Code Generation Issues

```bash
# Clean build cache
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Auth Issues

Check:
1. `.env` file has correct Supabase URL and key
2. Supabase Auth is enabled
3. Email templates are configured in Supabase

## 📝 License

Proprietary - All rights reserved

## 🤝 Contributing

This is a private project. For questions, contact the development team.
